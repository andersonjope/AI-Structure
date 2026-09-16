# Deploy Rules

## Agente responsável

`devops-engineer` → `security-reviewer` → `observability-engineer`

Este repositório-base é genérico e não versiona um workflow de deploy real.
Modelo reutilizável, pronto para copiar e adaptar por projeto: `.ai/structure/templates/deploy-workflow-template.md`.
Ao adotar este pipeline em um projeto real, versionar o resultado em `.github/workflows/deploy.yml`.

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
- Só executa quando a conclusão do CI for `success` e na branch de produção (`main`).
- Manter também `workflow_dispatch` para redeploy manual sem novo commit.

```yaml
on:
  workflow_run:
    workflows: ["CI"]
    types: [completed]
    branches: [main]
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Tag adicional para a imagem (além de latest/sha)"
        required: false
```

```yaml
jobs:
  build-and-push:
    if: ${{ github.event_name == 'workflow_dispatch' || github.event.workflow_run.conclusion == 'success' }}
```

O `if` é obrigatório: `workflow_run` dispara também em falha e cancelamento do CI.

### Checkout do commit certo

Em `workflow_run`, `github.sha` aponta para o último commit da branch padrão no momento
do disparo, não necessariamente o commit que passou no CI. Usar sempre:

```yaml
- uses: actions/checkout@v4
  with:
    ref: ${{ github.event.workflow_run.head_sha || github.sha }}
```

O mesmo valor deve ser usado na tag de imagem por SHA.

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
  contents: read
  packages: write
```

- `packages: write` só é necessário no job que publica no registry.
- Nunca usar `permissions: write-all`.

---

## Registry e tags de imagem

- Registry padrão: GHCR (`ghcr.io`), autenticado com o `GITHUB_TOKEN` efêmero do job.
- Prefixo derivado do owner do repositório, sem hardcode de organização:

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_PREFIX: ghcr.io/${{ github.repository_owner }}/<projeto>
```

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

O job de deploy depende do build (`needs: build-and-push`) e roda um script idempotente.

### Sparse-checkout dos arquivos de orquestração

A VPS só precisa do compose de produção e do exemplo de env — não do código fonte:

```bash
git clone --no-checkout --depth 1 --filter=blob:none "$REPO_URL" .
git sparse-checkout init --cone
git sparse-checkout set docker-compose.prod.yml .env.prod.example
git checkout main
```

Execuções seguintes fazem apenas `git pull --ff-only`.

### Token efêmero no remote

`GITHUB_TOKEN` expira ao fim do job. Em repositório privado, o `pull` da próxima execução
falha se o remote guardar o token antigo — por isso o remote é reescrito a cada deploy:

```bash
REPO_URL="https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git"
git remote set-url origin "$REPO_URL"
```

### Falhar quando o `.env` não existe

O `.env` de produção **não é versionado** e nunca é gerado com valores reais pelo pipeline.
Na primeira execução, o script copia o exemplo e **falha explicitamente**, exigindo
preenchimento manual na VPS:

```bash
if [ ! -f ".env" ]; then
  cp .env.prod.example .env
  echo "::error::.env criado a partir do exemplo, mas ainda tem valores de placeholder."
  exit 1
fi
```

Subir com placeholders é pior que falhar: o serviço sobe quebrado ou com segredo fraco.

### Sequência final

```bash
set -euo pipefail
echo "$TOKEN" | docker login ghcr.io -u "$ACTOR" --password-stdin
docker compose -f docker-compose.prod.yml --env-file .env pull
docker compose -f docker-compose.prod.yml --env-file .env up -d --remove-orphans
docker image prune -f
```

- `set -euo pipefail` obrigatório: sem ele, um passo que falha não aborta o deploy.
- `--remove-orphans` remove containers de serviços retirados do compose.
- `docker image prune -f` evita encher o disco da VPS com imagens antigas.

---

## Segredos obrigatórios

| Secret | Descrição |
|---|---|
| `DEPLOY_HOST` | Host/IP da VPS |
| `DEPLOY_USER` | Usuário SSH (não-root, com acesso ao grupo `docker`) |
| `DEPLOY_SSH_KEY` | Chave privada SSH dedicada ao deploy |
| `DEPLOY_PORT` | Porta SSH (default `22` via `${{ secrets.DEPLOY_PORT || 22 }}`) |
| `DEPLOY_PATH` | Diretório na VPS com o compose de produção |
| `GITHUB_TOKEN` | Fornecido pelo runner — não criar manualmente |

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
- Cancelar deploy em andamento (`cancel-in-progress: true`).
- Hardcode de owner, organização, host ou caminho no workflow.
- Cache de Buildx compartilhado entre serviços diferentes.

---

## Checklist de adoção em outro projeto

1. Ajustar `IMAGE_PREFIX` para o nome do projeto (o owner vem de `github.repository_owner`).
2. Ajustar a matriz `service`/`dockerfile` para os serviços reais.
3. Ajustar `context` do build para a raiz correta do monorepo.
4. Garantir que o workflow de CI se chama exatamente o que está em `workflows: ["CI"]`.
5. Criar `docker-compose.prod.yml` referenciando as imagens do registry (sem `build:`).
6. Criar `.env.prod.example` com todas as chaves e apenas placeholders.
7. Cadastrar os secrets da tabela acima.
8. Validar com `workflow_dispatch` antes de depender do encadeamento automático.
9. Registrar ADR se a estratégia de deploy divergir deste padrão
   (`.ai/structure/templates/adr-template.md`).

---

## Referências cruzadas

- `.ai/structure/rules/docker.md` — imagem, multi-stage, build context, `.dockerignore`.
- `.ai/structure/rules/security.md` — segredos e menor privilégio.
- `.ai/structure/rules/observability.md` — health checks e logs após o deploy.
- `.ai/structure/rules/git-workflow.md` — branch de produção e commits de infra.
