# Deploy Workflow: Projeto

Modelo reutilizável do pipeline de deploy (build no runner + `pull` na VPS, com
verificação de saúde e rollback automático). As regras e o porquê de cada decisão
estão em `.ai/structure/rules/deploy.md`. Os scripts executados pelo workflow e o
runbook da VPS estão em `.ai/structure/templates/deploy-scripts-template.md`.

## Contexto

- Projeto:
- Branch de produção:
- Registry:
- Ambiente alvo (VPS, host gerenciado, cluster):
- Serviços publicados:

## Pré-requisitos

- [ ] Workflow de CI existente e com nome estável (referenciado em `workflows: [...]`). Ver `.ai/structure/templates/ci-workflow-template.md`.
- [ ] `Dockerfile` por serviço, multi-stage, conforme `.ai/structure/rules/docker.md`.
- [ ] `docker-compose.prod.yml` referenciando imagens do registry com `${IMAGE_TAG}`, sem `build:`, com `healthcheck` em cada serviço.
- [ ] `.env.prod.example` com todas as chaves e apenas placeholders (`PREENCHER`).
- [ ] Scripts `deploy-remote.sh` e `update-remote.sh` em `infra/deploy/` (ver `deploy-scripts-template.md`).
- [ ] Ambiente `production` criado no GitHub (Settings → Environments), restrito à branch de produção.
- [ ] Secrets cadastrados: `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS` e, opcionais, `DEPLOY_PORT`, `DEPLOY_PATH`, `REGISTRY_PULL_USER`, `REGISTRY_PULL_TOKEN`.
- [ ] Usuário SSH dedicado, não-root, com acesso ao grupo `docker` na VPS.

## Parâmetros a substituir

| Placeholder | Descrição | Exemplo |
|---|---|---|
| `<PROJETO>` | Nome do projeto no prefixo da imagem | `app-narrota` |
| `<CI_WORKFLOW_NAME>` | Nome exato do workflow de CI | `CI` |
| `<BRANCH_PROD>` | Branch que dispara deploy | `main` |
| `<BUILD_CONTEXT>` | Raiz do build Docker (raiz do monorepo quando o Dockerfile precisa de vários módulos) | `.` |
| `<SERVICO>` / `<DOCKERFILE>` | Entradas da matriz | `identity-service` / `services/identity-service/infra/Dockerfile` |
| `<BUILD_ARGS_POR_SERVICO>` | `build-args` específicos, quando houver | `BASE_HREF=/app/` |

## Workflow

```yaml
name: Deploy

# Builda as imagens Docker no runner e publica no registry. O deploy no servidor
# só faz `pull` + `up -d`, sem `--build` e sem código-fonte: o servidor nunca compila.
on:
  workflow_run:
    workflows: ["<CI_WORKFLOW_NAME>"]
    types: [completed]
    branches: [<BRANCH_PROD>]
  workflow_dispatch:

# Deploy é serializado e nunca cancelado no meio.
concurrency:
  group: deploy-production
  cancel-in-progress: false

permissions:
  contents: read

env:
  REGISTRY: ghcr.io
  # Commit que passou no CI; no disparo manual, o topo da branch de produção.
  COMMIT: ${{ github.event.workflow_run.head_sha || github.sha }}

jobs:
  build-and-push:
    name: Build + push (${{ matrix.service }})
    # workflow_run também dispara para pull request cujo branch de origem tem o nome
    # da branch de produção, inclusive vindo de fork: só CI verde de push neste
    # repositório publica. O disparo manual só vale na branch de produção.
    if: >-
      (github.event_name == 'workflow_dispatch' && github.ref == 'refs/heads/<BRANCH_PROD>') ||
      (github.event.workflow_run.conclusion == 'success' &&
       github.event.workflow_run.event == 'push' &&
       github.event.workflow_run.head_repository.full_name == github.repository)
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    strategy:
      matrix:
        include:
          - service: <SERVICO>
            dockerfile: <DOCKERFILE>
            build-args: ''   # <BUILD_ARGS_POR_SERVICO>
          # repetir por serviço publicado
    steps:
      - uses: actions/checkout@v4
        with:
          # em workflow_run, github.sha não é o commit validado pelo CI
          ref: ${{ env.COMMIT }}

      - name: Nome da imagem
        id: imagem
        # O GHCR exige minúsculas no nome do dono.
        run: echo "nome=${REGISTRY}/${GITHUB_REPOSITORY_OWNER,,}/<PROJETO>-${{ matrix.service }}" >> "$GITHUB_OUTPUT"

      - name: Login no registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/setup-buildx-action@v3

      - name: Build + push da imagem
        uses: docker/build-push-action@v6
        with:
          context: <BUILD_CONTEXT>
          file: ${{ matrix.dockerfile }}
          push: true
          build-args: ${{ matrix.build-args }}
          tags: |
            ${{ steps.imagem.outputs.nome }}:latest
            ${{ steps.imagem.outputs.nome }}:${{ env.COMMIT }}
          labels: |
            org.opencontainers.image.source=${{ github.server_url }}/${{ github.repository }}
            org.opencontainers.image.revision=${{ env.COMMIT }}
          cache-from: type=gha,scope=${{ matrix.service }}
          cache-to: type=gha,mode=max,scope=${{ matrix.service }}

  deploy:
    name: Deploy no servidor
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: production
    permissions:
      contents: read
      packages: read
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ env.COMMIT }}

      # SSH do próprio runner, com o host verificado: chave e token não passam por
      # ação de terceiros, e o token do registry vai só pela entrada padrão.
      - name: Pull + up no servidor via SSH (sem build)
        env:
          DEPLOY_HOST: ${{ secrets.DEPLOY_HOST }}
          DEPLOY_USER: ${{ secrets.DEPLOY_USER }}
          DEPLOY_SSH_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
          DEPLOY_KNOWN_HOSTS: ${{ secrets.DEPLOY_KNOWN_HOSTS }}
          DEPLOY_PORT: ${{ secrets.DEPLOY_PORT }}
          DEPLOY_PATH: ${{ secrets.DEPLOY_PATH }}
          # Token de leitura próprio só se o GITHUB_TOKEN não conseguir baixar o pacote na VPS.
          REGISTRY_USER: ${{ secrets.REGISTRY_PULL_USER || github.actor }}
          REGISTRY_TOKEN: ${{ secrets.REGISTRY_PULL_TOKEN || secrets.GITHUB_TOKEN }}
          IMAGE_TAG: ${{ env.COMMIT }}
        run: bash infra/deploy/deploy-remote.sh
```

## Validação

| Cenário | Como validar | Esperado |
|---|---|---|
| CI falhou | Quebrar um teste e dar push | Deploy não executa |
| PR de fork com branch `<BRANCH_PROD>` | Abrir PR cujo branch de origem tem esse nome | `build-and-push` ignorado (`event != push` / repositório diferente) |
| Disparo manual fora da branch de produção | `workflow_dispatch` em outra branch | `build-and-push` ignorado |
| Redeploy manual | `workflow_dispatch` na branch de produção | Build + deploy do HEAD da branch |
| Primeira execução na VPS | Servidor sem `.env` | Falha com erro explícito, `.env` criado a partir do exemplo com `chmod 600` |
| `.env` com `PREENCHER` | Deixar um placeholder | Falha listando as chaves pendentes |
| Deploy normal | Push verde na branch de produção | Containers recriados a partir do registry, aguardam `healthy`, `.versao-atual` atualizado |
| Versão nova não fica saudável | Subir imagem com health check quebrado | Job falha após o tempo limite e a versão anterior volta |
| Host SSH divergente | Alterar `DEPLOY_KNOWN_HOSTS` | Conexão recusada antes de enviar o token |

## Riscos e pontos de atenção

- Rollback automático volta imagens, **não desfaz migração de dados**. Migração destrutiva
  não roda no deploy: executar manualmente, uma vez, conforme o runbook.
- Janela de indisponibilidade durante `up -d` se não houver réplica.
- Backup do banco não faz parte deste fluxo: tratar à parte.
- A VPS guarda só a versão atual, a anterior e a `latest`; rollback para commit mais antigo exige novo `pull`.
- `GITHUB_TOKEN` do job pode não ter permissão de leitura do pacote na VPS (pacote privado em
  outro escopo): usar `REGISTRY_PULL_TOKEN` com `read:packages`.

## ADR

Registrar ADR (`.ai/structure/templates/adr-template.md`) se o projeto divergir deste
padrão — por exemplo, deploy em Kubernetes, blue/green ou registry diferente.
