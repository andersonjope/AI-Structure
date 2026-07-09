# GitHub Copilot Instructions

This repository is an AI-assisted engineering monorepo for Java Spring Boot microservices, MongoDB, and an Ionic Angular mobile app.

## Shared Instructions

Use the same governance used by Claude Code or Codex or GitHub Copilot:

- Claude entrypoint: `CLAUDE.md`
- Codex and agent entrypoint: `AGENTS.md`
- GitHub Copilot entrypoint: `.github/copilot-instructions.md`
- Shared rules: `.ai/structure/rules/`
- Shared roles: `.ai/structure/agents/`
- Shared templates: `.ai/structure/templates/`
- Shared context: `.ai/context/`

Before making relevant changes, read the applicable files in `.ai/structure/rules/` and `.ai/context/`.
Also read `.ai/structure/agents/README.md` to choose the right specialist roles, operational checklist, and Definition of Done for the task.
For CPF, CNPJ, CEP, or phone fields, also follow `.ai/structure/rules/standard-fields.md`.

## Repository Layout

- `apps/backend/platform`: backend platform and operational support.
- `apps/backend/services`: Java Spring Boot microservices organized by bounded context.
- `apps/backend/shared`: backend shared libraries without service-specific business rules.
- `apps/mobile-app`: Ionic Angular mobile application.
- `libs/frontend-common`: shared frontend libraries.
- `infra`: Docker, Kubernetes, Nginx, and observability.

## Engineering Rules

- Keep business rules out of controllers and repositories.
- Preserve DDD, Clean Architecture, and Hexagonal Architecture boundaries.
- Keep domain code independent from Spring, MongoDB, HTTP, Kafka, Jackson, and infrastructure frameworks.
- Use TDD whenever there is business behavior.
- Preserve API and event compatibility unless a versioned contract change is explicitly requested.
- Do not remove existing tests to make an implementation pass.
- Do not add generic abstractions or overengineering without a clear local need.
- Do not expose secrets, tokens, stack traces, or sensitive data in code, logs, configs, or responses.

## Backend Rules

For files under `apps/backend/**`, follow:

- `.ai/structure/rules/architecture.md`
- `.ai/structure/rules/ddd.md`
- `.ai/structure/rules/tdd.md`
- `.ai/structure/rules/spring-boot.md`
- `.ai/structure/rules/mongodb.md`
- `.ai/structure/rules/security.md`
- `.ai/structure/rules/observability.md`
- `.ai/structure/rules/performance.md`
- `.ai/structure/rules/testing.md`

Each microservice should follow this structure:

- `domain`: model, value objects, events, domain services, repository interfaces.
- `application`: use cases, commands, queries, DTOs, ports.
- `infrastructure`: persistence, messaging, external integrations, config, security.
- `interfaces`: REST controllers, consumers, mappers.

## Frontend Rules

For files under `apps/mobile-app/**` and `libs/frontend-common/**`, follow:

- `.ai/structure/rules/ionic.md`
- `.ai/structure/rules/security.md`
- `.ai/structure/rules/performance.md`
- `.ai/structure/rules/testing.md`

Use lazy loading by route, typed API clients, centralized interceptors, explicit loading/error states, and avoid `any` unless justified.

## Review Expectations

When reviewing or generating changes:

1. State the affected bounded context or app area.
2. Identify risks before making broad changes.
3. Prefer incremental changes.
4. Add or update tests when behavior changes.
5. Summarize changed files, tests run, and residual risks.

## Specialist Routing

- New business rule: `domain-designer` -> `tdd-developer` -> `code-reviewer`.
- New microservice: `microservice-architect` -> `domain-designer` -> `api-designer` -> `tdd-developer` -> `security-reviewer` -> `observability-engineer`.
- REST API or contract change: `api-designer` -> `security-reviewer` -> `tdd-developer` -> `code-reviewer`.
- MongoDB persistence: `mongodb-specialist` -> `performance-engineer` -> `tdd-developer`.
- Service integration: `microservice-architect` -> `api-designer` -> `observability-engineer` -> `security-reviewer`.
- Ionic Angular frontend: `ionic-specialist` -> `tdd-developer` -> `performance-engineer`.
- Infrastructure, Docker, CI/CD, or deploy: `devops-engineer` -> `security-reviewer` -> `observability-engineer`.
- Relevant refactor: `refactor-guard` -> `code-reviewer` -> `tdd-developer`.

## Definition of Done

Every relevant change should identify:

1. Affected bounded context or app area.
2. `.ai/structure/rules/` files consulted.
3. ADRs checked and whether a new ADR is needed.
4. Test scenarios considered.
5. Tests added, updated, or why tests were not added.
6. Validation command and result.
7. Impact on APIs, events, data, security, observability, and performance.
8. Changed files.
9. Residual risks and next steps.

If business context is incomplete, do not invent critical behavior. State the assumption or ask before implementing irreversible behavior.
