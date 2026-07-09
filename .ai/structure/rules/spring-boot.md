# Spring Boot Rules

## Versão e runtime

- Preferir Java 21 ou superior.
- Usar Spring Boot estável definido no projeto.
- Usar Maven no backend, salvo decisão contrária.

## Organização

Cada microservice deve seguir:

```text
src/main/java
├── domain
├── application
├── infrastructure
└── interfaces
```

## Controllers

Controllers devem:

- Receber request.
- Validar entrada superficial.
- Chamar use case.
- Retornar response.
- Validar valores canônicos de CPF, CNPJ, CEP e telefone conforme `.ai/structure/rules/standard-fields.md`.

Controllers não devem:

- Conter regra de negócio.
- Chamar MongoRepository diretamente.
- Montar regra condicional complexa.

## Use cases

Use cases devem:

- Orquestrar fluxo.
- Controlar transação quando aplicável.
- Chamar portas/repositories.
- Publicar eventos via porta.

## Configuração

- Usar `application.yml`.
- Separar perfis: `local`, `test`, `dev`, `prod`.
- Não versionar segredo.
- Usar variáveis de ambiente para credenciais.

## Actuator

Habilitar endpoints mínimos:

- health
- info
- metrics
- prometheus, quando usado

## Exceptions

- Criar exceções de domínio para regras de negócio.
- Criar handler global em interfaces/rest.
- Não vazar stack trace para cliente.
- Respostas de erro REST devem seguir `.ai/structure/rules/api-contracts.md`, retornando no mínimo `code` e `message`.

## Proibido

- Usar `@Autowired` em campo.
- Criar service transacional gigante.
- Usar entidade Mongo diretamente como response pública sem necessidade.
- Expor detalhes internos em mensagens de erro.
