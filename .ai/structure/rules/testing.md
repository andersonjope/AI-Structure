# Testing Rules

## Pirâmide de testes

Prioridade:

1. Muitos testes unitários.
2. Alguns testes de integração.
3. Poucos testes end-to-end.

## Backend

Usar:

- JUnit 5.
- AssertJ.
- Mockito.
- Testcontainers.
- Spring Boot Test apenas quando necessário.

## Frontend Ionic

Usar:

- Unit tests para services e componentes relevantes.
- Testes de integração para fluxos críticos.
- E2E para login, pedido, pagamento e fluxos principais.

## Contratos

Entre microservices:

- Documentar contrato.
- Testar compatibilidade.
- Versionar eventos e APIs.

## Proibido

- Teste frágil baseado em detalhe interno.
- Ignorar teste quebrado.
- Teste sem assert.
- E2E cobrindo tudo quando unit test resolveria.
