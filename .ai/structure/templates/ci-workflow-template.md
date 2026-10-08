# CI Workflow: Projeto

Modelo reutilizável do pipeline de integração contínua (lint, build, testes com
cobertura mínima e build de imagem em PR). As regras e o porquê de cada decisão
estão em `.ai/structure/rules/ci.md`. O deploy encadeado a este workflow está em
`.ai/structure/templates/deploy-workflow-template.md`.

## Contexto

- Projeto:
- Branch de produção:
- Gerenciador de pacotes / build (Maven, Gradle, pnpm, npm):
- Módulos ou apps validados (um job por módulo):
- Serviços com imagem Docker (validados em PR):

## Pré-requisitos

- [ ] Comandos de lint, build e teste executáveis por linha de comando em cada módulo.
- [ ] Limite mínimo de cobertura configurado na própria ferramenta de teste (ver "Cobertura").
- [ ] Lockfile versionado (`pnpm-lock.yaml`, `package-lock.json`) ou versões fixadas no build.
- [ ] `Dockerfile` por serviço, conforme `.ai/structure/rules/docker.md`.
- [ ] Nome do workflow estável: o deploy o referencia em `workflows: ["<CI_WORKFLOW_NAME>"]`.

## Parâmetros a substituir

| Placeholder | Descrição | Exemplo |
|---|---|---|
| `<CI_WORKFLOW_NAME>` | Nome exato do workflow (usado pelo deploy) | `CI` |
| `<BRANCH_PROD>` | Branch de produção | `main` |
| `<MODULO>` | Nome do job por módulo | `backend`, `frontend`, `identity-service` |
| `<SETUP_RUNTIME>` | Steps de setup do runtime e cache | `actions/setup-java@v4` ou `actions/setup-node@v4` |
| `<CMD_LINT>` / `<CMD_BUILD>` / `<CMD_TEST_COV>` | Comandos do módulo | `mvn -B verify` / `pnpm --filter x test:cov` |
| `<COVERAGE_DIR>` | Pasta do relatório de cobertura | `target/site/jacoco/`, `coverage/` |
| `<SERVICO>` / `<DOCKERFILE>` / `<BUILD_CONTEXT>` | Entradas da matriz de imagens | ver `deploy-workflow-template.md` |

## Workflow

```yaml
name: <CI_WORKFLOW_NAME>

# Push só na branch de produção: nas demais, o pull_request já cobre, e push + PR
# rodariam tudo duas vezes. Mudança só de documentação não dispara CI (e, na
# branch de produção, também não gera deploy, que depende deste workflow).
on:
  push:
    branches: [<BRANCH_PROD>]
    paths-ignore: &docs
      - 'docs/**'
      - '.ai/**'
      - '**/*.md'
  pull_request:
    paths-ignore: *docs

# Push novo no mesmo PR cancela a execução anterior. Na branch de produção nada
# é cancelado: cada commit precisa concluir o CI para ser publicado pelo deploy.
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/<BRANCH_PROD>' }}

permissions:
  contents: read

jobs:
  # Repetir este job por módulo (backend, frontend, cada microservice).
  <MODULO>:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # <SETUP_RUNTIME>: instalar o runtime com cache de dependências
      #   Node/pnpm: pnpm/action-setup@v4 + actions/setup-node@v4 (cache: 'pnpm')
      #   Java/Maven: actions/setup-java@v4 (distribution: temurin, java-version: 21, cache: maven)
      - run: <CMD_LINT>
      - run: <CMD_BUILD>
      # Unitários e integração numa execução só, com cobertura combinada e limite
      # mínimo configurado na ferramenta: a execução falha se a cobertura cair.
      - run: <CMD_TEST_COV>
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: cobertura-<MODULO>
          path: <COVERAGE_DIR>
          if-no-files-found: ignore

  # Só no PR: na branch de produção o deploy já builda as mesmas imagens. Mesmos
  # build-args e escopos de cache do deploy.yml, só com leitura, para reaproveitar
  # as camadas e antecipar falha de Dockerfile antes do merge.
  docker-build:
    name: Docker build (${{ matrix.service }})
    if: github.event_name == 'pull_request'
    needs: [<MODULO>]   # listar todos os jobs de módulo
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - service: <SERVICO>
            dockerfile: <DOCKERFILE>
            build-args: ''
          # repetir por serviço com imagem
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          context: <BUILD_CONTEXT>
          file: ${{ matrix.dockerfile }}
          push: false
          build-args: ${{ matrix.build-args }}
          cache-from: type=gha,scope=${{ matrix.service }}
```

## Cobertura

O limite mínimo vive na configuração da ferramenta de teste, não no YAML — assim
falha igual localmente e no CI:

| Stack | Onde configurar |
|---|---|
| Java (JaCoCo) | `jacoco:check` com `<rule>` de `LINE`/`BRANCH` `COVEREDRATIO` mínimo, na fase `verify` |
| Jest | `coverageThreshold` global em `jest.config.js` ou `jest.coverage.config.js` |
| Karma/Angular | `coverageReporter.check.global` em `karma.conf.js` |

Começar no nível real do projeto e subir por etapas; nunca baixar o limite para
fazer o pipeline passar (ver `.ai/structure/rules/testing.md`).

## Validação

| Cenário | Como validar | Esperado |
|---|---|---|
| Mudança só em `docs/` ou `*.md` | PR alterando apenas Markdown | CI não dispara |
| Push novo no mesmo PR | Dois pushes seguidos | Execução anterior cancelada |
| Push em `<BRANCH_PROD>` | Dois commits seguidos | Nenhuma execução cancelada |
| Teste quebrado | Falhar um teste | Job do módulo falha e o deploy não executa |
| Cobertura abaixo do limite | Remover testes de um módulo em branch descartável | Job falha na etapa de cobertura |
| Dockerfile quebrado | Quebrar um `COPY` em PR | Job `docker-build` falha antes do merge |

## Riscos e pontos de atenção

- `paths-ignore` no CI impede o deploy em commits só de documentação: intencional, mas
  precisa estar documentado para quem espera deploy após editar um `.md`.
- Matriz de `docker-build` e matriz de `build-and-push` do deploy devem ficar
  sincronizadas (mesmos serviços, `build-args` e escopos de cache).
- Se o projeto exigir check obrigatório em branch protegida, o nome do job é o nome
  do check: trocar o nome do job exige atualizar a regra de proteção.

## ADR

Registrar ADR (`.ai/structure/templates/adr-template.md`) se o projeto divergir
deste padrão, por exemplo trocando de provedor de CI ou dispensando o gate de cobertura.
