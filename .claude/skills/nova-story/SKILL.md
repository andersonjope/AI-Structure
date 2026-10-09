---
name: nova-story
description: Especifica uma funcionalidade em docs/stories/ (histórias de usuário, critérios de aceite, regras de negócio, rastreabilidade) antes de implementar. Usar ao iniciar funcionalidade nova ou mudar regra de negócio visível.
---

# Nova story

Fonte: `.ai/structure/templates/story-template.md`. Regras: `.ai/structure/rules/documentation.md`. Papel: `domain-designer`.

## Passos

1. Ler `.ai/context/` (negócio, bounded contexts, linguagem ubíqua) e `docs/stories/README.md`. Usar os termos da linguagem ubíqua.
2. Identificar lacunas de negócio. **Perguntar ao usuário** em vez de inventar regra crítica; o que ficar sem resposta vai em "Premissas e perguntas em aberto".
3. Criar `docs/stories/NN-<assunto>.md` (próximo número do índice) com:
   - visão, personas e fora de escopo;
   - histórias `USnn` estáveis (continuar a numeração, nunca renumerar);
   - critérios de aceite em formato Dado/Quando/Então, incluindo caso de erro (cada um vira cenário de teste);
   - regras e invariantes;
   - tabela de rastreabilidade história → endpoint/evento → tela → teste;
   - fases e status.
4. Adicionar o documento ao índice `docs/stories/README.md` com status.
5. Se a story exigir decisão arquitetural, indicar a skill `nova-adr`. Se tocar contrato REST ou evento, indicar os templates `rest-api-template.md`/`event-contract-template.md`.
6. Rodar `bash scripts/validate-ai-structure.sh`.

## Próximo passo sugerido

Implementar por TDD (`tdd-developer`), partindo dos critérios de aceite.
