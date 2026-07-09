# AGENTS.md

## Perfil do projeto

Este é um monorepo profissional com microservices Java Spring Boot, MongoDB e aplicativo Ionic Angular.

Este arquivo é o ponto de entrada para Codex. Claude usa `CLAUDE.md` e GitHub Copilot usa `.github/copilot-instructions.md`, mas as regras, agentes, templates e contexto compartilhados ficam em `.ai/`.

## Antes de alterar arquivos

O Codex deve:

1. Entender o contexto do serviço, módulo ou app afetado.
2. Verificar as regras em `.ai/structure/rules/`.
3. Verificar o contexto em `.ai/context/`.
4. Verificar ADRs existentes antes de sugerir mudança arquitetural.
5. Criar plano antes de implementar alterações relevantes.
6. Usar TDD sempre que houver regra de negócio.
7. Preservar compatibilidade de APIs e eventos.
8. Não fazer refatorações grandes sem justificar impacto.

## Estrutura do monorepo

Backend:

- `apps/backend/platform`: componentes de plataforma e suporte operacional do backend.
- `apps/backend/services`: microservices organizados por bounded context.
- `apps/backend/shared`: bibliotecas compartilhadas do backend, sem regra específica de um serviço.

Frontend:

- `apps/mobile-app`: aplicativo Ionic Angular.
- `libs/frontend-common`: bibliotecas compartilhadas do frontend.
- Telas e mensagens do frontend devem seguir a regra de internacionalização em `.ai/structure/rules/ionic.md`.

Infraestrutura:

- `infra`: Docker, Kubernetes, Nginx e observabilidade.
- Artefatos Docker de microservices ficam em `apps/backend/services/<service>/infra/`.

## Regras obrigatórias

Para qualquer tarefa relevante:

1. Diagnóstico.
2. Plano curto.
3. Testes.
4. Implementação mínima.
5. Refatoração.
6. Revisão.
7. Resumo do que mudou.
8. Riscos e próximos passos.

## Papéis disponíveis

Use os arquivos em `.ai/structure/agents/` como especializações de trabalho:

- `domain-designer`
- `tdd-developer`
- `code-reviewer`
- `api-designer`
- `refactor-guard`
- `microservice-architect`
- `mongodb-specialist`
- `ionic-specialist`
- `security-reviewer`
- `observability-engineer`
- `performance-engineer`
- `devops-engineer`

Antes de usar um papel, consulte também `.ai/structure/agents/README.md`, que contém o roteamento por tipo de tarefa, checklists operacionais e critérios de pronto.

## Roteamento de agentes por tarefa

Use esta matriz para escolher os papéis mínimos necessários:

- Nova regra de negócio: `domain-designer` -> `tdd-developer` -> `code-reviewer`.
- Novo microservice: `microservice-architect` -> `domain-designer` -> `api-designer` -> `tdd-developer` -> `security-reviewer` -> `observability-engineer`.
- Nova API REST ou alteração de contrato: `api-designer` -> `security-reviewer` -> `tdd-developer` -> `code-reviewer`.
- Persistência MongoDB: `mongodb-specialist` -> `performance-engineer` -> `tdd-developer`.
- Integração entre serviços: `microservice-architect` -> `api-designer` -> `observability-engineer` -> `security-reviewer`.
- Frontend Ionic Angular: `ionic-specialist` -> `tdd-developer` -> `performance-engineer`.
- Infraestrutura, Docker, CI/CD ou deploy: `devops-engineer` -> `security-reviewer` -> `observability-engineer`.
- Refatoração relevante: `refactor-guard` -> `code-reviewer` -> `tdd-developer`.

Se a tarefa envolver mais de uma área, combine os fluxos e priorize o contexto dono da regra de negócio.

## Regras por área

Sempre consulte os arquivos relevantes em `.ai/structure/rules/`, principalmente:

- `architecture.md`
- `api-contracts.md`, sempre que houver API REST, formato de erro ou contrato consumido por outro cliente.
- `ddd.md`
- `tdd.md`
- `clean-code.md`
- `microservices.md`
- `spring-boot.md`
- `mongodb.md`
- `ionic.md`
- `i18n.md`, sempre que houver texto visível ao usuário, idioma, tradução ou mensagem de erro no frontend.
- `security.md`
- `observability.md`
- `performance.md`
- `testing.md`
- `git-workflow.md`
- `standard-fields.md`, sempre que houver CPF, CNPJ, CEP ou telefone.

## Definition of Done

Para considerar uma implementação pronta, o Codex deve registrar:

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
