# CI Rules

## Agente responsável

`devops-engineer` → `security-reviewer` → `observability-engineer`

Este repositório-base é genérico e não versiona workflows reais de CI.
Modelos reutilizáveis, prontos para copiar e adaptar por projeto:

- `.ai/structure/templates/ci-workflow-template.md`
- `.ai/structure/templates/dependency-audit-workflow-template.md`

Ao adotar o pipeline em um projeto real, versionar o resultado em
`.github/workflows/ci.yml` e `.github/workflows/dependency-audit.yml`.
O deploy encadeado ao CI está em `.ai/structure/rules/deploy.md`.

---

## Princípios

- O CI é o único portão para produção: o deploy só executa quando o CI de um push na branch de produção termina com sucesso.
- O mesmo comando roda local e no CI. Lint, build e testes vivem em scripts do projeto (`package.json`, Maven, Gradle), não em lógica solta no YAML.
- Falha rápida e barata: lint e build antes dos testes; build de imagem só onde agrega valor.
- Nunca remover, pular ou enfraquecer teste, lint ou gate de cobertura para o pipeline passar.

---

## Gatilhos

| Evento | Regra |
|---|---|
| `push` | Somente na branch de produção. Nas demais, o `pull_request` já cobre; `push` + PR rodariam tudo duas vezes |
| `pull_request` | Sempre, para qualquer branch de origem |
| `paths-ignore` | `docs/**`, `.ai/**` e `**/*.md` não disparam CI |

Consequência do `paths-ignore`: commit só de documentação na branch de produção não gera
deploy, porque o deploy depende do CI. É intencional e deve estar documentado no projeto.

O workflow de validação da governança (`validate-ai-structure.yml`) cobre `.ai/**` e os
arquivos de entrada de IA; ele não é substituído pelo CI de código.

---

## Concorrência

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
```

- Em PR, um push novo cancela a execução anterior (economia de runner).
- Na branch de produção **nada é cancelado**: cada commit precisa concluir o CI para poder ser publicado pelo deploy.

---

## Estrutura de jobs

- Um job por módulo implantável (backend, frontend, cada microservice), em paralelo.
- Ordem dentro do job: instalar dependências com lockfile congelado → lint → build → testes com cobertura.
- Instalação reproduzível: `pnpm install --frozen-lockfile`, `npm ci`, ou Maven/Gradle com versões fixadas. Nunca `install` que reescreve o lockfile.
- Cache de dependências pelo `setup-*` oficial do runtime, não por cache manual.
- `permissions: contents: read` no topo; elevar por job apenas quando necessário.
- Ações fixadas em major version (`@v4`), nunca `@main`.
- Nome do workflow estável: o deploy o referencia por nome em `workflow_run`.

---

## Cobertura mínima como gate

- O limite mínimo fica na configuração da ferramenta de teste (JaCoCo `check`, `coverageThreshold` do Jest, `check.global` do Karma), para falhar igual local e no CI.
- Unitários e integração rodam numa execução com cobertura combinada.
- Começar no nível real do projeto e subir por etapas; o limite só sobe.
- Relatório de cobertura publicado como artefato com `if: always()`, para diagnosticar falha.
- Baixar o limite exige justificativa registrada (relatório de auditoria ou ADR), nunca ajuste silencioso no PR.

Ver `.ai/structure/rules/testing.md` e `.ai/structure/rules/tdd.md`.

---

## Build de imagem em PR

- O job `docker-build` roda **só em PR** e com `push: false`: antecipa falha de Dockerfile e de contexto antes do merge.
- Na branch de produção o deploy já builda as mesmas imagens; repetir no CI duplicaria custo.
- Usar os mesmos `build-args` e o mesmo escopo de cache (`scope=${{ matrix.service }}`) do deploy, em modo leitura, para reaproveitar camadas.
- A matriz do CI e a do deploy devem permanecer sincronizadas.

Ver `.ai/structure/rules/docker.md`.

---

## Auditoria de dependências

- Workflow próprio (`dependency-audit.yml`), disparado por mudança em lockfile/manifestos, por agenda semanal e por `workflow_dispatch`. Alertas novos surgem sem mudança no código.
- Falha a partir da gravidade **alta**; moderados e baixos aparecem no log para triagem.
- Alerta sem correção disponível vira exceção registrada com justificativa, responsável e prazo de revisão. Não silenciar sem registro.
- Dependabot/Renovate complementam, não substituem.

Ver `.ai/structure/rules/security.md`.

---

## Proibições

- Deploy disparado por `push` ignorando o resultado do CI.
- Remover ou comentar teste, lint ou gate de cobertura para o pipeline passar.
- `cancel-in-progress: true` na branch de produção.
- Instalar dependências sem lockfile congelado.
- Segredos em texto claro no workflow ou impressos em log.
- Ações de terceiros sem versão fixada, ou `permissions: write-all`.
- Silenciar alerta de dependência sem exceção registrada.

---

## Checklist de adoção em outro projeto

1. Copiar `ci-workflow-template.md` para `.github/workflows/ci.yml` e substituir os placeholders.
2. Confirmar que cada módulo tem scripts de lint, build e teste com cobertura e limite mínimo na ferramenta.
3. Criar um job por módulo e uma entrada de matriz `docker-build` por serviço com imagem.
4. Copiar `dependency-audit-workflow-template.md` para `.github/workflows/dependency-audit.yml` e escolher o comando do ecossistema.
5. Garantir que o `name:` do workflow de CI é o mesmo referenciado em `workflows:` do deploy.
6. Marcar os jobs de CI como checks obrigatórios na proteção da branch de produção.
7. Registrar ADR se divergir (outro provedor de CI, sem gate de cobertura, sem auditoria).

---

## Referências cruzadas

- `.ai/structure/rules/deploy.md` — deploy encadeado ao CI.
- `.ai/structure/rules/docker.md` — imagem, multi-stage, build context.
- `.ai/structure/rules/testing.md` e `.ai/structure/rules/tdd.md` — pirâmide de testes e cobertura.
- `.ai/structure/rules/security.md` — dependências e segredos.
- `.ai/structure/rules/git-workflow.md` — branches e PRs.
