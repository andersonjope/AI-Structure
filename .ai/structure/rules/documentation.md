# Documentation Rules

## Agente responsável

`domain-designer` (stories) → `tdd-developer` (relatos de implementação) → `code-reviewer` (auditorias)

## Princípio

Cada tipo de documento responde a **uma** pergunta e vive em um lugar. Não duplicar conteúdo
entre eles; linkar.

| Pergunta | Documento | Local | Modelo |
|---|---|---|---|
| O que o produto faz e por quê? | Story | `docs/stories/NN-<assunto>.md` | `story-template.md` |
| Por que escolhemos assim? | ADR | `.ai/context/architecture-decision-records/` | `adr-template.md` |
| O que foi feito nesta entrega? | Relato de implementação | `docs/implementation/<assunto>.md` | `implementation-report-template.md` |
| Em que estado está a qualidade? | Auditoria | `docs/auditoria-<assunto>-AAAA-MM-DD.md` | `audit-report-template.md` |
| Como migrar dados existentes? | Migração | `docs/implementation/` + script versionado | `data-migration-template.md` |
| Como configurar o ambiente? | Variáveis | `docs/env/README.md` | (ver arquivo) |
| Como operar o deploy? | Runbook | `infra/deploy/README.md` | `deploy-scripts-template.md` |

Todos os modelos estão em `.ai/structure/templates/`.

## Quando criar

- **Story**: antes de implementar uma funcionalidade nova ou de mudar regra de negócio visível. Mantém `docs/stories/README.md` como índice com status por documento.
- **ADR**: decisão arquitetural, de segurança ou de plataforma com alternativas descartadas. Numeração sequencial, sem reaproveitar número.
- **Relato de implementação**: entrega relevante (nova regra, contrato, migração, mudança de infraestrutura, correção de achado de auditoria). Dispensado para ajuste trivial.
- **Auditoria**: revisão ampla (qualidade, segurança, cobertura) em marco do projeto ou antes de ir para produção.

## Regras

- Documentação descreve o que **existe**: atualizar no mesmo PR que muda o comportamento (contrato REST, modelagem, telas).
- Relato e auditoria são históricos datados: não reescrever; registrar mudança de status no próprio item.
- Identificadores (`US01`, `AUD-01`, `ADR-007`) são estáveis: nunca renumerar nem reutilizar.
- Fase de funcionalidade grande vira relato próprio (`<assunto>-fase-1-...md`), ligada à story.
- Sem segredo, token, senha ou dado pessoal real em exemplos.
- Documento em Markdown, no idioma do projeto, com links relativos que existam (o validador confere os caminhos `.ai/`).
- O índice `docs/stories/README.md` lista todos os documentos com status; documento novo entra no índice.

## Proibido

- Relato de implementação descrevendo trabalho não feito ou não validado.
- Auditoria sem evidência (comando, saída, arquivo) para cada achado.
- ADR editada depois de aceita para esconder uma decisão que mudou; criar ADR nova que a substitui.
- Duplicar a especificação da story dentro do relato ou da ADR.
