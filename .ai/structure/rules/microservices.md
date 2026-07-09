# Microservices Rules

## Princípios

- Microservice deve representar capacidade de negócio.
- Cada microservice deve ter ownership claro dos seus dados.
- Banco de dados não deve ser compartilhado entre serviços.
- Comunicação entre serviços deve ser orientada a contrato.

## Banco por serviço

Cada serviço deve possuir:

- Database próprio; ou
- Schema lógico próprio; ou
- Coleções próprias com ownership exclusivo.

Nenhum serviço deve consultar diretamente a base de outro serviço.

## Comunicação

Preferência:

1. Eventos assíncronos para propagação de fatos.
2. REST para consultas ou comandos simples.
3. gRPC apenas quando houver necessidade clara de baixa latência ou contrato fortemente tipado.

## Resiliência

Toda chamada externa deve considerar:

- Timeout.
- Retry com backoff quando seguro.
- Circuit breaker quando necessário.
- Idempotência.
- Fallback explícito quando aplicável.

## Eventos

Eventos devem ser:

- Versionados.
- Pequenos.
- Estáveis.
- Documentados.
- Idempotentes para consumo.

## Proibido

- Chamada síncrona em cascata sem necessidade.
- Transação distribuída como primeira opção.
- Compartilhar entidade entre serviços.
- Expor modelo interno como contrato público.
- Criar microservice CRUD sem bounded context.
