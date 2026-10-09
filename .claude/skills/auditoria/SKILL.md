---
name: auditoria
description: Executa uma auditoria de qualidade, segurança e cobertura e registra o relatório com achados AUD-NN e evidências em docs/. Usar quando o usuário pedir auditoria, revisão ampla antes de produção ou levantamento de conformidade com as regras internas.
---

# Auditoria

Fonte: `.ai/structure/templates/audit-report-template.md`. Regras: `.ai/structure/rules/documentation.md`, `security.md`, `testing.md`, `ci.md`.

## Passos

1. Definir o escopo com o usuário (módulos, apps, testes, dependências, CI, infra) e registrar a revisão auditada (`git rev-parse --short HEAD`).
2. Aplicar os papéis `code-reviewer` e `security-reviewer` (e `performance-engineer`/`observability-engineer` conforme o escopo), lendo seus checklists em `.ai/structure/agents/README.md`.
3. **Medir, não supor.** Executar e registrar o resultado real de:
   - testes unitários e de integração;
   - lint e typecheck/compilação;
   - build de produção;
   - cobertura nas quatro métricas (linhas, instruções, funções, ramificações), declarando o método;
   - auditoria de dependências (`pnpm audit`, `npm audit`, OWASP dependency-check);
   - `bash scripts/validate-ai-structure.sh`.
   Comando que não puder rodar vira "não executado" com o motivo.
4. Para cada achado: ID estável `AUD-NN`, gravidade, evidência (comando e saída, arquivo e linha), causa, impacto sem exagero, regras/ADRs de referência, status e ações verificáveis. Sem evidência, não é achado.
5. Salvar em `docs/auditoria-<assunto>-AAAA-MM-DD.md`. **Não corrigir** durante a auditoria; informar ao usuário que nenhuma correção foi aplicada.
6. Fechar com conclusão e ordem sugerida de correção (segurança e integridade de dados primeiro).

## Proibido

- Achado sem evidência reproduzível.
- Reescrever relatório antigo: registrar mudança de status no próprio achado.
- Baixar limite de cobertura ou silenciar alerta para "melhorar" o resultado.
