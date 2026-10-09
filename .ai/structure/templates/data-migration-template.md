# Migração de Dados: Título

Modelo para migração de dados existentes (correção de tipo, backfill de campo, mudança de
estrutura). Regras em `.ai/structure/rules/mongodb.md` > "Migração de dados" e deploy em
`.ai/structure/rules/deploy.md` (migrações **não** rodam no deploy).

## Contexto

- Serviço/módulo e coleções afetadas:
- Motivo (defeito, nova regra, mudança de schema):
- ADR ou relato de implementação relacionado:

## Classificação

| Pergunta | Resposta |
|---|---|
| Idempotente (rodar duas vezes produz o mesmo resultado)? | sim / não |
| Destrutiva (apaga ou zera dados)? | sim / não |
| Tem trava que impede reexecução indevida? | sim / não, qual |
| Precisa ser executada antes ou depois do deploy do código? | |
| Ordem relativa a outras migrações: | |

Migração destrutiva exige: backup confirmado, aprovação explícita e execução manual única.

## Estratégia

1. Selecionar apenas documentos que **ainda precisam** de migração (filtro por tipo/ausência do campo), nunca a coleção inteira.
2. Usar a coleção nativa do driver quando o mapeamento do ORM/ODM converteria o filtro ou o valor.
3. Converter apenas valores válidos; contar e reportar os inválidos sem alterá-los.
4. Aplicar em lotes, com operação por lote idempotente (`$set` condicionado ao estado anterior).
5. Imprimir resumo: lidos, migrados, ignorados, inválidos.

## Script

- Local versionado: `apps/backend/.../scripts/<nome-da-migracao>` (mesmo build/runtime da aplicação).
- Parâmetros e variáveis: conexão por variável de ambiente, nunca hardcoded.
- Modo `--dry-run` que apenas conta e reporta, quando viável.
- Saída com código diferente de zero se houver documentos inválidos.

## Testes (obrigatórios)

Seguir TDD: escrever primeiro, ver falhar.

| Cenário | Esperado |
|---|---|
| Documento no formato antigo | Migrado para o formato novo |
| Documento já no formato novo | Inalterado |
| Valor inválido ou nulo | Ignorado e contabilizado, sem exceção |
| Segunda execução | Nenhuma alteração (idempotência) |
| Coleção vazia | Conclui sem erro |
| Dados semeados pelo caminho real da aplicação | Migração não é necessária / não altera |

Rodar contra banco real de teste (Testcontainers ou equivalente), não mocks: o defeito costuma
estar no tipo gravado, que um mock esconde.

## Execução e rollback

- Comando de execução (no ambiente alvo):
- Pré-requisitos (backup, janela, versão do código):
- Verificação pós-execução (consulta de contagem que deve retornar zero pendentes):
- Rollback: restauração do backup, ou script inverso idempotente. Rollback automático de deploy **não** desfaz migração.

## Registro

Listar no runbook `infra/deploy/README.md` (seção "Migrações"), na ordem de execução, com:
o que faz, se é idempotente/destrutiva e o comando. Registrar a execução em ambiente
real (data, quem, resultado) no relato de implementação.
