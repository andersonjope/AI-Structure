# TDD Rules

## Fluxo obrigatório

Para regra de negócio:

1. Escrever teste que falha.
2. Implementar o mínimo para passar.
3. Refatorar mantendo teste verde.

## Tipos de teste

Prioridade:

1. Unit tests para domínio.
2. Unit tests para use cases.
3. Integration tests para adapters, MongoDB e APIs.
4. Contract tests para comunicação entre serviços.
5. E2E apenas para fluxos críticos.

## Nomenclatura

Usar nomes descritivos:

```java
shouldCreateOrderWhenCustomerHasValidCart()
shouldRejectOrderWhenCartIsEmpty()
```

## Regras

- Não mockar entidades de domínio.
- Não testar detalhes internos irrelevantes.
- Testar comportamento, não implementação.
- Usar Testcontainers para MongoDB quando testar persistência real.
- Usar AssertJ para legibilidade.
- Usar builders ou object mothers para dados de teste.

## Proibido

- Remover teste para fazer build passar.
- Ignorar teste quebrado sem justificativa.
- Criar teste sem assert relevante.
- Testar apenas caminho feliz.
