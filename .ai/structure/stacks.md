# Catálogo de Stacks

Mapa declarativo entre **escolhas de projeto** e **o que fica, sai ou muda** neste template.
É a fonte que a skill `iniciar-projeto` consulta (e que uma pessoa pode seguir à mão) ao
transformar o repositório-base em um projeto. Se a estrutura do template mudar, atualizar este
arquivo no mesmo PR.

## Como usar

1. Registrar as escolhas em `.ai/project.md`.
2. Para cada escolha, aplicar a seção correspondente abaixo: **Mantém**, **Remove**, **Adapta**.
3. Após cada remoção, rodar `bash scripts/validate-ai-structure.sh`. Link quebrado ou agente órfão
   indica referência que faltou limpar; corrigir a causa, não o validador.
4. Nunca remover o que está em "Universal".

Idioma da documentação: **português (pt-BR)**. Os arquivos do template já estão em português, com
trechos em inglês em algumas rules e em `.github/`; ao iniciar um projeto, manter o que existe e escrever
todo conteúdo novo em português.

## Marcadores no template

| Marcador | Significado | Ação ao iniciar o projeto |
|---|---|---|
| `<!-- TEMPLATE:EXEMPLO -->` | Conteúdo de um produto de exemplo (AgendaHub) | **Reescrever** a partir do contexto real e remover o marcador e o aviso "Exemplo ilustrativo" |
| `<!-- TEMPLATE:ESQUELETO -->` | Referência de stack (READMEs de `apps/`, `docs/env`) | **Adaptar** à stack escolhida, ou remover se a stack não se aplica; depois remover o marcador |

Verificação: `grep -rn "TEMPLATE:" . --include=*.md` não deve retornar nada ao fim da inicialização.
Termos do produto de exemplo (`AgendaHub` e os nomes de serviço de exemplo) também não devem restar; o validador confere
(ver "Termos residuais").

## Universal (nunca remover)

- Agentes: `domain-designer`, `tdd-developer`, `code-reviewer`, `api-designer`, `security-reviewer`,
  `observability-engineer`, `performance-engineer`, `devops-engineer`, `refactor-guard`.
  O agente `microservice-architect` também permanece, mas muda de nome conforme o estilo de arquitetura (ver abaixo).
- Rules: `architecture`, `clean-code`, `ddd`, `tdd`, `testing`, `security`, `observability`, `performance`,
  `api-contracts`, `git-workflow`, `documentation`, `standard-fields`, `ci`, `docker`.
- Templates: `adr`, `aggregate`, `value-object`, `domain-event`, `usecase`, `rest-api`, `event-contract`,
  `test-plan`, `pull-request`, `story`, `implementation-report`, `audit-report`, `data-migration`,
  `ci-workflow`, `dependency-audit-workflow`.
- Entradas de IA: `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`.
- Validação: `scripts/validate-ai-structure.sh` e seu workflow.

Pontos que citam várias stacks como opção (ex.: `ci.md`, `ci-workflow-template.md`,
`dependency-audit-workflow-template.md`, `deploy.md`) permanecem; a skill apenas confirma que o exemplo da stack
escolhida está presente.

---

## Estilo de arquitetura

### Microservices

**Mantém**: agente `microservice-architect`, rule `.ai/structure/rules/microservices.md` e template
`.ai/structure/templates/microservice-template.md`.

### Monólito modular

**Remove**
- Rule `.ai/structure/rules/microservices.md` e template `.ai/structure/templates/microservice-template.md`.
- As linhas que os citam em `.ai/structure/agents/README.md` e nos agentes `microservice-architect`, `mongodb-specialist`,
  `performance-engineer`, `observability-engineer` e `devops-engineer` (`grep -rn "microservice-template\|rules/microservices"`).

**Renomeia** (agente de arquitetura): `microservice-architect` → `software-architect`
1. Renomear `.ai/structure/agents/microservice-architect.md` para `software-architect.md` e reescrever o papel para módulos,
   fronteiras entre módulos e evolução do monólito (sem serviços independentes, gateway ou banco por serviço).
2. Atualizar o slug em `CLAUDE.md` (lista de papéis e roteamento), `AGENTS.md`, `.github/copilot-instructions.md`,
   `.ai/structure/agents/README.md` e demais citações (`grep -rn "microservice-architect"`).
3. Rodar o validador: ele confirma roster, matriz e arquivo.

**Adapta** (trechos de "microservice(s)" para "módulo(s)" ou removidos, conforme o contexto):
`.ai/structure/rules/architecture.md`, `ddd.md`, `api-contracts.md`, `observability.md`, `performance.md`, `mongodb.md`,
`docker.md`, `testing.md`; agentes `api-designer`, `refactor-guard`; `apps/backend/README.md` (esqueleto por módulo, sem
`services/`); `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md` e `.github/instructions/backend.instructions.md`
(layout `apps/backend/services` → `apps/backend/src/<modulo>`); `.ai/context/*` (já reescritos pela inicialização).

**Pergunte**: lista de módulos e dependências permitidas entre eles; se haverá extração futura para serviços.

---

## Backend

### Spring Boot (Java)

**Mantém**
- Rule `.ai/structure/rules/spring-boot.md`.
- Rule `.ai/structure/rules/microservices.md` e template `.ai/structure/templates/microservice-template.md` (se a arquitetura for de microservices).

**Remove**
- Rule `.ai/structure/rules/nestjs.md`.

**Adapta**
- `apps/backend/README.md` (esqueleto Spring: renomear serviço de exemplo para o contexto real).
- `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`: seção de stack e perfil do projeto.
- `.github/instructions/backend.instructions.md`: `applyTo` e regras listadas.
- `.ai/structure/agents/README.md` e agentes `code-reviewer`, `devops-engineer`, `domain-designer`, `observability-engineer`, `refactor-guard`: trechos específicos de Java/Spring, se houver.
- `.ai/structure/rules/testing.md` (JUnit/AssertJ/Mockito/Testcontainers) e `docker.md` (seções Java).

- `.ai/structure/rules/mongodb.md`: remover os trechos de Mongoose/NestJS.
- `README.md` raiz e `.ai/README.md`: descrições da stack do template.

**Pergunte**: Java e Spring Boot (versões), Maven ou Gradle, microservices ou monólito modular, comunicação síncrona e assíncrona.

### NestJS (Node/TypeScript)

**Mantém**
- Rule `.ai/structure/rules/nestjs.md`.

**Remove**
- Rule `.ai/structure/rules/spring-boot.md`.
- Template `.ai/structure/templates/microservice-template.md` se for monólito modular; manter e adaptar (campos de stack) se forem microservices.
- Rule `.ai/structure/rules/microservices.md` se for monólito modular.

**Adapta**
- `apps/backend/README.md`: reescrever o esqueleto para módulos NestJS (`src/<modulo>`).
- `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`: trocar "Java/Spring" por "NestJS/TypeScript" (perfil, stack e proibições).
- `.github/instructions/backend.instructions.md`: `applyTo` para `apps/backend/**/*.ts` e regra `nestjs.md` no lugar de `spring-boot.md`; remover itens específicos de Spring.
- `.ai/structure/rules/testing.md`: seção Backend trocando JUnit/AssertJ/Mockito/Testcontainers por Jest, `@nestjs/testing` e `supertest`.
- `.ai/structure/rules/docker.md`: seções de Dockerfile Java trocadas por Node (multi-stage, usuário não-root, JRE → Node alpine).
- `.ai/structure/rules/architecture.md` e `mongodb.md`: manter apenas o trecho da stack escolhida (Mongoose).
- Agentes `code-reviewer`, `devops-engineer`, `domain-designer`, `observability-engineer`, `refactor-guard` e `.ai/structure/agents/README.md`: trechos de Java/Spring/Maven.
- `.ai/structure/rules/tdd.md`: exemplos de nomes de teste em Java.
- `docs/env/README.md`: remover "Como carregar o `.env` com Spring Boot" e comandos `mvn`; documentar o carregamento do `.env` com `ConfigModule`.
- `README.md` raiz e `.ai/README.md`: descrições da stack do template.
- `.claude/settings.json`: manter só as permissões do gerenciador escolhido.
- `package.json`/workspace: ver "Gerenciador de pacotes".

**Pergunte**: versão do Node, gerenciador de pacotes (pnpm, npm, yarn), módulos do domínio, monólito modular ou microservices.

---

## Frontend

### Ionic Angular

**Mantém**
- Rules `.ai/structure/rules/ionic.md`, `.ai/structure/rules/frontend-state.md`, `.ai/structure/rules/i18n.md`.
- Agente `.ai/structure/agents/ionic-specialist.md`.
- `.github/instructions/frontend.instructions.md`.

**Remove**
- Rule `.ai/structure/rules/angular.md` (o `ionic.md` cobre o caso Ionic).

**Adapta**
- `apps/mobile-app/README.md`: renomear a feature de exemplo ("Items") para a funcionalidade real.
- `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`: perfil, stack e roteamento do frontend.

**Pergunte**: nome do app, plataformas (web, Android, iOS via Capacitor), idiomas suportados.

### Angular (web, sem Ionic)

**Mantém**
- Rules `.ai/structure/rules/angular.md`, `.ai/structure/rules/frontend-state.md`, `.ai/structure/rules/i18n.md`.

**Remove**
- Rule `.ai/structure/rules/ionic.md`.

**Renomeia** (agente de frontend): `ionic-specialist` → `angular-specialist`
1. Renomear `.ai/structure/agents/ionic-specialist.md` para `angular-specialist.md` e trocar "Ionic" por "Angular" no conteúdo (papel, regra lida: `angular.md`).
2. Atualizar o slug em `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/frontend.instructions.md`, `.ai/structure/agents/README.md` (tabela, checklist e seção), nas linhas de roteamento e nos demais arquivos que o citem (`grep -rn "ionic-specialist"`).
3. Rodar o validador: ele confirma roster, matriz e arquivo.

**Adapta**
- `apps/mobile-app/README.md`: renomear a pasta e o README para `apps/web-app` (ou nome do projeto) e reescrever o esqueleto sem `ion-*`.
- `.ai/structure/rules/frontend-state.md`, `i18n.md` e `performance.md`: remover menções a Ionic/mobile quando houver.
- `.github/instructions/frontend.instructions.md`: `applyTo` e regra `angular.md`.
- Seções "Ionic" de `standard-fields.md`, `testing.md`, `performance.md` e `docker.md` (Dockerfile do frontend): trocar por Angular.
- `docs/env/README.md` (seção Frontend), `README.md` raiz e `.ai/README.md`.

**Pergunte**: nome do app, necessidade de SSR/SEO, idiomas.

### Sem frontend

**Remove**
- Rules `ionic.md`, `angular.md`, `frontend-state.md`, `i18n.md`; agente `ionic-specialist` (com limpeza dos rosters e do roteamento); `.github/instructions/frontend.instructions.md`; pasta `apps/mobile-app`.

**Adapta**
- Remover as linhas de roteamento de "Frontend ..." em `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md` e `.ai/structure/agents/README.md`.
- `performance-engineer` e `code-reviewer`: retirar verificações de frontend.
- Seções de frontend em rules universais: `standard-fields.md` ("Frontend Ionic Angular"), `testing.md` ("Frontend Ionic"),
  `performance.md` ("Ionic"), `docker.md` (Dockerfile do frontend, `apps/mobile-app` e porta 4200 na tabela de composes).
- `docs/env/README.md` (seção Frontend), `README.md` raiz e `.ai/README.md`.
- `.gitignore`/`.dockerignore`: pode manter as entradas (`.angular/`, `www/`), são inofensivas.

---

## Banco de dados

### MongoDB

**Mantém**: rule `.ai/structure/rules/mongodb.md` e agente `mongodb-specialist`; template `data-migration-template.md`; `infra/docker-compose.yml`.

**Adapta**: manter somente a seção do mapeamento da stack escolhida (Spring Data MongoDB ou Mongoose) em `mongodb.md`; ajustar URIs em `.env.example` e `docs/env/README.md`.

### Outro banco

**Remove**: `mongodb.md`, agente `mongodb-specialist` (limpar rosters e roteamento "Persistência MongoDB"), a imagem `mongo` de `infra/docker-compose.yml`.

**Cria**: rule do banco escolhido (`.ai/structure/rules/<banco>.md`) e agente equivalente, se o projeto precisar; o template `data-migration-template.md` permanece (a estratégia de idempotência vale para qualquer banco).

---

## Deploy e CI

| Escolha | Faz |
|---|---|
| VPS com Docker Compose + GitHub Actions | Mantém `deploy.md`, `deploy-workflow-template.md`, `deploy-scripts-template.md` e `infra/docker-compose.prod.yml`; usa a skill `pipeline-ci-deploy` |
| Outro destino (Kubernetes, serviço gerenciado) | Remove os templates de deploy; mantém `ci.md`; registrar ADR com o padrão de deploy escolhido e escrever `deploy.md` conforme o destino |
| Sem deploy no início | Remove `deploy.md` e templates de deploy **depois** de limpar as referências em `devops-engineer.md` e `agents/README.md`; manter `ci.md` |
| Outro provedor de CI | Registrar ADR; adaptar `ci-workflow-template.md` e `dependency-audit-workflow-template.md` |

## Gerenciador de pacotes (monorepo)

Registrar em `.ai/project.md` e propagar para `ci.md`, os templates de CI/auditoria, `docs/env/README.md` e
`.claude/settings.json` (permissões `Bash(...)` do gerenciador escolhido). Para pnpm em monorepo, registrar uma
ADR (workspace, lockfile único, contexto de build do Docker na raiz).

---

## Checagem final da inicialização

- `bash scripts/validate-ai-structure.sh` passa.
- `grep -rn "TEMPLATE:" . --include=*.md` vazio.
- Nenhum termo de stack não escolhida nem do produto de exemplo restante: o validador confere as linhas `TERMOS` da seção
  "Termos residuais" (com `status: inicializado`).
- `.ai/project.md` com `status: inicializado` e a lista `aplicado` completa.
- Rosters de `CLAUDE.md`/`AGENTS.md` coerentes com `.ai/structure/agents/`.

---

## Termos residuais (lidos pelo validador)

Com `status: inicializado` em `.ai/project.md`, o `scripts/validate-ai-structure.sh` procura, sem diferenciar maiúsculas,
os termos abaixo nos arquivos de texto do repositório e falha se algum restar. Cada linha `TERMOS` vale quando o campo
de `.ai/project.md` tem o valor indicado (`sempre` vale sempre; `outro` vale para qualquer valor que comece com `outro`).
Cada linha `EXCLUIR` isenta um caminho (arquivo ou pasta, por prefixo): são os documentos que citam várias stacks de propósito.
Linhas de texto com o comentário `<!-- ok-stack -->` também são ignoradas, para menções intencionais.

Atualizar estas linhas junto com as seções acima.

```text
TERMOS backend=nestjs :: spring|junit|mockito|assertj|pom\.xml|\bmaven\b|\bjava\b|\.java\b|\bmvn\b|jackson
TERMOS backend=spring-boot :: nestjs|@nestjs|nest\.js|class-validator|ts-jest|mongoose
TERMOS backend=nenhum :: spring|junit|mockito|assertj|pom\.xml|\bmaven\b|\bjava\b|\.java\b|\bmvn\b|jackson|nestjs|@nestjs|class-validator|mongoose
TERMOS frontend=nenhum :: ionic|mobile-app|angular
TERMOS frontend=angular :: ionic|ion-
TERMOS estilo=monolito-modular :: microservice|microsservi
TERMOS banco=outro :: mongo
TERMOS exemplo=sempre :: agendahub|(identity|company|client|catalog|order|scheduling|email)[-_ ]service|(identity|company|client|catalog|order|scheduling)_mongodb

EXCLUIR .ai/structure/stacks.md
EXCLUIR .ai/project.md
EXCLUIR .ai/structure/rules/ci.md
EXCLUIR .ai/structure/rules/deploy.md
EXCLUIR .ai/structure/templates/ci-workflow-template.md
EXCLUIR .ai/structure/templates/dependency-audit-workflow-template.md
EXCLUIR .ai/structure/templates/deploy-workflow-template.md
EXCLUIR .ai/structure/templates/deploy-scripts-template.md
EXCLUIR .github/workflows/
EXCLUIR .claude/
EXCLUIR scripts/
EXCLUIR .gitignore
EXCLUIR .dockerignore
```
