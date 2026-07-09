# Docker Rules

## Agente responsável

`devops-engineer` → `security-reviewer` → `observability-engineer`

---

## Princípios gerais

- Toda imagem deve ter tamanho mínimo justificável.
- Multi-stage build obrigatório para serviços Java e para o frontend.
- Não executar containers como `root` quando o processo permitir usuário não privilegiado.
- Configuração exclusivamente por variável de ambiente — nenhum segredo no Dockerfile ou na imagem.
- Build deve ser reproduzível: mesma imagem gerada em qualquer máquina com os mesmos inputs.
- Não versionar `.env` com valores reais. Versionar apenas `.env.example`.

---

## Regras de imagem mínima

### Escolha de imagem base

- Preferir variantes `alpine` sempre que o runtime suportar: `eclipse-temurin:21-jre-alpine`, `nginx:1.27-alpine`, `node:20-alpine`.
- Nunca usar `latest` — fixar versão explícita (ex.: `mongo:7.0`, `node:20-alpine`).
- Não usar JDK na imagem de runtime — usar apenas JRE (`eclipse-temurin:21-jre-alpine`).
- Para casos onde Alpine não é compatível (ex.: dependência de glibc), usar `eclipse-temurin:21-jre-jammy` (Ubuntu slim) como alternativa.

### Redução de camadas e contexto

- Copiar `package.json` / `pom.xml` **antes** do código fonte para maximizar o cache de dependências.
- Combinar instalações em um único `RUN` quando envolver `apk` ou `apt`:
  ```dockerfile
  RUN apk add --no-cache curl wget
  ```
- Nunca usar `apk add` sem `--no-cache` — evita cache de índice dentro da imagem.
- Usar `.dockerignore` obrigatório em **todos** os contextos de build para excluir `target/`, `node_modules/`, `.git/`, `*.log`, `.env`.

### Java / Spring Boot

- Usar `-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0` no `ENTRYPOINT` para respeitar os limites de memória do container.
- Não copiar fontes, testes ou arquivos de build para a imagem de runtime — apenas o `.jar` final.
- Construir somente o módulo necessário com `mvn -pl <modulo> package -DskipTests` — não rebuildar o monorepo inteiro.

### Frontend (Node + Nginx)

- Usar `npm ci --prefer-offline --no-audit` no build — mais rápido e determinístico que `npm install`.
- Copiar apenas `www/browser` para o Nginx — não copiar assets de desenvolvimento.
- Remover a configuração `default.conf` do Nginx antes de adicionar a configuração customizada.

### Verificação de tamanho

Após build, verificar o tamanho com:
```bash
docker images agendahub/<servico>:local
```

Referência orientativa por tipo de serviço:

| Serviço | Tamanho esperado |
|---|---|
| Spring Boot (JRE Alpine) | 180–280 MB |
| Nginx Alpine + bundle Angular | 30–60 MB |
| mongo:7.0 | ~750 MB (fixo, não customizável) |

---

## Estrutura de composes no projeto

```
apps/backend/
├── platform/api-gateway/
│   ├── Dockerfile              # build context: apps/backend/
│   └── docker-compose.yml      # standalone (gateway + host services)
├── services/
│   ├── identity-service/
│   │   └── infra/
│   │       ├── Dockerfile
│   │       └── docker-compose.yml  # standalone (service + MongoDB próprio)
│   └── ... (mesmo padrão para cada serviço)
└── .dockerignore

apps/mobile-app/
├── Dockerfile                  # build context: apps/mobile-app/
├── nginx.conf
├── docker-compose.yml          # standalone
└── .dockerignore

infra/
├── docker-compose.yml          # full stack (todos os serviços + MongoDB compartilhado)
├── nginx/
│   └── nginx.conf
└── mongo/
    └── init.js                 # criação dos bancos na primeira inicialização
```

### Quando usar cada compose

| Situação | Comando |
|---|---|
| Desenvolver um serviço isolado | `cd apps/backend/services/<service>/infra && docker compose up --build` |
| Subir apenas o gateway com serviços no host | `cd apps/backend/platform/api-gateway && docker compose up --build` |
| Subir apenas o frontend | `cd apps/mobile-app && docker compose up --build` |
| Subir o stack completo | `cd infra && docker compose up --build` |

---

## Dockerfile — microservices Java (Spring Boot)

Localização por serviço:

```text
apps/backend/services/<service>/infra/Dockerfile
```

O build context dos Dockerfiles em `services/<service>/infra` deve ser definido explicitamente no compose para preservar acesso ao módulo Maven necessário. Quando o Dockerfile precisa empacotar um módulo do monorepo, o context normalmente deve apontar para `apps/backend`.

### Estrutura multi-stage obrigatória

```dockerfile
# ── Estágio 1: build ──────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q

# ── Estágio 2: runtime ────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=build /app/target/*.jar app.jar
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Regras específicas para Java

- Usar `eclipse-temurin:21-jre-alpine` no runtime — não usar JDK na imagem final.
- Desabilitar testes no build da imagem (`-DskipTests`): testes rodam na pipeline CI, não no build Docker.
- Passar perfil Spring ativo via variável de ambiente: `SPRING_PROFILES_ACTIVE=prod`.
- Expor somente a porta do serviço — não expor porta de debug em imagens de produção.
- Health check via `/actuator/health` — garantir que o endpoint está habilitado no `application.yml`.

### Variáveis de ambiente obrigatórias por microservice

| Variável | Descrição |
|---|---|
| `SPRING_PROFILES_ACTIVE` | Perfil ativo (`local`, `dev`, `prod`) |
| `SPRING_DATA_MONGODB_URI` | URI completa de conexão MongoDB |
| `SERVER_PORT` | Porta HTTP do serviço (padrão: 8080) |
| `JWT_SECRET` | Segredo JWT (somente para identity-service) |
| `MAIL_*` | Configurações SMTP (somente para email-service) |

---

## Dockerfile — frontend Ionic Angular (Nginx)

### Estrutura multi-stage obrigatória

```dockerfile
# ── Estágio 1: build ──────────────────────────────────────────
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline
COPY . .
RUN npm run build -- --configuration=production

# ── Estágio 2: runtime via Nginx ─────────────────────────────
FROM nginx:1.27-alpine AS runtime
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/www/browser /usr/share/nginx/html
COPY infra/nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:80/ || exit 1
```

### Regras específicas para o frontend

- Usar `npm ci` no build — nunca `npm install` em imagem.
- Copiar apenas o conteúdo de `www/browser` para o Nginx — não expor assets de build.
- O Nginx serve os arquivos estáticos e faz proxy das chamadas `/api/**` para o API Gateway.
- Configurar `try_files $uri $uri/ /index.html` para suporte a rotas Angular (SPA).

---

## Nginx — configuração de referência

Localização: `infra/nginx/nginx.conf`

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Rotas Angular (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy para API Gateway
    location /api/ {
        proxy_pass         http://api-gateway:8080/;
        proxy_http_version 1.1;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
        proxy_connect_timeout 5s;
    }

    # Bloquear acesso a arquivos ocultos
    location ~ /\. {
        deny all;
    }
}
```

---

## Docker Compose — ambiente local

Localização: `infra/docker-compose.yml`

### Regras

- Definir uma rede interna `backend-net` para comunicação entre serviços — não expor portas internas desnecessariamente.
- MongoDB com volume nomeado para persistência local.
- Cada serviço Java declara `depends_on` com `condition: service_healthy` para MongoDB.
- API Gateway é o único container com porta exposta para o host além do frontend.
- Frontend (Nginx) acessa o API Gateway pelo nome de serviço interno.
- Usar `env_file: .env` em todos os serviços — nunca hardcode de credencial no compose.

### Estrutura de serviços esperada

```
infra/
├── docker-compose.yml
├── docker-compose.override.yml   # overrides locais, não versionado com valores reais
├── nginx/
│   └── nginx.conf
└── mongo/
    └── init.js                   # script de inicialização do MongoDB (opcional)
```

### Portas expostas no ambiente local (referência)

| Serviço | Porta interna | Porta host (local) |
|---|---|---|
| mobile-app (Nginx) | 80 | 4200 |
| api-gateway | 8080 | 8080 |
| identity-service | 8080 | — (interno) |
| company-service | 8080 | — (interno) |
| client-service | 8080 | — (interno) |
| catalog-service | 8080 | — (interno) |
| order-service | 8080 | — (interno) |
| email-service | 8080 | — (interno) |
| mongodb | 27017 | 27017 (somente local) |

---

## Segurança

- Não usar `latest` como tag de imagem base — fixar versão explícita.
- Não expor porta do MongoDB para fora da rede interna em produção.
- Não incluir arquivos `.env`, `*.jks`, `*.p12`, `application-prod.yml` na imagem.
- `.dockerignore` obrigatório em cada serviço com no mínimo: `target/`, `node_modules/`, `.env`, `*.log`.
- Atualizar imagens base regularmente para receber patches de segurança.
- Health check obrigatório em todo container que possua dependentes (`depends_on`).

---

## Observabilidade em containers

- Logs devem ir para `stdout`/`stderr` — nunca gravar log em arquivo dentro do container.
- Spring Boot já faz isso por padrão — não configurar appender de arquivo no perfil `prod`.
- Variável `JAVA_TOOL_OPTIONS` pode ser usada para configurar memória sem alterar o Dockerfile:
  ```
  JAVA_TOOL_OPTIONS=-Xmx512m -Xms256m
  ```
- Métricas Actuator/Micrometer acessíveis dentro da rede interna para coleta por Prometheus.

---

## .dockerignore — referência para serviços Java

```
target/
.mvn/
*.md
.git/
.env
*.log
```

## .dockerignore — referência para o frontend

```
node_modules/
www/
dist/
.angular/
.git/
*.md
.env
*.log
coverage/
```
