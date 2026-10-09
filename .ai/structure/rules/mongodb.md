# MongoDB Rules

## Modelagem

MongoDB deve ser modelado por padrão de acesso, não por normalização relacional.

Perguntas obrigatórias antes de criar coleção:

- Quais queries serão mais frequentes?
- Qual o volume esperado?
- Qual o padrão de leitura e escrita?
- Existe necessidade de histórico?
- Existe necessidade de consistência forte?

## Documents

- Documentos devem representar agregados ou projeções coerentes.
- Evitar documento gigante e sem limite de crescimento.
- Evitar arrays ilimitados.
- Usar embed quando os dados forem acessados juntos e tiverem ciclo de vida dependente.
- Usar referência por ID quando houver ciclo de vida independente.

## Índices

- Toda query crítica deve ter índice planejado.
- Criar índices compostos para consultas frequentes com múltiplos campos.
- Avaliar cardinalidade antes de indexar.
- Evitar índices desnecessários, pois impactam escrita.
- Índices devem ser documentados no serviço.

## Spring Data MongoDB

- Repositories concretos ficam em infrastructure.
- Interfaces de domínio não devem depender de Spring Data.
- Usar MongoTemplate para queries complexas.
- Usar projections quando não for necessário carregar documento completo.

## Referências entre coleções (tipo do identificador)

- Referência a documento de outra coleção do **mesmo** serviço deve ser gravada como `ObjectId`, não como texto. Id recebido pela API chega como `String` e precisa ser convertido no adaptador.
- Spring Data: `@Field(targetType = FieldType.OBJECT_ID)` na referência e `@MongoId(FieldType.OBJECT_ID)` no identificador. Mongoose/NestJS: `@Prop({ type: SchemaTypes.ObjectId, ref })`, nunca `type: Types.ObjectId`.
- Efeito do erro: o valor é gravado como texto e filtros por `ObjectId` deixam de encontrar o documento, sem lançar exceção.
- Cobrir com teste de mapeamento (o tipo gravado é `ObjectId`) e com teste de integração que cria pelo endpoint e filtra pela referência. Dados semeados direto com `ObjectId` escondem o defeito.
- Dados já gravados com o tipo errado são corrigidos por migração idempotente (ver abaixo).

## Migração de dados

Modelo: `.ai/structure/templates/data-migration-template.md`.

- Script versionado junto da aplicação, com conexão por variável de ambiente.
- **Idempotente**: seleciona só documentos que ainda precisam migrar e pode rodar mais de uma vez.
- Usa a coleção nativa do driver quando o mapeamento do ODM converteria filtro ou valor; converte apenas valores válidos e contabiliza os inválidos.
- Migração destrutiva (apaga ou zera dados) exige backup, trava contra reexecução e execução manual única.
- Não roda no deploy automático; fica documentada, na ordem de execução, no runbook (`infra/deploy/README.md`).
- Rollback de imagem não desfaz migração: planejar restauração ou script inverso.
- Teste obrigatório com banco real de teste (ver `.ai/structure/rules/testing.md`).

## Auditoria

Campos recomendados:

- createdAt
- updatedAt
- createdBy quando aplicável
- updatedBy quando aplicável
- version quando houver concorrência otimista

## Performance

- Evitar consultas sem filtro em coleções grandes.
- Evitar paginação profunda com `skip` em alto volume.
- Preferir paginação por cursor quando necessário.
- Evitar regex sem prefixo indexável.
- Usar TTL index para dados temporários.
- Monitorar slow queries.

## Proibido

- Fazer modelagem relacional automática.
- Criar índice para todo campo sem análise.
- Criar documento com array infinito.
- Consultar banco de outro microservice.
- Acoplar domínio diretamente a `@Document` quando prejudicar isolamento.
