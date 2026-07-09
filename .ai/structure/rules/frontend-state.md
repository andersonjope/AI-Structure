# Frontend State Context

## Objetivo

Definir um padrão mínimo para gerenciamento de estado no app Ionic Angular, evitando estado duplicado, stores globais desnecessárias e lógica de negócio pesada em páginas ou componentes.

Este contexto deve ser lido junto com:

- `.ai/structure/rules/ionic.md`
- `.ai/structure/rules/security.md`
- `.ai/structure/rules/performance.md`
- `.ai/structure/rules/testing.md`
- `.ai/structure/agents/ionic-specialist.md`

## Princípios

- Estado deve ficar o mais próximo possível da feature que o utiliza.
- Estado local simples pode ficar no componente quando não for compartilhado e não tiver regra de negócio.
- Estado compartilhado por uma feature deve ficar em services da própria feature.
- Estado compartilhado entre várias features deve ficar em `core` ou `data-access`, com contrato claro.
- Store global só deve ser criada quando houver necessidade comprovada de coordenação entre múltiplas features.
- Dados derivados devem ser calculados de forma explícita e testável, evitando duplicação.
- Fluxos assíncronos devem expor estados de loading, vazio e erro.

## Tipos de estado

### Estado local de UI

Use componente ou page quando o estado for transitório e não compartilhado.

Exemplos:

- Aba selecionada.
- Modal aberto/fechado.
- Campo de busca local.
- Ordenação visual local.

Regras:

- Não colocar regra de negócio complexa no componente.
- Não duplicar dados que já vêm de service.
- Não chamar API diretamente se existir camada `data-access`.

### Estado de feature

Use feature service quando o estado for compartilhado por telas/componentes da mesma feature.

Exemplos:

- Filtros de catálogo.
- Carrinho em construção.
- Dados do perfil carregados para edição.

Regras:

- Service deve expor API tipada.
- Estados assíncronos devem representar loading, success, empty e error.
- Evitar múltiplas chamadas HTTP repetidas para o mesmo dado.
- Testar regras de transformação e fluxos críticos.

### Estado de dados remotos

Use services em `data-access` para chamadas REST e modelos de integração.

Regras:

- Não espalhar URLs em componentes.
- Centralizar headers, autenticação e tratamento técnico de erro em interceptors quando aplicável.
- DTOs de API devem ser tipados.
- Converter DTOs para modelos de tela quando houver diferença relevante.

### Estado global

Criar apenas quando houver justificativa clara.

Critérios para considerar estado global:

- Autenticação e sessão.
- Preferências persistentes do usuário.
- Dados usados por múltiplas features independentes.
- Sincronização offline ou cache coordenado.

Antes de criar:

- Documentar por que feature service não basta.
- Definir estratégia de limpeza, invalidação ou expiração.
- Definir testes unitários para reducers/services/selectors equivalentes.
- Avaliar impacto de segurança quando envolver tokens ou dados sensíveis.

## Padrão mínimo para fluxos assíncronos

Todo fluxo assíncrono visível ao usuário deve tratar:

- Loading: operação em andamento.
- Empty: sucesso sem dados, quando aplicável.
- Success: dados carregados ou operação concluída.
- Error: falha com mensagem segura para o usuário.

Erros não devem expor stack trace, tokens, URLs internas sensíveis ou payloads sigilosos.

## Persistência no dispositivo

- Não armazenar token sensível em `localStorage` se houver alternativa mais segura.
- Dados persistidos devem ter finalidade clara.
- Dados sensíveis devem ser minimizados e removidos no logout.
- Cache local deve ter estratégia de invalidação.

## Testes esperados

- Unit tests para services que controlam estado de feature.
- Unit tests para transformação de DTOs em modelos de tela.
- Testes para loading, empty e error states em fluxos críticos.
- E2E apenas para fluxos principais como login, pedido e pagamento.

## Proibido

- Página com regra de negócio complexa.
- `HttpClient` diretamente em page quando houver camada `data-access`.
- Store global por conveniência sem justificativa.
- Estado duplicado em múltiplos componentes sem fonte única.
- `any` para estado ou DTO sem justificativa explícita.
