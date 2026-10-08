# Claude Entry Workspace

Este diretório contém apenas configurações e notas específicas do Claude.

As regras, agentes, templates e contexto arquitetural compartilhados por Claude, Codex e GitHub Copilot ficam em `.ai/`.

Claude usa `CLAUDE.md` como ponto de entrada.

Codex usa `AGENTS.md` como ponto de entrada.

GitHub Copilot usa `.github/copilot-instructions.md` e `.github/instructions/*.instructions.md` como pontos de entrada.

## Como usar

Use comandos como:

```text
Leia CLAUDE.md, .ai/structure/rules e .ai/context. Depois analise o serviço company-service.
```

```text
Use os agentes domain-designer, tdd-developer e code-reviewer para implementar o caso de uso de cadastro de produto.
```

```text
Use refactor-guard antes de alterar este módulo.
```

## Organização

- `.ai/structure/rules/`: padrões técnicos obrigatórios para Claude, Codex e GitHub Copilot.
- `.ai/structure/agents/`: papéis especializados.
- `.ai/structure/templates/`: modelos para artefatos recorrentes.
- `.ai/context/`: contexto de negócio e arquitetura.

## Skills

`.claude/skills/<nome>/SKILL.md` define atalhos para tarefas recorrentes (ADR, story, relato de implementação,
auditoria, migração de dados, pipeline de CI/deploy e validação da estrutura). Cada skill aponta para as
regras e os templates de `.ai/`, sem duplicar conteúdo. O validador confere o frontmatter (`name` igual ao
diretório e `description` preenchida). Codex e Copilot não leem esta pasta; usam as regras e templates de `.ai/` diretamente.
