# AI Engineering Monorepo

Estrutura base para trabalhar com Claude Code, Codex e GitHub Copilot no mesmo monorepo.

## Objetivo

Este repositório é um **template de governança para desenvolvimento assistido
por IA** (Claude Code, Codex, GitHub Copilot) em projetos de microservices
Java/Spring Boot + MongoDB e app Ionic Angular. Ele centraliza agentes, regras
técnicas, templates de artefato, contexto de arquitetura e uma referência
mínima de código (`apps/`) para que um projeto novo comece com padrões
consistentes, em vez de reconstruir essa base do zero a cada vez.

O que este repositório fornece, em três camadas (detalhado em
`.ai/README.md` > "Portabilidade para outros projetos"):

- **Universal**: papéis de agente, Definition of Done, templates de contrato/ADR, regras de segurança, teste e clean code — não muda entre projetos.
- **Stack-specific**: regras de Spring Boot, MongoDB, Ionic Angular, Docker — muda se o projeto novo usar outra stack.
- **Product-specific**: tudo em `.ai/context/` (negócio, bounded contexts, linguagem ubíqua, integrações, ADRs reais) — é sempre substituído a cada novo projeto.

## Como usar este repositório para iniciar um novo projeto

Este repositório funciona como base **via branch**, não via cópia manual de
arquivos para outro lugar:

1. A partir de `main` (que deve permanecer genérica e sempre atualizada), criar uma branch por projeto:
   ```bash
   git checkout -b projeto/<nome-do-projeto>
   ```
2. Nessa branch, adaptar o que é específico do produto:
   - Reescrever `.ai/context/` inteiro (contexto de negócio, bounded contexts, linguagem ubíqua, integrações, requisitos não funcionais, ADRs) para a realidade do novo projeto.
   - Remover ou ajustar, em `.ai/structure/rules/`, as regras de stack que não se aplicam (ex.: remover `mongodb.md` se o projeto usar outro banco; remover `ionic.md`/`frontend-state.md` se não houver app mobile).
   - Atualizar a seção "Estrutura principal" deste `README.md` e usar `apps/backend/README.md`/`apps/mobile-app/README.md` como esqueleto para o primeiro serviço e a primeira feature reais.
   - Revisar `CLAUDE.md`/`AGENTS.md`/`.github/copilot-instructions.md` só se o time técnico ou o roteamento de agentes mudar — normalmente não precisam mudar.
3. Rodar `scripts/validate-ai-structure.sh` depois de qualquer alteração e antes de abrir PR.
4. Manter `main` como a base limpa: melhorias universais (novo agente, correção no validador, nova regra técnica de uso geral) entram primeiro em `main` e são trazidas para as branches de projeto por merge/rebase — nunca o caminho inverso.

Isso mantém um único lugar de verdade para a governança, em vez de cada
projeto divergir de forma independente e nunca mais receber melhorias.

## Pontos de entrada

- Claude Code: leia `CLAUDE.md`.
- Codex: leia `AGENTS.md`.
- GitHub Copilot: lê `.github/copilot-instructions.md` e instruções específicas em `.github/instructions/`.

## Governança compartilhada

As regras, agentes, templates e contexto ficam centralizados em `.ai/` para evitar duplicação:

- `.ai/structure/rules/`: padrões técnicos obrigatórios.
- `.ai/structure/agents/`: papéis especializados.
- `.ai/structure/templates/`: modelos para artefatos recorrentes.
- `.ai/context/`: contexto de negócio e arquitetura.
- `.github/copilot-instructions.md`: instruções gerais do Copilot.
- `.github/instructions/`: instruções do Copilot por caminho.

## Estrutura principal

Convenção de pastas para código de aplicação — neste repositório-base, `apps/`
contém apenas os READMEs de referência mínima; os diretórios reais de código
(`src/`, `pom.xml` por serviço, `package.json` do app mobile) só existem a
partir do primeiro serviço/feature real que o projeto criar:

- `apps/backend/platform`: componentes de plataforma do backend (ex.: API Gateway).
- `apps/backend/services/<service>`: um microservice Java Spring Boot por bounded context. Veja [`apps/backend/README.md`](apps/backend/README.md) para o esqueleto de referência ("Item Service").
- `apps/backend/shared`: bibliotecas compartilhadas do backend, sem regra específica de um serviço.
- `apps/mobile-app`: aplicativo Ionic Angular. Veja [`apps/mobile-app/README.md`](apps/mobile-app/README.md) para o esqueleto de referência (feature "Items").
- `libs/frontend-common`: bibliotecas compartilhadas do frontend.
- `infra`: infraestrutura local e deploy (`docker-compose.yml` local, `docker-compose.prod.yml`, `.env.prod.example`, `deploy/`).
- `docs`: documentação do projeto (`stories/`, `implementation/`, auditorias e `env/`), conforme `.ai/structure/rules/documentation.md`.
- `.github/workflows`: workflows reais do projeto, criados a partir dos modelos em `.ai/structure/templates/` (CI, auditoria de dependências e deploy). Este repositório-base versiona apenas o `validate-ai-structure.yml`.

A lista de serviços e features reais de cada projeto fica em
`.ai/context/bounded-contexts.md`, não aqui — esta seção descreve a
convenção de pastas, não o inventário de um produto específico.

## Pipeline (CI, auditoria e deploy)

Modelos prontos para copiar e adaptar, com as regras em `.ai/structure/rules/ci.md` e `.ai/structure/rules/deploy.md`:

| Necessidade | Modelo |
|---|---|
| CI com gate de cobertura | `.ai/structure/templates/ci-workflow-template.md` |
| Auditoria de dependências | `.ai/structure/templates/dependency-audit-workflow-template.md` |
| Workflow de deploy | `.ai/structure/templates/deploy-workflow-template.md` |
| Scripts de deploy e runbook | `.ai/structure/templates/deploy-scripts-template.md` |

## Documentação do projeto

Story, relato de implementação, auditoria e migração de dados têm modelo próprio
(`story-template.md`, `implementation-report-template.md`, `audit-report-template.md`,
`data-migration-template.md`); ver `.ai/structure/rules/documentation.md`.

## Fluxo recomendado

1. Leia o ponto de entrada do agente.
2. Consulte as regras aplicáveis em `.ai/structure/rules/`.
3. Consulte o contexto em `.ai/context/`.
4. Use os papéis em `.ai/structure/agents/` para orientar implementação, revisão e arquitetura.
5. Use TDD sempre que houver regra de negócio.

## Configuracao de ambiente

- Template versionavel: `.env.example`.
- Arquivo local com segredos reais: `.env` (nao versionar).
- Referencia de manutencao: `docs/env/README.md`.
