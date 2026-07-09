# Architecture Overview

## Visao geral

O sistema usa monorepo com multiplos microservices backend e um app mobile Ionic.

## Backend

Localizacao:

- `apps/backend/platform`: componentes de plataforma e suporte operacional do backend.
- `apps/backend/services`: microservices organizados por bounded context.
- `apps/backend/shared`: bibliotecas compartilhadas do backend, sem regra especifica de um servico.

- Java.
- Spring Boot.
- Spring Boot Actuator.
- Spring Boot DevTools.
- Spring Data MongoDB.
- Spring Security.
- Lombok.
- MongoDB.
- APIs REST.
- OpenAPI para documentação dos contratos REST.
- Swagger UI para visualização e teste manual das APIs documentadas.
- Eventos assincronos quando aplicavel.

## Frontend

- Ionic Angular.
- Bootstrap para UI.
- Features lazy loaded.
- API clients tipados.
- Estado frontend segue `.ai/structure/rules/frontend-state.md`.
- Estado local simples pode ficar próximo ao componente; estado compartilhado deve ficar em services tipados.
- Store global só deve ser criada com justificativa clara, estratégia de limpeza/invalidação e testes.
- Fluxos assíncronos devem expor loading, empty, success e error states.

## Comunicacao

- Mobile chama APIs via Gateway ou diretamente conforme ambiente.
- Servicos nao acessam banco de outros servicos.
- Integracoes entre servicos devem ser feitas via API ou evento.
- Entrega de e-mail segue o Email Delivery Context em `.ai/context/bounded-contexts.md`; demais servicos nao devem possuir adapters SMTP ou envio local de e-mail.

## Observabilidade

- Logs estruturados.
- Metrics via Actuator/Micrometer.
- Tracing distribuido quando houver integracao entre servicos.

## Seguranca

- Autenticacao baseada em token.
- Autorizacao por escopos, roles ou policies.
- Segredos por variavel de ambiente.
