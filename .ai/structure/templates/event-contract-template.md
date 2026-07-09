# Event Contract: NomeDoEvento

## Versão

1

## Produtor

-

## Consumidores

-

## Quando é emitido

-

## Payload

```json
{
  "eventId": "uuid",
  "eventType": "EventName",
  "eventVersion": 1,
  "occurredAt": "2026-01-01T10:00:00Z",
  "correlationId": "uuid",
  "data": {}
}
```

## Idempotência

Campo usado para idempotência:

- eventId

## Compatibilidade

- Não remover campos.
- Não alterar semântica de campos existentes.
- Campos novos devem ser opcionais.
