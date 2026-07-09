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
