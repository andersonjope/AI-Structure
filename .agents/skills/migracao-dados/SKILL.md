---
name: migracao-dados
description: Cria uma migração de dados idempotente com testes contra banco real, e documenta a execução no runbook. Usar ao corrigir tipo gravado, fazer backfill de campo ou alterar a estrutura de dados já existentes.
---

# Migração de dados

Fonte: `.ai/structure/templates/data-migration-template.md`. Regras: `.ai/structure/rules/mongodb.md` (seção "Migração de dados"), `testing.md`, `deploy.md`. Papéis: `mongodb-specialist` → `tdd-developer`.

## Passos

1. Entender o defeito ou a mudança: reproduzir com uma consulta que conte os documentos afetados.
2. **Classificar** (preencher a tabela do template): idempotente? destrutiva? tem trava? ordem relativa a outras migrações? Se for destrutiva, **parar e pedir confirmação** ao usuário, exigindo backup e execução manual única.
3. **TDD**: escrever primeiro os testes contra banco real de teste (Testcontainers ou equivalente), vendo-os falhar:
   - formato antigo migra; formato novo não muda;
   - valor inválido/nulo é ignorado e contabilizado;
   - segunda execução não altera nada;
   - coleção vazia conclui sem erro.
   Dados de teste devem nascer pelo caminho real da aplicação.
4. Implementar o script: seleciona só o que falta migrar, usa a coleção nativa quando o ODM converteria filtro ou valor, converte apenas valores válidos, resume (lidos/migrados/ignorados/inválidos), conexão por variável de ambiente, `--dry-run` quando viável.
5. Documentar na seção "Migrações" do `infra/deploy/README.md`, na ordem de execução, com o comando. **Não** colocar a migração no deploy automático.
6. Registrar rollback (restauração ou script inverso) e, se a entrega for relevante, indicar a skill `relato-implementacao`.
7. Rodar os testes e `bash scripts/validate-ai-structure.sh`.

## Proibido

- Executar a migração em ambiente real.
- Migrar a coleção inteira sem filtro de pendentes.
- Dar a migração como verificada só com mocks.
