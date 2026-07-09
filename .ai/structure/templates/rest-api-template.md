# REST API: Nome

## Endpoint

```http
POST /api/v1/resources
```

## Objetivo

Descrever objetivo.

## Contexto dono

- Bounded context:
- Serviço:
- Use case:

## Request

```json
{
  "field": "value"
}
```

## Response sucesso

```json
{
  "id": "value"
}
```

## Status codes

- 200 OK
- 201 Created
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 409 Conflict
- 422 Unprocessable Entity
- 500 Internal Server Error

## Compatibilidade

- Tipo de mudança: nova API | compatível | breaking change
- Clientes afetados:
- Estratégia de versionamento:

## Erro padrão

```json
{
  "code": "ERROR_CODE",
  "message": "Human readable message",
  "details": [],
  "correlationId": "uuid"
}
```

## Segurança

- Autenticação:
- Autorização:
- Dados sensíveis:

## Observabilidade

- Métricas:
- Logs:
- Traces:
- CorrelationId:

## Testes

- Unitários:
- Integração:
- Contrato:

## Riscos

-
