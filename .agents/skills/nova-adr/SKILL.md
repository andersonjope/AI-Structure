---
name: nova-adr
description: Cria uma nova ADR (Architecture Decision Record) numerada em .ai/context/architecture-decision-records/. Usar quando houver decisão arquitetural, de segurança ou de plataforma com alternativas descartadas, ou quando o usuário pedir uma ADR.
---

# Nova ADR

Fonte: `.ai/structure/templates/adr-template.md`. Regras de documentação: `.ai/structure/rules/documentation.md`.

## Passos

1. Listar `.ai/context/architecture-decision-records/` e ler as ADRs relacionadas ao assunto. Se uma existente já cobre a decisão, propor **nova ADR que a substitui** (nunca editar ADR aceita para mudar a decisão).
2. Descobrir o próximo número: maior `ADR-NNN` existente + 1, sem reaproveitar número. `ADR-000-template.md` não conta.
3. Se faltar contexto para o problema, as alternativas ou as consequências, perguntar ao usuário. Não inventar justificativa nem alternativa.
4. Criar `ADR-NNN-<slug-em-kebab-case>.md` com base no template: contexto, decisão, alternativas descartadas (com o motivo), consequências, riscos e status.
5. Linkar ADRs relacionadas e regras de `.ai/structure/rules/` afetadas.
6. Rodar `bash scripts/validate-ai-structure.sh`.

## Saída

Caminho da ADR criada, decisão em uma frase e ADRs relacionadas. Não commitar sem o usuário pedir.
