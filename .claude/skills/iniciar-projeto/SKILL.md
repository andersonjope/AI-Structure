---
name: iniciar-projeto
description: Transforma este template em um projeto real - entrevista o usuario, registra as escolhas em .ai/project.md e aplica o catalogo .ai/structure/stacks.md (contexto de negocio, stack, regras, agentes, READMEs, env e pipeline). Usar uma unica vez, no inicio de um projeto novo criado a partir do template, ou ao reaplicar uma escolha de stack.
---

# Iniciar projeto

Transforma o repositório-base em um projeto. Fontes: `.ai/structure/stacks.md` (o que fica, sai ou muda por escolha),
`.ai/project.md` (manifesto das decisões) e `.ai/README.md` > "Portabilidade". Idioma de tudo que for escrito: **português (pt-BR)**.

A skill é **repetível**: o campo `aplicado` de `.ai/project.md` registra o que já foi feito; ao rodar de novo, ela retoma do que falta
e não duplica trabalho.

## Regras de ouro

- **Não inventar contexto de negócio.** O que o usuário não responder vira `TODO(contexto)` no arquivo e entra em "Pendências" do relatório final.
- **Plano antes de aplicar.** Nada é removido ou reescrito antes do usuário aprovar o plano.
- **Validar a cada remoção.** `bash scripts/validate-ai-structure.sh` após cada bloco; corrigir a causa (referência esquecida), nunca o validador.
- **Não commitar nem dar push** sem o usuário pedir.
- **Não tocar no que é Universal** (lista em `stacks.md`).

## Passo 0: pré-checagem

1. Ler `.ai/project.md`. Se `status: inicializado`, avisar que o projeto já foi iniciado e perguntar se é para **reaplicar uma escolha** (registrar ADR conforme o manifesto) ou encerrar.
2. `git status` e `git branch --show-current`:
   - árvore com alterações: pedir para commitar ou guardar antes;
   - na `main` do template: sugerir criar `projeto/<nome>` (conforme `README.md` > "Como usar este repositório...") e criar a branch se o usuário concordar.
3. Rodar `bash scripts/validate-ai-structure.sh`. Se falhar antes de começar, corrigir primeiro (skill `validar-estrutura`).
4. Marcar `status: em-andamento` em `.ai/project.md`.

## Passo 1: entrevista

Usar `AskUserQuestion` em rodadas curtas (até 4 perguntas por vez). Sempre inferir antes de perguntar (arquivos existentes, `git remote`, lockfiles).

**Rodada A: produto**
- Nome do projeto (slug em kebab-case), problema que resolve e para quem.
- Quem são os usuários/papéis e quais os 2 a 5 contextos de negócio iniciais (bounded contexts).
- Existem integrações externas já conhecidas (pagamento, e-mail, ERP...)?

**Rodada B: arquitetura e stack** (opções de `stacks.md`)
- Estilo: microservices ou monólito modular.
- Backend: Spring Boot, NestJS ou nenhum.
- Frontend: Ionic Angular, Angular (web) ou nenhum.
- Banco: MongoDB ou outro.
- Gerenciador de pacotes/build (Maven, Gradle, pnpm, npm, yarn).

**Rodada C: entrega**
- CI: GitHub Actions ou outro.
- Deploy: VPS com Docker Compose, outro destino ou nenhum por enquanto.
- Registry e branch de produção.

Para cada escolha, fazer também as perguntas da seção "Pergunte" correspondente de `stacks.md`. Gravar as respostas em `.ai/project.md` (sem segredos).

## Passo 2: plano

Montar, a partir de `stacks.md`, a lista exata de:
- **arquivos a remover** (rules, agentes, templates, pastas);
- **arquivos a reescrever** (`.ai/context/*` com `TEMPLATE:EXEMPLO`, READMEs de `apps/` com `TEMPLATE:ESQUELETO`, entradas de IA);
- **arquivos a adaptar** (trechos de stack em rules, agentes, `.github/instructions`, `.claude/settings.json`);
- **arquivos a gerar** (pipeline, `.env.example`, compose, ADRs necessárias).

Apresentar o plano agrupado por etapa e esperar a aprovação explícita. Ajustar conforme o feedback.

## Passo 3: aplicar, por etapa

Registrar cada etapa concluída em `aplicado` (nomes em `.ai/project.md`). Após cada uma, rodar o validador.

1. **`contexto-negocio`**: reescrever `.ai/context/` com as respostas e remover o marcador `TEMPLATE:EXEMPLO` e o aviso "Exemplo ilustrativo":
   - `business-context.md`, `bounded-contexts.md`, `ubiquitous-language.md` (termos do domínio do usuário), `integration-map.md`, `architecture-overview.md`, `non-functional-requirements.md`.
   - Remover as ADRs de exemplo (`ADR-001`, `ADR-002` do template) e criar ADRs reais com a skill `nova-adr` para as decisões já tomadas (estilo de arquitetura, banco, gerenciador de pacotes, deploy).
   - Onde o usuário não deu informação: `TODO(contexto)`, nunca texto inventado.
2. **`estilo-arquitetura`**, **`stack-backend`**, **`stack-frontend`**, **`banco`**: aplicar **Mantém / Remove / Renomeia / Adapta** das seções escolhidas de `stacks.md`
   (inclui o estilo de arquitetura: monólito modular remove `microservices.md`/`microservice-template.md` e renomeia `microservice-architect` para `software-architect`).
   - Ao remover agente ou rule, limpar rosters (`CLAUDE.md`, `AGENTS.md`), tabela e checklists de `.ai/structure/agents/README.md`, linhas de roteamento e `.github/*`.
   - Ao renomear agente (Angular sem Ionic), seguir os passos de `stacks.md` e conferir com `grep -rn "<slug-antigo>"`.
3. **`entradas-ia`**: atualizar o perfil e a stack em `CLAUDE.md`, `AGENTS.md` e `.github/copilot-instructions.md` (sem mexer na estrutura de regras, papéis e Definition of Done), mais `.github/instructions/*.instructions.md` e permissões do gerenciador escolhido em `.claude/settings.json`.
4. **`readmes-apps`**: reescrever `apps/backend/README.md` e `apps/mobile-app/README.md` (ou o nome do app) para o esqueleto real, ou remover a pasta se a stack não se aplica; remover `TEMPLATE:ESQUELETO`.
5. **`env-infra`**: ajustar `.env.example`, `docs/env/README.md`, `infra/docker-compose.yml`, `infra/docker-compose.prod.yml`, `infra/.env.prod.example`, `.gitignore` e `.dockerignore` à stack e aos serviços reais (nomes de serviço, URIs, portas). Nada de segredo.
6. **`pipeline`**: se houver CI/deploy, chamar a skill `pipeline-ci-deploy` já com as respostas de `project.md` (não perguntar de novo). Se não houver deploy, seguir "Sem deploy no início" de `stacks.md`.
7. **`marcadores-removidos`**: marcar `status: inicializado` em `.ai/project.md` **antes** de validar e rodar o validador. Ele falha listando, por escolha, os termos de stack
   não escolhida e do produto de exemplo que ainda restam (seção "Termos residuais" de `stacks.md`), mais os marcadores `TEMPLATE:`. Reescrever esses trechos
   (isso é trabalho de leitura e edição, não de busca e troca cega) e repetir até passar. Menção intencional: `<!-- ok-stack -->` na linha, ou `EXCLUIR` no catálogo
   para documentos que citam várias stacks de propósito (pipeline).

## Passo 4: fechamento

1. `bash scripts/validate-ai-structure.sh` passando; registrar `validado` em `aplicado`.
2. Se tudo concluído: `status: inicializado`. Se sobraram pendências: manter `em-andamento`.
3. Relatório final ao usuário:
   - escolhas registradas;
   - arquivos removidos, reescritos, adaptados e gerados (agrupados);
   - **pendências** (`TODO(contexto)`, secrets a cadastrar, decisões sem ADR);
   - o que **não foi validado/executado** (workflows, deploy, build);
   - próximos passos: primeira story (skill `nova-story`) e primeiro serviço/feature por TDD.
4. Perguntar se o usuário quer commitar (sem atribuição de ferramenta de IA).

## Proibido

- Inventar regra de negócio, bounded context, integração ou ADR sem decisão do usuário.
- Remover arquivo Universal ou enfraquecer regra de segurança/teste para "simplificar".
- Deixar referência quebrada, agente órfão, marcador de template ou termo residual ao declarar `inicializado`.
- Silenciar o validador (`ok-stack`, `EXCLUIR`) para esconder texto que deveria ser reescrito.
- Executar deploy, push, cadastro de secrets ou instalação de dependências sem o usuário pedir.
