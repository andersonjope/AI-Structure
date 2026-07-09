# Domain Event: NomeDoEventoNoPassado

## Significado

Descreva o fato de negócio que aconteceu.

## Produtor

- Serviço/contexto produtor

## Consumidores

- Serviço/contexto consumidor

## Payload

```json
{
  "eventId": "uuid",
  "eventType": "OrderCreated",
  "eventVersion": 1,
  "occurredAt": "2026-01-01T10:00:00Z",
  "data": {}
}
```

## Regras de compatibilidade

- Não remover campos sem nova versão.
- Adicionar campos opcionais é permitido.
- Consumidores devem ser idempotentes.
