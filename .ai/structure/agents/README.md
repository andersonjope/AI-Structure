# Agents Operational Playbook

Este arquivo orienta Claude, Codex e GitHub Copilot sobre quando usar cada agente especializado e como transformar os papéis em execução prática.

## Como usar

1. Identifique o bounded context, serviço, app ou camada afetada.
2. Leia o contexto em `.ai/context/`.
3. Leia as regras aplicáveis em `.ai/structure/rules/`.
4. Escolha os agentes pela matriz de roteamento.
5. Use os templates de `.ai/structure/templates/` quando criar contratos, ADRs, microservices, eventos, use cases ou planos de teste.
6. Execute a menor implementação que atenda ao objetivo.
7. Valide com testes e revise riscos antes de concluir.

Quando o contexto de negócio estiver incompleto, não invente regra crítica. Registre a premissa usada ou peça esclarecimento antes de implementar comportamento irreversível.

## Matriz de roteamento

| Tipo de tarefa | Agentes obrigatórios | Agentes opcionais |
|---|---|---|
| Nova regra de negócio | `domain-designer`, `tdd-developer`, `code-reviewer` | `security-reviewer`, `performance-engineer` |
| Novo microservice | `microservice-architect`, `domain-designer`, `api-designer`, `tdd-developer`, `security-reviewer`, `observability-engineer` | `mongodb-specialist`, `devops-engineer`, `performance-engineer` |
| Nova API REST ou alteração de contrato | `api-designer`, `security-reviewer`, `tdd-developer`, `code-reviewer` | `observability-engineer`, `performance-engineer` |
| Persistência MongoDB | `mongodb-specialist`, `performance-engineer`, `tdd-developer` | `security-reviewer` |
| Integração entre serviços | `microservice-architect`, `api-designer`, `observability-engineer`, `security-reviewer` | `performance-engineer`, `devops-engineer` |
| Frontend Ionic Angular | `ionic-specialist`, `tdd-developer`, `performance-engineer` | `security-reviewer` |
| Infraestrutura, Docker, CI/CD ou deploy | `devops-engineer`, `security-reviewer`, `observability-engineer` | `performance-engineer` |
| Refatoração relevante | `refactor-guard`, `code-reviewer`, `tdd-developer` | `domain-designer`, `api-designer` |
| Revisão de código | `code-reviewer` | Qualquer especialista da área alterada |

## Checklists por agente

### domain-designer

Ler:

- `.ai/context/business-context.md`
- `.ai/context/bounded-contexts.md`
- `.ai/context/ubiquitous-language.md`
- `.ai/structure/rules/ddd.md`
- `.ai/structure/rules/architecture.md`

Validar:

- Contexto dono da regra.
- Invariantes protegidas no domínio.
- Value objects necessários.
- Eventos de domínio no passado.
- Ausência de Spring, MongoDB, HTTP, Kafka e Jackson no domínio.

Saída mínima:

- Modelo sugerido ou alterado.
- Invariantes.
- Testes de domínio necessários.
- Premissas de negócio.

### tdd-developer

Ler:

- `.ai/structure/rules/tdd.md`
- `.ai/structure/rules/testing.md`
- Regras da área afetada.

Validar:

- Cenários antes da implementação.
- Teste de domínio ou use case para regra de negócio.
- Teste de adapter apenas quando houver integração técnica relevante.
- Assert relevante em cada teste.

Comandos úteis:

- Backend completo: `mvn test`
- Módulo backend: `mvn -pl caminho/do/modulo test`
- Frontend: usar o comando definido no `package.json` do app afetado.

Saída mínima:

- Cenários cobertos.
- Testes criados ou atualizados.
- Comando executado e resultado.

### code-reviewer

Ler:

- Regras de arquitetura, clean code, testing, security, performance e observability.
- Arquivos alterados e testes relacionados.

Validar:

- Regra de negócio fora de controllers e repositories.
- Domínio sem dependência de infraestrutura.
- Contratos públicos preservados ou versionados.
- Erros sem vazamento de detalhes internos.
- Testes suficientes para o risco da mudança.

Saída mínima:

- Achados por severidade: Critical, Major, Minor, Suggestion.
- Arquivo e linha quando aplicável.
- Impacto e correção objetiva.

### api-designer

Ler:

- `.ai/structure/rules/api-contracts.md`
- `.ai/structure/rules/microservices.md`
- `.ai/structure/rules/security.md`
- `.ai/structure/rules/standard-fields.md`, quando houver CPF, CNPJ, CEP ou telefone.
- `.ai/structure/templates/rest-api-template.md`
- `.ai/context/integration-map.md`

Validar:

- Recurso REST com substantivo.
- Versionamento em APIs públicas.
- Request/response não vazam modelo interno.
- Status HTTP e erro padrão.
- Compatibilidade com clientes existentes.

Saída mínima:

- Endpoint, método, request, response, status codes e impactos de compatibilidade.

### microservice-architect

Ler:

- `.ai/context/architecture-overview.md`
- `.ai/context/bounded-contexts.md`
- `.ai/context/integration-map.md`
- ADRs em `.ai/context/architecture-decision-records/`
- `.ai/structure/rules/microservices.md`

Validar:

- Capacidade de negócio clara.
- Ownership de dados.
- Contratos explícitos.
- Dependências entre serviços.
- Necessidade de evento, API ou ambos.
- Risco de acoplamento síncrono em cascata.

Saída mínima:

- Contexto dono, dependências, contratos, eventos, riscos e ADR necessária.

### mongodb-specialist

Ler:

- `.ai/structure/rules/mongodb.md`
- `.ai/structure/rules/performance.md`
- Contexto do bounded context afetado.

Validar:

- Banco, schema lógico ou coleções com ownership exclusivo.
- Documento sem crescimento indefinido.
- Índices para queries críticas.
- TTL quando houver expiração natural.
- Ausência de join lógico entre bancos de serviços diferentes.

Saída mínima:

- Modelo documental, índices, queries críticas e riscos de escala.

### ionic-specialist

Ler:

- `.ai/structure/rules/ionic.md`
- `.ai/structure/rules/security.md`
- `.ai/structure/rules/performance.md`
- `.ai/structure/rules/testing.md`
- `.ai/structure/rules/standard-fields.md`, quando houver CPF, CNPJ, CEP ou telefone.
- `.ai/structure/rules/frontend-state.md`, para fluxos com estado compartilhado, cache ou store global.

Validar:

- Lazy loading por rota.
- Services tipados para API.
- Loading, empty e error states.
- Componentes focados.
- Ausência de `any` sem justificativa.

Saída mínima:

- Estrutura, componentes, services, rotas, otimizações e testes.

### security-reviewer

Ler:

- `.ai/structure/rules/security.md`
- Regras da área afetada.
- `.ai/structure/rules/standard-fields.md`, quando houver CPF, CNPJ, CEP ou telefone.

Validar:

- Autenticação aplicada em todas as APIs não públicas.
- Autorização por papel, escopo ou política.
- JWT: assinatura, issuer, audience e expiração validados.
- JWT: algoritmo `none` rejeitado; algoritmos restritos a permitidos (ex: `RS256`).
- JWT: access token com duração curta; refresh token com rotação quando aplicável.
- JWT: estratégia de revogação definida.
- APIs: rate limit em endpoints críticos.
- APIs: proteção contra brute force e enumeração de usuários.
- APIs: tamanho máximo de payload validado.
- APIs: endpoints administrativos com proteção adicional.
- Segredos fora do código e não versionados.
- Logs sem senha, token, Authorization header ou dado sensível.
- Erros sem stack trace para cliente.
- Banco: usuário da aplicação sem privilégio de administrador.
- Banco: queries parametrizadas, sem risco de injection.
- Dependências: vulnerabilidades verificadas.
- Credenciais distintas por ambiente.

Saída mínima:

- Vulnerabilidade, severidade, impacto e correção recomendada.

### observability-engineer

Ler:

- `.ai/structure/rules/observability.md`
- `.ai/context/non-functional-requirements.md`

Validar:

- Health checks mínimos.
- CorrelationId em requests e chamadas externas.
- Logs estruturados para fluxos críticos.
- Métricas de latência, erro e throughput.
- Tracing em integrações entre serviços quando aplicável.

Saída mínima:

- Logs, métricas, traces, dashboards e alertas sugeridos.

### performance-engineer

Ler:

- `.ai/structure/rules/performance.md`
- `.ai/context/non-functional-requirements.md`

Validar:

- Paginação em listagens.
- Payloads adequados.
- Índices para queries críticas.
- Ausência de chamadas síncronas em cascata sem necessidade.
- Cache apenas com justificativa e estratégia de invalidação.

Saída mínima:

- Gargalo, evidência, impacto, correção e como medir.

### devops-engineer

Ler:

- `.ai/structure/rules/git-workflow.md`
- `.ai/structure/rules/observability.md`
- `.ai/structure/rules/security.md`
- `.ai/context/non-functional-requirements.md`

Validar:

- Configuração por variável de ambiente.
- Health check por serviço.
- Build reproduzível.
- Imagens sem root quando possível.
- Separação de ambientes.
- Sem segredos versionados.

Saída mínima:

- Dockerfile, Compose, pipeline, variáveis, estratégia de deploy e riscos operacionais.

### refactor-guard

Ler:

- `.ai/structure/rules/architecture.md`
- `.ai/structure/rules/clean-code.md`
- `.ai/structure/rules/testing.md`
- ADRs relacionadas.

Validar:

- Escopo pequeno.
- Contrato público preservado.
- Testes protegendo comportamento.
- Refatoração realmente necessária.
- Estratégia de rollback.

Saída mínima:

- Risco, plano seguro, testes necessários e rollback.

## Contract and Event Testing

Use esta seção quando a tarefa criar ou alterar API pública, evento, integração entre microservices ou contrato consumido pelo mobile.

### Quando exigir contrato documentado

- Nova API REST pública ou interna entre serviços.
- Alteração de request, response, status code ou formato de erro.
- Novo evento publicado ou consumido.
- Alteração no payload, nome, versão ou semântica de evento existente.
- Nova chamada síncrona entre microservices.
- Nova dependência externa relevante.

### Regras para APIs

- Documentar endpoint, método, request, response, status codes, erro padrão, autenticação e autorização.
- Usar `.ai/structure/templates/rest-api-template.md`.
- Versionar breaking changes.
- Preservar compatibilidade quando houver cliente existente.
- Testar validação de entrada, sucesso, erro esperado e autorização quando aplicável.

### Regras para eventos

- Usar `.ai/structure/templates/event-contract-template.md`.
- Nomear eventos no passado, por exemplo `OrderCreated`.
- Versionar eventos públicos.
- Manter payload pequeno, estável e sem objeto interno gigante.
- Consumidores devem ser idempotentes.
- Evento não deve exigir leitura direta do banco de outro serviço.

### Testes esperados

- Unit tests para regras que geram ou consomem o contrato.
- Integration tests para adapters REST, consumers ou publishers quando houver lógica técnica relevante.
- Contract tests ou teste de compatibilidade quando outro serviço ou mobile consumir o contrato.
- Plano explícito quando contract test ainda não existir.

### Critérios de bloqueio

- Breaking change sem versionamento ou ADR.
- Evento sem versão quando tiver consumidor externo ao serviço.
- Contrato que exponha entidade interna como modelo público.
- Integração entre serviços sem timeout, observabilidade mínima ou tratamento de erro.
- Consumidor de evento não idempotente quando houver risco de reprocessamento.

## Definition of Done compartilhado

Toda entrega relevante deve informar:

1. Contexto, bounded context ou app afetado.
2. Agentes usados ou papéis considerados.
3. Regras `.ai/structure/rules/` consultadas.
4. ADRs avaliadas e se uma nova ADR foi necessária.
5. Cenários de teste considerados.
6. Testes criados, atualizados ou justificativa para não criar.
7. Comando de validação executado e resultado.
8. Impacto em APIs, eventos, dados, segurança, observabilidade e performance.
9. Arquivos alterados.
10. Riscos residuais e próximos passos.
