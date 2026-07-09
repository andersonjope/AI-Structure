---
applyTo: "apps/backend/**/*.java,apps/backend/**/pom.xml,apps/backend/**/*.yml,apps/backend/**/*.yaml,apps/backend/**/Dockerfile"
---

# Backend Instructions

Follow the backend rules in `.ai/structure/rules/architecture.md`, `.ai/structure/rules/api-contracts.md`, `.ai/structure/rules/ddd.md`, `.ai/structure/rules/tdd.md`, `.ai/structure/rules/spring-boot.md`, `.ai/structure/rules/mongodb.md`, `.ai/structure/rules/security.md`, `.ai/structure/rules/observability.md`, `.ai/structure/rules/performance.md`, and `.ai/structure/rules/testing.md`.

Also follow `.ai/structure/agents/README.md` to choose specialist roles and apply the backend Definition of Done.

Microservices live in `apps/backend/services`.

Shared backend modules live in `apps/backend/shared`.

Platform and operational backend support lives in `apps/backend/platform`.

Keep domain code free of Spring, MongoDB, HTTP, Kafka, Jackson, and infrastructure imports.

Controllers must adapt input and output only. Use cases orchestrate application flow. Domain objects protect invariants. Infrastructure implements persistence, messaging, external integrations, config, and security.

Use TDD for business rules. Prefer domain and use case unit tests before integration tests.

Do not share databases between microservices. Do not query another service's database directly. Use APIs, events, or explicit contracts.

For backend work:

- Identify the bounded context before changing code.
- Check ADRs before architectural or contract changes.
- Use `domain-designer` and `tdd-developer` for business behavior.
- Use `api-designer` and `security-reviewer` for REST APIs.
- Use `mongodb-specialist` for persistence changes.
- Use `observability-engineer` for external calls, events, and critical flows.
- Prefer `mvn -pl path/to/module test` for focused validation and `mvn test` before broader completion.
- Report changed files, validation command, result, residual risks, and compatibility impact.
