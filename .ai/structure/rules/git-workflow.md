# Git Workflow Rules

## Branches

Padrão sugerido:

```text
main
feature/<descricao>
fix/<descricao>
chore/<descricao>
refactor/<descricao>
```

## Commits

Usar Conventional Commits:

```text
feat: add product creation use case
fix: correct order validation
refactor: isolate domain rules
chore: update dependencies
```

## Pull Request

Todo PR deve conter:

- Objetivo.
- Mudanças principais.
- Testes executados.
- Riscos.
- Evidências.

## Proibido

- Commit gigante misturando assuntos.
- Refatoração junto com feature sem necessidade.
- Merge sem teste.
- Alterar contrato público sem documentação.
