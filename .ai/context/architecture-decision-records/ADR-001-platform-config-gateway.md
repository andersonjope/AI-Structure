<!-- TEMPLATE:EXEMPLO -->
# ADR-001 - API Gateway autonomo na plataforma backend

> **Exemplo ilustrativo.** Este é um ADR real de um projeto de referência
> (AgendaHub), mantido aqui como exemplo de como preencher
> `.ai/structure/templates/adr-template.md`. Ao iniciar um projeto novo,
> remova este ADR e crie os ADRs reais do seu produto conforme as decisões
> forem tomadas.

## Status

Aceito

## Contexto

O backend do monorepo precisa iniciar pela entrada HTTP do aplicativo mobile sem depender de outro projeto ou componente de plataforma ainda nao necessario.

As regras do projeto exigem `application.yml`, segredos via variaveis de ambiente, health checks e preservacao de contratos entre servicos.

## Decisao

Criar apenas o componente `api-gateway` em `apps/backend/platform`.

O gateway usa Spring Cloud Gateway WebFlux com configuracao local em `src/main/resources/application.yml`.

As configuracoes de porta, JWT e observabilidade ficam no proprio `application.yml` do gateway usando placeholders de variaveis de ambiente.

Rotas para identity, catalog, order, payment ou outros servicos nao serao criadas ate que os servicos e seus contratos existam no monorepo.

## Consequencias

Positivas:

- Evita dependencia operacional de Config Server neste momento.
- Evita mapeamentos para servicos ainda inexistentes.
- Prepara a entrada unica do mobile por gateway sem acoplamento prematuro.
- Mantem configuracoes de plataforma fora dos dominios de negocio.

Negativas:

- Configuracoes compartilhadas precisarao ser revisitadas quando novos microservices forem criados.
- Rotas deverao ser adicionadas de forma incremental junto com contratos versionados.
- Um Config Server, GitOps ou Vault pode ser reavaliado depois para ambientes produtivos.

## Data

2026-05-26
