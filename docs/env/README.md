<!-- TEMPLATE:ESQUELETO -->
# Variaveis de Ambiente

Este documento e a referencia de manutencao das variaveis dinamicas do projeto.
O arquivo executavel de exemplo fica em `.env.example`; o arquivo `.env` local
nao deve ser versionado porque pode conter segredos reais.

## Regra de manutencao

Sempre que uma nova variavel de ambiente for adicionada em `application.yml`,
Docker, pipeline, script de subida ou configuracao do frontend, atualizar tambem:

- `.env.example`
- `docs/env/README.md`

Nao registrar senhas, tokens reais, chaves privadas ou credenciais de ambientes
em nenhum arquivo versionado.

## Como carregar o `.env` com Spring Boot

Crie o arquivo local a partir do exemplo:

```bash
cp .env.example .env
```

No PowerShell:

```powershell
Copy-Item .env.example .env
```

Suba o servico informando o arquivo ao Spring Boot:

```bash
export SPRING_CONFIG_IMPORT="optional:file:$PWD/.env[.properties]"
mvn -f apps/backend/services/identity-service/pom.xml spring-boot:run
```

No PowerShell:

```powershell
$env:SPRING_CONFIG_IMPORT="optional:file:$PWD/.env[.properties]"
mvn -f apps/backend/services/identity-service/pom.xml spring-boot:run
```

Troque o caminho do `pom.xml` para subir outro servico.

## Variaveis globais

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `APP_ENV` | Nao | `local` | Nome do ambiente de execucao. |
| `INTERNAL_GATEWAY_TOKEN` | Sim | - | Token compartilhado para comunicacao interna entre gateway e servicos. Deve ser forte e diferente por ambiente. |

## API Gateway

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `API_GATEWAY_PORT` | Nao | `8080` | Porta HTTP do gateway. |
| `SESSION_INTROSPECTION_TIMEOUT` | Nao | `2s` | Timeout para introspeccao de sessao no identity-service. |
| `SERVICE_MONITOR_TIMEOUT` | Nao | `2s` | Timeout individual usado pelo gateway ao consultar `monitor.services`. |
| `IDENTITY_SERVICE_URL` | Nao | `http://localhost:8081` | URL interna do identity-service. |
| `COMPANY_SERVICE_URL` | Nao | `http://localhost:8082` | URL interna do company-service. |
| `CLIENT_SERVICE_URL` | Nao | `http://localhost:8083` | URL interna do client-service. |
| `CATALOG_SERVICE_URL` | Nao | `http://localhost:8084` | URL interna do catalog-service. |
| `ORDER_SERVICE_URL` | Nao | `http://localhost:8085` | URL interna do order-service. |
| `SCHEDULING_SERVICE_URL` | Nao | `http://localhost:8087` | URL interna do scheduling-service. |
| `EMAIL_SERVICE_URL` | Nao | `http://localhost:8086` | URL interna do email-service usada no monitor agregado. |

## Identity Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `IDENTITY_SERVICE_PORT` | Nao | `8081` | Porta HTTP do identity-service. |
| `IDENTITY_MONGODB_URI` | Sim | - | URI MongoDB exclusiva do identity-service. Usar usuario com menor privilegio. |
| `EMAIL_SERVICE_URL` | Nao | `http://localhost:8086` | URL interna do email-service. |

## Company Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `COMPANY_SERVICE_PORT` | Nao | `8082` | Porta HTTP do company-service. |
| `COMPANY_MONGODB_URI` | Sim | - | URI MongoDB exclusiva do company-service. Usar usuario com menor privilegio. |
| `CORREIOS_CEP_API_BASE_URL` | Nao | `https://api.correios.com.br/cep` | URL base da integracao de CEP dos Correios. |
| `CORREIOS_CEP_API_TOKEN` | Conforme ambiente | vazio | Token da API de CEP quando exigido pelo provedor. |
| `CORREIOS_CEP_API_TIMEOUT` | Nao | `2s` | Timeout da chamada externa para CEP. |
| `IDENTITY_SERVICE_URL` | Nao | `http://localhost:8081` | URL interna do identity-service. |

## Client Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `CLIENT_SERVICE_PORT` | Nao | `8083` | Porta HTTP do client-service. |
| `CLIENT_MONGODB_URI` | Sim | - | URI MongoDB exclusiva do client-service. Usar usuario com menor privilegio. |
| `SCHEDULING_CLIENT_SERVICE_TOKEN` | Sim | - | Token exclusivo aceito do scheduling-service para localizar ou cadastrar cliente por telefone. |
| `CORREIOS_CEP_API_BASE_URL` | Nao | `https://api.correios.com.br/cep` | URL base da integracao de CEP dos Correios. |
| `CORREIOS_CEP_API_TOKEN` | Conforme ambiente | vazio | Token da API de CEP quando exigido pelo provedor. |
| `CORREIOS_CEP_API_TIMEOUT` | Nao | `2s` | Timeout da chamada externa para CEP. |

## Catalog Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `CATALOG_SERVICE_PORT` | Nao | `8084` | Porta HTTP do catalog-service. |
| `CATALOG_MONGODB_URI` | Sim | - | URI MongoDB exclusiva do catalog-service. Usar usuario com menor privilegio. |

## Order Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `ORDER_SERVICE_PORT` | Nao | `8085` | Porta HTTP do order-service. |
| `ORDER_MONGODB_URI` | Sim | - | URI MongoDB exclusiva do order-service. Usar usuario com menor privilegio. |
| `SCHEDULING_ORDER_SERVICE_TOKEN` | Sim | - | Token exclusivo para autenticar comandos do scheduling-service no order-service. |

## Scheduling Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `SCHEDULING_SERVICE_PORT` | Nao | `8087` | Porta HTTP do scheduling-service. |
| `SCHEDULING_MONGODB_URI` | Sim | - | URI MongoDB exclusiva do scheduling-service. Usar usuario com menor privilegio. |
| `CLIENT_SERVICE_URL` | Nao | `http://localhost:8083` | URL interna usada para localizar ou cadastrar cliente no autoagendamento. |
| `SCHEDULING_CLIENT_SERVICE_TOKEN` | Sim | - | Token compartilhado exclusivamente entre scheduling-service e client-service. |
| `CLIENT_SERVICE_CONNECT_TIMEOUT` | Nao | `2s` | Timeout de conexao com o client-service. |
| `CLIENT_SERVICE_READ_TIMEOUT` | Nao | `5s` | Timeout de resposta do client-service. |
| `ORDER_SERVICE_URL` | Nao | `http://localhost:8085` | URL interna usada para gerar pedido a partir do atendimento. |
| `SCHEDULING_ORDER_SERVICE_TOKEN` | Sim | - | Token compartilhado exclusivamente entre scheduling-service e order-service. |
| `ORDER_SERVICE_CONNECT_TIMEOUT` | Nao | `2s` | Timeout de conexao com o order-service. |
| `ORDER_SERVICE_READ_TIMEOUT` | Nao | `5s` | Timeout de resposta do order-service. |

## Email Service

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `EMAIL_SERVICE_PORT` | Nao | `8086` | Porta HTTP do email-service. |
| `MAIL_HOST` | Sim | `localhost` | Host SMTP. |
| `MAIL_PORT` | Sim | `1025` | Porta SMTP. |
| `MAIL_USERNAME` | Conforme ambiente | vazio | Usuario SMTP. |
| `MAIL_PASSWORD` | Conforme ambiente | vazio | Senha SMTP. Nunca versionar valor real. |
| `MAIL_SMTP_AUTH` | Nao | `false` | Habilita autenticacao SMTP. |
| `MAIL_SMTP_STARTTLS` | Nao | `false` | Habilita STARTTLS no SMTP. |
| `MAIL_FROM` | Sim | `no-reply@agendahub.local` | Remetente padrao dos e-mails transacionais. |

## Frontend Ionic Angular

| Variavel | Obrigatoria | Padrao local | Descricao |
|---|---:|---|---|
| `MOBILE_API_BASE_URL` | Nao | `http://localhost:8080/api/v1` | Referencia para pipeline/deploy do app mobile. O app atual ainda usa `apps/mobile-app/src/environments/*.ts`. |

## Checklist ao adicionar variavel

- Confirmar o servico ou app dono da configuracao.
- Definir se a variavel e obrigatoria ou possui padrao seguro.
- Evitar segredo hardcoded em `application.yml`.
- Atualizar `.env.example`.
- Atualizar esta documentacao.
- Validar a subida do servico afetado.
