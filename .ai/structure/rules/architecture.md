# Architecture Rules

## Estilo arquitetural

O projeto usa Clean Architecture com influência de Hexagonal Architecture.

Camadas esperadas em cada microservice, só criar a estrutura de pastas se necessário:

```text
src/main/java/com/company/service
├── domain
│   ├── model
│   ├── valueobject
│   ├── event
│   ├── service
│   └── repository
├── application
│   ├── usecase
│   ├── command
│   ├── query
│   ├── dto
│   └── port
├── infrastructure
│   ├── persistence
│   ├── messaging
│   ├── external
│   ├── config
│   └── security
└── interfaces
    ├── rest
    ├── consumer
    └── mapper
```

## Dependências permitidas

- `interfaces` pode depender de `application`.
- `application` pode depender de `domain`.
- `infrastructure` pode implementar portas de `application` e `domain`.
- `domain` não depende de Spring, MongoDB, HTTP, Kafka, Jackson ou qualquer framework.

## Regras obrigatórias

- Controller deve apenas adaptar entrada e saída.
- Use case deve orquestrar fluxo de aplicação.
- Domínio deve proteger invariantes.
- Infraestrutura deve conter detalhes técnicos.
- Contratos externos devem ser versionados.
- Decisões arquiteturais relevantes devem gerar ADR.

## Infraestrutura operacional por microservice

Além da camada Java `src/main/java/.../infrastructure`, cada microservice pode possuir uma pasta operacional na raiz do serviço:

```text
apps/backend/services/<service>/infra/
├── Dockerfile
└── docker-compose.yml
```

Essa pasta é exclusiva para artefatos de runtime e deploy local do serviço, como Dockerfile, docker-compose e arquivos auxiliares de container.

Não colocar código Java, regras de negócio, adapters Spring ou configuração de aplicação nessa pasta. Código e configuração Java continuam seguindo as camadas `domain`, `application`, `infrastructure` e `interfaces`.

## Proibido

- Domínio importando `org.springframework`.
- Domínio importando `org.bson`.
- Controller chamando repository diretamente.
- Repository contendo regra de negócio.
- Application contendo detalhes de MongoDB.
- Uso indiscriminado de classes `Util`.
