---
name: pipeline-ci-deploy
description: Adapta os templates de CI, auditoria de dependências e deploy para o projeto, gerando .github/workflows e infra/deploy. Usar ao configurar ou portar o pipeline de CI/CD de um projeto novo ou existente.
---

# Pipeline de CI, auditoria e deploy

Regras: `.ai/structure/rules/ci.md`, `deploy.md`, `docker.md`, `security.md`. Papéis: `devops-engineer` → `security-reviewer` → `observability-engineer`.

Modelos:
- `.ai/structure/templates/ci-workflow-template.md`
- `.ai/structure/templates/dependency-audit-workflow-template.md`
- `.ai/structure/templates/deploy-workflow-template.md`
- `.ai/structure/templates/deploy-scripts-template.md`

## Passos

1. **Descobrir o projeto** antes de perguntar: gerenciador de pacotes (`pnpm-lock.yaml`, `pom.xml`...), scripts de lint/build/teste, módulos implantáveis, Dockerfiles existentes, branch de produção (`git branch`), nome do workflow de CI.
2. **Perguntar só o que não deu para inferir**: ecossistema alvo do deploy (VPS ou outro), registry, serviços publicados, contexto de build, prefixos de rota extras, limite de cobertura.
3. **Pré-requisitos**: conferir o checklist do template (Dockerfile multi-stage, `docker-compose.prod.yml` com `${IMAGE_TAG}` e `healthcheck`, `.env.prod.example` com `PREENCHER`, ambiente `production`). Listar o que falta; não gerar o que depende de decisão do usuário.
4. **Gerar os arquivos** substituindo todos os placeholders `<...>`:
   - `.github/workflows/ci.yml` (nome estável, é referenciado pelo deploy);
   - `.github/workflows/dependency-audit.yml`;
   - `.github/workflows/deploy.yml`;
   - `infra/deploy/deploy-remote.sh`, `update-remote.sh` e `README.md`.
   Os scripts devem sair executáveis (`chmod +x`).
5. **Gate de cobertura**: confirmar que o limite está na ferramenta de teste do projeto; se não está, propor a configuração (não baixar nem inventar limite sem registrar).
6. **Validar sem executar o deploy**: sintaxe YAML, `bash -n` nos scripts, `docker compose -f infra/docker-compose.prod.yml config`, nenhum placeholder `<...>` restante (`grep -rn '<[A-Z_]*>' .github infra`).
7. Informar os **secrets** que o usuário precisa cadastrar no ambiente `production` e que o primeiro deploy falhará de propósito até o `.env` da VPS ser preenchido. Recomendar validar com `workflow_dispatch` e testar o rollback com health check quebrado.
8. Se divergir do padrão (outro registry, Kubernetes), sugerir a skill `nova-adr`.

## Proibido

- Executar deploy, `git push` ou cadastrar secrets.
- Gerar valor real de segredo ou token.
- Compilar na VPS (`up --build`).
