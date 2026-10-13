---
name: relato-implementacao
description: Gera o relato de implementação de uma entrega concluída em docs/implementation/ a partir do diff, dos testes e da Definition of Done. Usar ao terminar uma entrega relevante (nova regra, contrato, migração, mudança de infra, correção de achado) ou quando o usuário pedir o resumo versionado do que mudou.
---

# Relato de implementação

Fonte: `.ai/structure/templates/implementation-report-template.md`. Regras: `.ai/structure/rules/documentation.md`.

## Quando NÃO usar

Ajuste trivial (typo, texto). Dizer ao usuário que o relato é dispensável.

## Passos

1. Levantar os fatos, não a memória: `git status`, `git diff` (e `git log` da branch) para arquivos e alterações reais.
2. Descobrir o que foi validado: comandos de teste/lint/build **efetivamente executados** nesta sessão e seus resultados. Se não foram rodados, rodar agora, ou registrar em "Validação final" que não foram.
3. Preencher o template, no passado e de forma curta:
   - contexto, bounded context/app e plano;
   - alterações;
   - regras `.ai/structure/rules/` consultadas, agentes aplicados, ADRs avaliadas (e se nova ADR foi necessária);
   - impactos em APIs, eventos, dados, segurança, observabilidade e performance;
   - testes (cenários, criados/atualizados, preservados);
   - arquivos alterados agrupados por módulo;
   - riscos residuais e próximo passo.
4. Salvar em `docs/implementation/<assunto>.md` (sem número). Se a entrega é fase de uma story, linkar `docs/stories/` e atualizar o status no índice `docs/stories/README.md`.
5. Rodar `bash scripts/validate-ai-structure.sh`.

## Proibido

- Descrever trabalho não feito ou não validado.
- Declarar teste como passando sem ter executado.
- Duplicar a especificação da story dentro do relato.
