# Testing Rules

## Pirâmide de testes

Prioridade:

1. Muitos testes unitários.
2. Alguns testes de integração.
3. Poucos testes end-to-end.

## Backend

Usar:

- JUnit 5.
- AssertJ.
- Mockito.
- Testcontainers.
- Spring Boot Test apenas quando necessário.

## Frontend Ionic

Usar:

- Unit tests para services e componentes relevantes.
- Testes de integração para fluxos críticos.
- E2E para login, pedido, pagamento e fluxos principais.

## Cobertura mínima

- Todo módulo implantável tem **limite mínimo de cobertura** configurado na ferramenta de teste, para falhar igual local e no CI:
  - Java: JaCoCo com `check` (regra `LINE` e `BRANCH`, `COVEREDRATIO`) na fase `verify`.
  - Jest: `coverageThreshold` global em `jest.config.js`.
  - Karma/Angular: `coverageReporter.check.global`.
- Unitários e integração rodam numa execução, com cobertura combinada; percentuais de suítes separadas não se somam.
- Medir as quatro métricas (linhas, instruções, funções, ramificações). Linha alta com ramificação baixa esconde caminhos de erro sem teste.
- Começar no nível real do projeto e só subir; meta de referência: 90%.
- Baixar o limite exige justificativa registrada (auditoria ou ADR); nunca ajuste silencioso para o CI passar.
- Cobertura não substitui cenário: regra de negócio, concorrência e valores nulos precisam de teste que **falha** sem a correção.
- CI e artefato do relatório: `.ai/structure/rules/ci.md`.

## Migração de dados

- Toda migração tem teste contra banco real de teste: formato antigo migra, formato novo não muda, valor inválido é ignorado e contado, segunda execução não altera.
- Dados de teste devem ser criados pelo caminho real da aplicação (endpoint/caso de uso); dados semeados direto no banco escondem defeitos de tipo e mapeamento.
- Modelo: `.ai/structure/templates/data-migration-template.md`.

## Contratos

Entre microservices:

- Documentar contrato.
- Testar compatibilidade.
- Versionar eventos e APIs.

## Proibido

- Teste frágil baseado em detalhe interno.
- Ignorar teste quebrado.
- Teste sem assert.
- E2E cobrindo tudo quando unit test resolveria.
