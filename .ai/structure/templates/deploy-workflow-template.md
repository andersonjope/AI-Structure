# Deploy Workflow: Projeto

Modelo reutilizável do pipeline de deploy (build no runner + `pull` na VPS).
As regras e o porquê de cada decisão estão em `.ai/structure/rules/deploy.md`.

## Contexto

- Projeto:
- Branch de produção:
- Registry:
- Ambiente alvo (VPS, host gerenciado, cluster):
- Serviços publicados:

## Pré-requisitos

- [ ] Workflow de CI existente e com nome estável (referenciado em `workflows: [...]`).
- [ ] `Dockerfile` por serviço, multi-stage, conforme `.ai/structure/rules/docker.md`.
- [ ] `docker-compose.prod.yml` referenciando imagens do registry, sem `build:`.
- [ ] `.env.prod.example` com todas as chaves e apenas placeholders.
- [ ] Secrets cadastrados: `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`, `DEPLOY_PORT`, `DEPLOY_PATH`.
- [ ] Usuário SSH não-root com acesso ao grupo `docker` na VPS.

## Parâmetros a substituir

| Placeholder | Descrição | Exemplo |
|---|---|---|
| `<PROJETO>` | Nome do projeto no prefixo da imagem | `app-narrota` |
| `<CI_WORKFLOW_NAME>` | Nome exato do workflow de CI | `CI` |
| `<BRANCH_PROD>` | Branch que dispara deploy | `main` |
| `<BUILD_CONTEXT>` | Raiz do build Docker | `apps/backend` |
| `<SERVICO>` / `<DOCKERFILE>` | Entradas da matriz | `identity-service` / `services/identity-service/infra/Dockerfile` |

## Workflow

```yaml
name: Deploy

# Builda as imagens Docker no runner e publica no registry. O deploy no
# servidor só faz `pull` + `up -d`, sem `--build` — o servidor nunca compila.
on:
  workflow_run:
    workflows: ["<CI_WORKFLOW_NAME>"]
    types: [completed]
    branches: [<BRANCH_PROD>]
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Tag adicional para a imagem (além de latest/sha)"
        required: false

concurrency:
  group: deploy-production
  cancel-in-progress: false

permissions:
  contents: read
  packages: write

env:
  REGISTRY: ghcr.io
  IMAGE_PREFIX: ghcr.io/${{ github.repository_owner }}/<PROJETO>

jobs:
  build-and-push:
    name: Build + push (${{ matrix.service }})
    if: ${{ github.event_name == 'workflow_dispatch' || github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - service: <SERVICO>
            dockerfile: <DOCKERFILE>
          # repetir por serviço publicado
    steps:
      - uses: actions/checkout@v4
        with:
          # em workflow_run, github.sha não é o commit validado pelo CI
          ref: ${{ github.event.workflow_run.head_sha || github.sha }}

      - name: Login no registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Configurar Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build + push da imagem
        uses: docker/build-push-action@v6
        with:
          context: <BUILD_CONTEXT>
          file: <BUILD_CONTEXT>/${{ matrix.dockerfile }}
          push: true
          tags: |
            ${{ env.IMAGE_PREFIX }}-${{ matrix.service }}:latest
            ${{ env.IMAGE_PREFIX }}-${{ matrix.service }}:${{ github.event.workflow_run.head_sha || github.sha }}
          cache-from: type=gha,scope=${{ matrix.service }}
          cache-to: type=gha,mode=max,scope=${{ matrix.service }}

  deploy:
    name: Deploy no servidor
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Pull + up via SSH (sem build)
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_SSH_KEY }}
          port: ${{ secrets.DEPLOY_PORT || 22 }}
          script: |
            set -euo pipefail
            DEPLOY_PATH="${{ secrets.DEPLOY_PATH }}"
            # Token embutido: necessário em repositório privado e sem custo em público.
            REPO_URL="https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git"

            mkdir -p "$DEPLOY_PATH"
            cd "$DEPLOY_PATH"

            if [ ! -d ".git" ]; then
              git clone --no-checkout --depth 1 --filter=blob:none "$REPO_URL" .
              git sparse-checkout init --cone
              git sparse-checkout set docker-compose.prod.yml .env.prod.example
              git checkout <BRANCH_PROD>
            else
              # GITHUB_TOKEN é efêmero por job: reescreve o remote antes do pull.
              git remote set-url origin "$REPO_URL"
              git pull --ff-only
            fi

            if [ ! -f ".env" ]; then
              echo "::warning::.env não encontrado em $DEPLOY_PATH — copiando o exemplo."
              cp .env.prod.example .env
              echo "::error::.env criado a partir do exemplo, mas ainda tem placeholders."
              echo "Edite $DEPLOY_PATH/.env no servidor com os valores reais e rode o deploy de novo."
              exit 1
            fi

            echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin
            docker compose -f docker-compose.prod.yml --env-file .env pull
            docker compose -f docker-compose.prod.yml --env-file .env up -d --remove-orphans
            docker image prune -f
```

## Validação

| Cenário | Como validar | Esperado |
|---|---|---|
| CI falhou | Quebrar um teste e dar push | Deploy não executa |
| Redeploy manual | `workflow_dispatch` | Build + deploy do HEAD da branch |
| Primeira execução na VPS | Servidor sem `.env` | Falha com erro explícito e `.env` copiado do exemplo |
| Deploy normal | Push verde na branch de produção | Containers recriados a partir do registry, sem build |
| Rollback | `docker compose` apontando para a tag `:<sha>` anterior | Versão anterior no ar |

## Riscos e pontos de atenção

- Deploy sem etapa de smoke test após `up -d` — considerar verificação de health.
- Sem estratégia de rollback automático: rollback é manual via tag de SHA.
- Janela de indisponibilidade durante `up -d` se não houver réplica.

## ADR

Registrar ADR (`.ai/structure/templates/adr-template.md`) se o projeto divergir deste
padrão — por exemplo, deploy em Kubernetes, blue/green ou registry diferente.
