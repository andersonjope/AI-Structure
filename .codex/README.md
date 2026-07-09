# Codex Engineering Workspace

Este diretório marca o suporte do repositório ao Codex.

## Como usar

O ponto de entrada do Codex é o arquivo `AGENTS.md` na raiz.

As regras, agentes, templates e contexto arquitetural são compartilhados com Claude e GitHub Copilot em `.ai/` para evitar duplicação e divergência.

## Organização compartilhada

- `.ai/structure/rules/`: padrões técnicos obrigatórios.
- `.ai/structure/agents/`: papéis especializados.
- `.ai/structure/templates/`: modelos para artefatos recorrentes.
- `.ai/context/`: contexto de negócio e arquitetura.

## Fluxo recomendado

Antes de implementar qualquer alteração relevante:

1. Leia `AGENTS.md`.
2. Consulte as regras em `.ai/structure/rules/`.
3. Consulte o contexto em `.ai/context/`.
4. Use os agentes em `.ai/structure/agents/` como papéis de revisão e implementação.
5. Consulte `.ai/structure/agents/README.md` para escolher o roteamento de agentes e aplicar a Definition of Done.

## Entrega esperada

Ao concluir uma tarefa relevante, informe:

- Contexto ou bounded context afetado.
- Regras e agentes considerados.
- ADRs avaliadas.
- Testes criados ou atualizados.
- Comando de validação executado.
- Impactos em APIs, eventos, dados, segurança, observabilidade e performance.
- Riscos residuais e próximos passos.
