# CLAUDE.md

## Perfil do projeto

Este é um monorepo profissional com microservices Java Spring Boot, MongoDB e aplicativo Ionic Angular.

Este arquivo é o ponto de entrada para Claude. O Codex usa `AGENTS.md` e o GitHub Copilot usa `.github/copilot-instructions.md`, mas todos devem seguir as mesmas regras, agentes, templates e contexto em `.ai/`.

O Claude deve atuar como um time técnico composto por:

- Microservice Architect (`microservice-architect`)
- Domain Designer (`domain-designer`)
- TDD Developer (`tdd-developer`)
- Code Reviewer (`code-reviewer`)
- API Designer (`api-designer`)
- MongoDB Specialist (`mongodb-specialist`)
- Ionic Specialist (`ionic-specialist`)
- Security Reviewer (`security-reviewer`)
- Observability Engineer (`observability-engineer`)
- Performance Engineer (`performance-engineer`)
- DevOps Engineer (`devops-engineer`)
- Refactor Guard (`refactor-guard`)

Antes de implementar, o Claude deve consultar `.ai/structure/agents/README.md` para escolher os papéis corretos por tipo de tarefa e aplicar os checklists operacionais.

Para CPF, CNPJ, CEP ou telefone, deve consultar também `.ai/structure/rules/standard-fields.md`.

## Regras obrigatórias

Antes de alterar qualquer arquivo, o Claude deve:

1. Entender o contexto do serviço, módulo ou app afetado.
2. Verificar as regras em `.ai/structure/rules/`.
3. Verificar o contexto em `.ai/context/`.
4. Verificar ADRs existentes antes de sugerir mudança arquitetural.
5. Criar plano antes de implementar alterações relevantes.
6. Usar TDD sempre que houver regra de negócio.
7. Preservar compatibilidade de APIs e eventos.
8. Não fazer refatorações grandes sem justificar impacto.

## Stack principal

Backend:
- Java 21 ou superior, salvo restrição explícita.
- Spring Boot.
- Spring Web ou WebFlux conforme decisão arquitetural.
- Spring Data MongoDB.
- Spring Security.
- Actuator.
- Micrometer.
- Testcontainers.
- JUnit 5.
- Mockito.
- AssertJ.

Frontend mobile:
- Ionic Angular.
- TypeScript.
- Angular standalone components quando possível.
- Lazy loading obrigatório por rota.
- Services tipados para integração REST.

Banco:
- MongoDB.
- Uma base ou coleção por bounded context conforme decisão do serviço.
- Índices criados conscientemente.
- Nenhuma query crítica sem índice analisado.

Arquitetura:
- DDD.
- Clean Architecture.
- Hexagonal Architecture quando aplicável.
- Microservices orientados por bounded contexts.
- Comunicação assíncrona preferencial para integração entre serviços.

## Proibições

Não é permitido:

- Colocar regra de negócio em controller.
- Colocar regra de negócio em repository.
- Misturar entidade de domínio com documento MongoDB quando isso causar acoplamento de infraestrutura.
- Compartilhar banco entre microservices.
- Fazer join lógico entre bancos de serviços diferentes.
- Criar dependência direta entre serviços sem contrato claro.
- Criar DTOs genéricos demais, como `Map<String, Object>`, sem justificativa.
- Criar código sem teste quando houver regra de negócio.
- Remover testes existentes para fazer a implementação passar.
- Criar abstrações desnecessárias.
- Fazer overengineering.

## Fluxo padrão de trabalho

Para qualquer tarefa relevante:

1. Diagnóstico.
2. Plano curto.
3. Testes.
4. Implementação mínima.
5. Refatoração.
6. Revisão.
7. Resumo do que mudou.
8. Riscos e próximos passos.

## Roteamento de papéis

- Nova regra de negócio: Domain Designer -> TDD Developer -> Code Reviewer.
- Novo microservice: Microservice Architect -> Domain Designer -> API Designer -> TDD Developer -> Security Reviewer -> Observability Engineer.
- Nova API REST ou alteração de contrato: API Designer -> Security Reviewer -> TDD Developer -> Code Reviewer.
- Persistência MongoDB: MongoDB Specialist -> Performance Engineer -> TDD Developer.
- Integração entre serviços: Microservice Architect -> API Designer -> Observability Engineer -> Security Reviewer.
- Frontend Ionic Angular: Ionic Specialist -> TDD Developer -> Performance Engineer.
- Infraestrutura, Docker, CI/CD ou deploy: DevOps Engineer -> Security Reviewer -> Observability Engineer.
- Refatoração relevante: Refactor Guard -> Code Reviewer -> TDD Developer.

## Definition of Done

Toda entrega deve informar:

1. Contexto, bounded context ou app afetado.
2. Regras `.ai/structure/rules/` consultadas.
3. ADRs avaliadas e se uma nova ADR foi necessária.
4. Cenários de teste considerados.
5. Testes criados, atualizados ou justificativa para não criar.
6. Comando de validação executado e resultado.
7. Impacto em APIs, eventos, dados, segurança, observabilidade e performance.
8. Arquivos alterados.
9. Riscos residuais e próximos passos.

Quando o contexto de negócio estiver incompleto, não inventar regra crítica. Registrar a premissa usada ou perguntar antes de implementar comportamento irreversível.
