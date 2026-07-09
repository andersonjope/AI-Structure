# API Contract Rules

## Objetivo

Garantir contratos REST estáveis, seguros e compatíveis entre frontend, gateway e microservices.

## Versionamento

- APIs públicas e integrações entre serviços devem ser versionadas, preferencialmente com prefixo `/api/v1`.
- Breaking changes exigem nova versão ou estratégia explícita de compatibilidade.
- Alterações compatíveis devem preservar campos existentes e semântica dos status codes.

## Requests e responses

- Não expor entidades de domínio, documentos MongoDB ou modelos internos como contrato público.
- Usar DTOs/records específicos para request e response.
- Campos obrigatórios devem ser documentados e validados na borda.
- Campos opcionais devem ter semântica clara para ausência, `null` e string vazia.

## Status HTTP

- `200 OK`: leitura, atualização ou comando concluído sem criação.
- `201 Created`: recurso criado.
- `400 Bad Request`: validação ou regra de negócio inválida.
- `401 Unauthorized`: autenticação ausente ou inválida.
- `403 Forbidden`: usuário autenticado sem permissão.
- `404 Not Found`: recurso inexistente no contexto dono.
- `409 Conflict`: conflito de estado ou duplicidade quando fizer sentido para o contrato.
- `503 Service Unavailable`: dependência técnica temporariamente indisponível.

## Erro padrão

Toda API REST deve retornar erro com, no mínimo:

```json
{
  "code": "ERROR_CODE",
  "message": "Mensagem segura para o cliente"
}
```

Campos opcionais:

```json
{
  "details": [],
  "correlationId": "uuid"
}
```

## Regras para `code`

- `code` deve ser estável, em `UPPER_SNAKE_CASE`.
- `code` não deve depender de texto humano, idioma ou stack trace.
- Clientes devem usar `code` para tradução, decisão de UI e tratamento programático.
- `message` deve ser segura, sem stack trace, query, segredo, token ou detalhe interno.
- Quando uma mensagem legada precisar ser preservada, manter `message` e adicionar `code` sem remover campos existentes.

## Internacionalização de erros

- Frontends devem preferir tradução por `errors.CODE`.
- Backends devem retornar mensagens seguras em idioma padrão do serviço apenas como fallback.
- Não criar contrato que dependa exclusivamente do texto de `message`.

## Testes esperados

- Handlers de erro devem ter testes para status HTTP, `code` e `message`.
- APIs críticas devem testar sucesso, validação, autorização e erro esperado.
- Alterações de contrato consumidas pelo mobile ou outro serviço exigem teste de compatibilidade ou justificativa explícita.

## Proibido

- Retornar stack trace para cliente.
- Retornar `Map<String, Object>` genérico sem justificativa.
- Expor mensagens internas de infraestrutura.
- Usar texto de erro como contrato programático.
- Remover campo existente de response sem versionamento.
