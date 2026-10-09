# Dependency Audit Workflow: Projeto

Modelo reutilizável da auditoria periódica de dependências vulneráveis. As regras
estão em `.ai/structure/rules/ci.md` (seção "Auditoria de dependências") e em
`.ai/structure/rules/security.md`.

## Contexto

- Projeto:
- Ecossistemas auditados (npm/pnpm, Maven, Gradle, pip):
- Gravidade que falha o pipeline (padrão: `high`):
- Quem faz a triagem dos alertas moderados e baixos:

## Por que existe um workflow separado

Alertas novos surgem **sem mudança no código**: uma CVE publicada hoje afeta um
lockfile que não mudou há semanas. Por isso a auditoria roda em três situações —
mudança nas dependências, agenda semanal e disparo manual — e não faz parte do CI
principal, que só dispara com mudança de código.

## Parâmetros a substituir

| Placeholder | Descrição | Exemplo |
|---|---|---|
| `<ARQUIVOS_DE_DEPENDENCIA>` | Paths que disparam a auditoria | `pnpm-lock.yaml`, `**/package.json`, `**/pom.xml` |
| `<SETUP_RUNTIME>` | Setup do runtime do ecossistema | `pnpm/action-setup@v4` + `actions/setup-node@v4` |
| `<CMD_AUDIT>` | Comando de auditoria com limite de gravidade | `pnpm audit --audit-level=high` |
| `<CRON>` | Agenda semanal (UTC) | `0 9 * * 1` (segunda, 09:00) |

## Workflow

```yaml
name: Auditoria de dependências

# Alertas novos surgem sem mudança no código, então além de mudanças nas
# dependências roda toda semana. Falha a partir da gravidade alta; moderados e
# baixos aparecem no log para triagem.
on:
  push:
    branches: [<BRANCH_PROD>]
    paths: &deps
      - '<ARQUIVOS_DE_DEPENDENCIA>'
      - '.github/workflows/dependency-audit.yml'
  pull_request:
    paths: *deps
  schedule:
    - cron: '<CRON>'
  workflow_dispatch:

permissions:
  contents: read

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # <SETUP_RUNTIME>
      - run: <CMD_AUDIT>
```

### Equivalentes por ecossistema

| Ecossistema | `<CMD_AUDIT>` |
|---|---|
| pnpm | `pnpm audit --audit-level=high` |
| npm | `npm audit --audit-level=high` |
| Maven | `mvn -B org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7` |
| Gradle | plugin `org.owasp.dependencycheck` com `failBuildOnCVSS = 7` |

Para projetos com mais de um ecossistema (ex.: backend Java e app Ionic), usar um job
por ecossistema no mesmo workflow.

## Tratamento de alertas

| Gravidade | Ação |
|---|---|
| Crítica / alta | Pipeline falha; corrigir (atualizar, trocar ou substituir a dependência) antes de seguir |
| Moderada / baixa | Aparecem no log; triar em até uma semana e registrar a decisão |
| Falso positivo ou sem correção disponível | Registrar exceção com justificativa, prazo de revisão e responsável (ADR ou relatório de auditoria) |

Não silenciar alerta (`--ignore`, `suppression`) sem registro da exceção.

## Validação

| Cenário | Como validar | Esperado |
|---|---|---|
| Execução manual | `workflow_dispatch` | Job roda e lista alertas por gravidade |
| Agenda | Aguardar o cron | Execução semanal sem mudança de código |
| Dependência vulnerável | Fixar versão com CVE alta em branch descartável | Job falha |
| Mudança em código sem dependência | PR sem tocar lockfile | Workflow não dispara |

## Riscos e pontos de atenção

- Falha agendada não tem PR por trás: definir quem recebe a notificação do workflow.
- Auditoria só vê o que a base pública conhece; não substitui revisão de segurança.
- Atualizações automáticas (Dependabot/Renovate) são complementares, não substitutas.

## ADR

Registrar ADR (`.ai/structure/templates/adr-template.md`) ao mudar o limite de
gravidade, adotar ferramenta diferente ou aceitar exceção de longa duração.
