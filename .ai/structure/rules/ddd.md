# DDD Rules

## DDD estratégico

- Cada microservice deve representar um bounded context claro.
- Não criar microservice por entidade CRUD.
- Identificar linguagem ubíqua antes de modelar.
- Evitar compartilhar modelos de domínio entre bounded contexts.
- Integração entre contextos deve ocorrer via APIs, eventos ou contratos explícitos.

## DDD tático

Elementos permitidos no domínio:

- Aggregate
- Entity
- Value Object
- Domain Service
- Domain Event
- Repository Interface
- Specification, quando fizer sentido

## Aggregates

- Agregados devem proteger invariantes.
- Toda alteração relevante deve passar por método de comportamento.
- Evitar setters públicos indiscriminados.
- Evitar agregados grandes demais.
- Referenciar outros agregados por ID, não por objeto completo.

## Value Objects

- Devem ser imutáveis.
- Devem validar seu próprio estado.
- Devem representar conceitos do negócio.
- Exemplos: Email, Money, DocumentNumber, ProductSku, Quantity.
- Para CPF, CNPJ, CEP e telefone, seguir os valores canônicos e validações de `.ai/structure/rules/standard-fields.md`.

## Domain Events

Eventos de domínio devem:

- Ter nome no passado, por exemplo `OrderCreated`.
- Representar algo que já aconteceu.
- Não carregar objeto gigante.
- Carregar apenas dados necessários para consumidores.

## Proibido

- Anemizar domínio com apenas getters e setters.
- Criar entidade de domínio como reflexo direto da coleção MongoDB.
- Usar DTO como entidade.
- Colocar validação de negócio apenas em annotation.
