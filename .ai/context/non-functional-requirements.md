<!-- TEMPLATE:EXEMPLO -->
# Non-Functional Requirements

## Performance

- APIs críticas devem responder preferencialmente abaixo de 300ms em operação normal.
- Listagens devem ser paginadas.
- Queries críticas devem ter índice.
- Mobile deve usar lazy loading.

## Disponibilidade

- Serviços críticos devem ter health check.
- Falhas de dependência devem ser tratadas com timeout.
- Mensageria deve ter consumo idempotente.

## Segurança

- APIs privadas exigem autenticação.
- Dados sensíveis não devem aparecer em logs.
- Segredos não devem ser versionados.

## Observabilidade

- Todo request deve ter correlationId.
- Erros devem ser rastreáveis.
- Métricas devem permitir análise de latência, erro e throughput.

## Manutenibilidade

- Código deve seguir DDD, Clean Architecture e Clean Code.
- Mudanças arquiteturais devem gerar ADR.
- Contratos devem ser documentados.
