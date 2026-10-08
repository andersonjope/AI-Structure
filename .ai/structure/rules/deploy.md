# Deploy Rules

## Agente responsável

`devops-engineer` → `security-reviewer` → `observability-engineer`

Este repositório-base é genérico e não versiona um workflow de deploy real.
Modelos reutilizáveis, prontos para copiar e adaptar por projeto:

- `.ai/structure/templates/deploy-workflow-template.md` — workflow `deploy.yml`.
- `.ai/structure/templates/deploy-scripts-template.md` — scripts `deploy-remote.sh`/`update-remote.sh` e runbook `infra/deploy/README.md`.

Ao adotar este pipeline em um projeto real, versionar o resultado em `.github/workflows/deploy.yml` e `infra/deploy/`.
O CI ao qual o deploy se encadeia está em `.ai/structure/rules/ci.md`.

---

## Princípio central: build no runner, VPS só puxa imagem

O servidor de produção **nunca compila** código. O pipeline separa dois papéis:

| Etapa | Onde roda | O que faz |
|---|---|---|
| Build + push | Runner do CI (GitHub Actions) | Compila, gera a imagem Docker e publica no registry |
| Deploy | VPS via SSH | `docker compose pull` + `up -d`, sem `--build` |

Motivos:

- VPS pequena não tem CPU nem RAM para build Java/Maven ou bundle Angular.
- Build no runner é reproduzível, cacheável e não derruba o ambiente em produção.
- O que vai para produção é exatamente o artefato validado pelo CI, não uma recompilação.

**Proibido** usar `docker compose up --build` no servidor de produção.

---

## Gatilho do deploy

- O deploy é encadeado ao workflow de CI via `workflow_run`, não ao `push`.
- Só executa quando o CI terminou com `success`, **foi disparado por `push`** e o repositório de origem é o próprio repositório.
- Manter também `workflow_dispatch` para redeploy manual sem novo commit, válido apenas na branch de produção.

```yaml
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [main]
  workflow_dispatch:
```

```yaml
jobs:
  build-and-push:
    if: >-
      (github.event_name == 'workflow_dispatch' && github.ref == 'refs/heads/main') ||
      (github.event.workflow_run.conclusion == 'success' &&
       github.event.workflow_run.event == 'push' &&
       github.event.workflow_run.head_repository.full_name == github.repository)
```

O `if` é obrigatório e tem três motivos:

- `workflow_run` dispara também em falha e cancelamento do CI (`conclusion == 'success'`).
- `workflow_run` dispara também para pull request cujo branch de origem tem o nome da branch de produção, inclusive vindo de fork (`event == 'push'` e `head_repository`). Sem isso, código de terceiros seria publicado.
- O botão manual rodando em outra branch publicaria código não revisado (`github.ref`).

### Checkout do commit certo

Em `workflow_run`, `github.sha` aponta para o último commit da branch padrão no momento
do disparo, não necessariamente o commit que passou no CI. Usar sempre:

```yaml
- uses: actions/checkout@v4
  with:
    ref: ${{ github.event.workflow_run.head_sha || github.sha }}
```

O mesmo valor deve ser usado na tag de imagem por SHA. Centralizar em `env.COMMIT`:

```yaml
env:
  COMMIT: ${{ github.event.workflow_run.head_sha || github.sha }}
```

---

## Concorrência

Deploy de produção é serializado e **não** pode ser cancelado no meio:

```yaml
concurrency:
  group: deploy-production
  cancel-in-progress: false
```

`cancel-in-progress: true` em deploy pode interromper um `docker compose up` parcial e
deixar o ambiente inconsistente.

---

## Permissões do token

Princípio de menor privilégio, declarado explicitamente no workflow:

```yaml
permissions:
  contents: read          # nível do workflow

jobs:
  build-and-push:
    permissions: { contents: read, packages: write }
  deploy:
    permissions: { contents: read, packages: read }
```

- `packages: write` só no job que publica no registry; o job de deploy só lê.
- Nunca usar `permissions: write-all`.

---

## Registry e tags de imagem

- Registry padrão: GHCR (`ghcr.io`), autenticado com o `GITHUB_TOKEN` efêmero do job.
- Prefixo derivado do owner do repositório, sem hardcode de organização. O GHCR exige o nome do dono em **minúsculas**:

```yaml
- name: Nome da imagem
  id: imagem
  run: echo "nome=${REGISTRY}/${GITHUB_REPOSITORY_OWNER,,}/<projeto>-${{ matrix.service }}" >> "$GITHUB_OUTPUT"
```
- Imagens com `labels` OCI `org.opencontainers.image.source` e `org.opencontainers.image.revision` (vínculo com o repositório e o commit).

- Toda imagem recebe **duas** tags obrigatórias:

| Tag | Uso |
|---|---|
| `:latest` | O que o compose de produção referencia |
| `:<sha>` | Rastreabilidade e rollback para um commit específico |

`:latest` sozinho impede identificar o que está rodando e inviabiliza rollback.

---

## Build multi-serviço por matriz

Um job por serviço, em paralelo, declarado por matriz — não duplicar steps:

```yaml
strategy:
  matrix:
    include:
      - service: identity-service
        dockerfile: services/identity-service/infra/Dockerfile
      - service: api-gateway
        dockerfile: platform/api-gateway/infra/Dockerfile
```

Regras:

- `build-args` específicos de um serviço entram na própria entrada da matriz (ex.: `BASE_HREF` só no frontend); passar argumento inexistente a outro serviço só gera aviso.
- `context` deve apontar para a raiz que dá acesso aos módulos do monorepo
  (ver `.ai/structure/rules/docker.md` > build context), não para a pasta do Dockerfile.
- Cache do Buildx **escopado por serviço**, senão os serviços invalidam o cache uns dos outros:

```yaml
cache-from: type=gha,scope=${{ matrix.service }}
cache-to: type=gha,mode=max,scope=${{ matrix.service }}
```

- Ações fixadas em major version (`docker/build-push-action@v6`, `docker/login-action@v3`,
  `actions/checkout@v4`) — não usar `@main`.

---

## Deploy na VPS via SSH

O job de deploy depende do build (`needs: build-and-push`), usa `environment: production`
(com revisão e restrição à branch de produção quando o time exigir) e executa scripts
versionados em `infra/deploy/` — não um bloco de shell embutido no YAML.

Modelos dos scripts: `.ai/structure/templates/deploy-scripts-template.md`.

### Sem ação de terceiros e sem clone na VPS

- O SSH é feito pelo próprio runner (`ssh`), não por ação de terceiros: chave e token do registry não passam por código externo.
- A VPS **não clona o repositório**. O deploy envia por SSH apenas `docker-compose.prod.yml` e `.env.prod.example`; nenhum código-fonte chega ao servidor e não há token de repositório guardado em `remote`.

### Host SSH verificado

`DEPLOY_KNOWN_HOSTS` é obrigatório e a conexão usa `StrictHostKeyChecking=yes`. Sem host conhecido, um servidor no meio do caminho receberia o token do registry. Gerar com `ssh-keyscan` e conferir a impressão digital com a da VPS.

### Token do registry só pela entrada padrão

```bash
printf '%s' "$REGISTRY_TOKEN" | ssh_vps "docker login ghcr.io -u $USER --password-stdin"
```

- Nunca em argumento de comando, nunca gravado em arquivo na VPS.
- `docker logout` ao final (`trap ... EXIT`).
- Token de leitura próprio (`REGISTRY_PULL_TOKEN`, `read:packages`) só quando o `GITHUB_TOKEN` do job não consegue baixar o pacote.

### Falhar quando o `.env` não existe ou tem placeholder

O `.env` de produção **não é versionado** e nunca é gerado com valores reais pelo pipeline.
Na primeira execução, o script copia o exemplo com `chmod 600` e **falha explicitamente**.
Nas seguintes, falha listando as chaves ainda com `PREENCHER`:

```bash
if [[ ! -f .env ]]; then
  cp .env.prod.example .env; chmod 600 .env
  echo "::error::.env criado a partir do exemplo. Preencha os valores reais e rode o deploy de novo." >&2
  exit 1
fi
pendentes="$(grep -E '^[A-Z_]+=PREENCHER' .env | cut -d= -f1 | paste -sd ' ' - || true)"
[[ -z "$pendentes" ]] || { echo "::error::Preencha: $pendentes" >&2; exit 1; }
```

Subir com placeholders é pior que falhar: o serviço sobe quebrado ou com segredo fraco.
O deploy nunca edita o `.env`; valores por versão (tag, registry, prefixos de rota) vão pelo ambiente do comando (`env IMAGE_TAG=... docker compose ...`).

### Saúde e rollback automático

Depois do `up -d`, o script espera os serviços ficarem `healthy` (padrão 180 s):

- Todos saudáveis → grava o commit em `.versao-atual` e limpa imagens antigas, mantendo **a atual, a anterior e a `latest`**.
- Algum não saudável → imprime `ps` e as últimas linhas de log, **volta para a versão registrada em `.versao-atual`** e termina com erro (o job falha).
- Sem versão anterior (primeiro deploy), apenas falha, sem rollback.

Todo serviço do compose de produção precisa de `healthcheck` (ver `.ai/structure/rules/observability.md`).
Rollback restaura imagens, **não desfaz migração de dados**.

### Sequência final

```bash
set -euo pipefail
compose "$tag" pull
compose "$tag" up -d --remove-orphans
```

- `set -euo pipefail` obrigatório: sem ele, um passo que falha não aborta o deploy.
- `--remove-orphans` remove containers de serviços retirados do compose.
- Limpeza de imagens antigas só depois de confirmar saúde, para não perder a imagem do rollback.

### Migrações de dados

Não rodam no deploy. Migração destrutiva ou que mexe em dados existentes é executada manualmente,
uma vez, na ordem documentada no runbook (`infra/deploy/README.md`), e deve ser idempotente quando possível.

---

## Segredos obrigatórios

| Secret | Descrição |
|---|---|
| `DEPLOY_HOST` | Host/IP da VPS |
| `DEPLOY_USER` | Usuário SSH (não-root, com acesso ao grupo `docker`) |
| `DEPLOY_SSH_KEY` | Chave privada SSH dedicada ao deploy (ed25519) |
| `DEPLOY_KNOWN_HOSTS` | Saída de `ssh-keyscan -p <porta> <host>`, conferida com a impressão digital da VPS |
| `DEPLOY_PORT` | Opcional; padrão `22` |
| `DEPLOY_PATH` | Opcional; diretório na VPS com o compose de produção |
| `REGISTRY_PULL_USER` / `REGISTRY_PULL_TOKEN` | Opcionais: token com `read:packages`, se o `GITHUB_TOKEN` não baixar o pacote na VPS |
| `GITHUB_TOKEN` | Fornecido pelo runner — não criar manualmente |

Cadastrar os secrets no **ambiente** `production` (Settings → Environments), restrito à branch de produção.
Sem os obrigatórios, o job falha listando o que falta, antes de abrir conexão SSH.

Regras:

- Nenhum host, caminho, usuário ou credencial em texto claro no workflow.
- Chave SSH exclusiva para deploy, com acesso mínimo — não reutilizar chave pessoal.
- Segredo de aplicação vive no `.env` da VPS, não no workflow.

---

## Proibições

- Compilar na VPS (`up --build`, `mvn package`, `npm run build` no servidor).
- Publicar imagem sem tag de SHA.
- Versionar `.env` de produção ou gerar valores reais de segredo no pipeline.
- Usar `push` direto como gatilho de deploy, ignorando o resultado do CI.
- Publicar a partir de `workflow_run` sem checar `event == 'push'` e o repositório de origem (PR e fork).
- Conectar por SSH sem `DEPLOY_KNOWN_HOSTS` (`StrictHostKeyChecking=no`) ou usar ação de terceiros para SSH com a chave de deploy.
- Passar token do registry por argumento de comando ou deixá-lo gravado na VPS.
- Clonar o repositório na VPS ou guardar token de repositório no `remote`.
- Remover imagens antigas antes de confirmar a saúde da nova versão.
- Cancelar deploy em andamento (`cancel-in-progress: true`).
- Hardcode de owner, organização, host ou caminho no workflow.
- Cache de Buildx compartilhado entre serviços diferentes.

---

## Checklist de adoção em outro projeto

1. Ajustar `IMAGE_PREFIX` para o nome do projeto (o owner vem de `github.repository_owner`).
2. Ajustar a matriz `service`/`dockerfile` para os serviços reais.
3. Ajustar `context` do build para a raiz correta do monorepo.
4. Garantir que o workflow de CI se chama exatamente o que está em `workflows: ["CI"]`.
5. Criar `docker-compose.prod.yml` referenciando as imagens do registry com `${IMAGE_TAG}` (sem `build:`) e `healthcheck` em cada serviço.
6. Criar `.env.prod.example` com todas as chaves e apenas placeholders `PREENCHER`.
7. Copiar `deploy-remote.sh`/`update-remote.sh` e o runbook de `deploy-scripts-template.md` para `infra/deploy/`.
8. Criar o ambiente `production` e cadastrar os secrets da tabela acima nele.
9. Validar com `workflow_dispatch` na branch de produção antes de depender do encadeamento automático, incluindo um deploy com health check quebrado para exercitar o rollback.
10. Registrar ADR se a estratégia de deploy divergir deste padrão
   (`.ai/structure/templates/adr-template.md`).

---

## Referências cruzadas

- `.ai/structure/rules/ci.md` — CI ao qual o deploy se encadeia, cobertura e auditoria de dependências.
- `.ai/structure/rules/docker.md` — imagem, multi-stage, build context, `.dockerignore`.
- `.ai/structure/rules/security.md` — segredos e menor privilégio.
- `.ai/structure/rules/observability.md` — health checks e logs após o deploy.
- `.ai/structure/rules/git-workflow.md` — branch de produção e commits de infra.
