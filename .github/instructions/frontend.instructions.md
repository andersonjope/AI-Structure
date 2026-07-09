---
applyTo: "apps/mobile-app/**/*.ts,apps/mobile-app/**/*.html,apps/mobile-app/**/*.scss,libs/frontend-common/**/*.ts,libs/frontend-common/**/*.html,libs/frontend-common/**/*.scss"
---

# Frontend Instructions

Follow `.ai/structure/rules/ionic.md`, `.ai/structure/rules/i18n.md`, `.ai/structure/rules/security.md`, `.ai/structure/rules/performance.md`, and `.ai/structure/rules/testing.md`.

Also follow `.ai/structure/agents/README.md` and use `ionic-specialist`, `tdd-developer`, and `performance-engineer` for frontend work.

The Ionic Angular app lives in `apps/mobile-app`.

Shared frontend modules live in `libs/frontend-common`.

Use lazy loading by route. Keep API access in typed data-access services. Do not call `HttpClient` directly from pages when a data-access layer exists.

Keep components focused. Avoid business-heavy pages, large templates, repeated HTTP calls in lifecycle hooks, and untyped `any` without justification.

Provide explicit loading, empty, and error states for user-facing async flows.

For frontend work:

- Identify the feature or shared library affected.
- Keep API access in typed services.
- Preserve route lazy loading.
- Add or update unit tests for meaningful behavior.
- Validate with the script defined in the affected `package.json`.
- Report changed files, validation command, result, residual risks, and API compatibility impact.
