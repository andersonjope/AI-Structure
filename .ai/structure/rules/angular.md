# Angular Rules

Para aplicativo web Angular **sem** Ionic. Para Ionic Angular, ver `.ai/structure/rules/ionic.md`
(que complementa esta regra com componentes `ion-*`, layout e mobile).

## Estrutura

Organização modular; só criar pastas quando houver conteúdo:

```text
src/app
├── core            # auth, http, interceptors, guards, configuração
├── shared          # components, pipes e directives reutilizáveis
├── features        # uma pasta por funcionalidade (rotas lazy)
└── data-access     # clients de API e modelos tipados
```

## Componentes e rotas

- Componentes standalone; `ChangeDetectionStrategy.OnPush` por padrão.
- Lazy loading obrigatório por rota (`loadComponent`/`loadChildren`).
- Usar `trackBy`/`@for ... track` em listas.
- Evitar lógica pesada em template e componente gigante.
- Sem regra de negócio complexa em componente: extrair para service ou função pura testável.

## Integração com APIs

- Clients tipados na camada `data-access`; nenhuma URL de API espalhada em componentes.
- Interceptors centralizados para autenticação e tratamento padronizado de erro.
- Não chamar `HttpClient` diretamente em componente.
- Para CPF, CNPJ, CEP e telefone, seguir `.ai/structure/rules/standard-fields.md`.

## Estado

- Estado local no componente (signals); estado compartilhado em services tipados da feature.
- Ler `.ai/structure/rules/frontend-state.md` antes de implementar cache, autenticação, dados remotos ou store global.
- Fluxos assíncronos visíveis tratam loading, empty, success e error.

## Formulários

- Reactive Forms tipados (`FormGroup<...>`), validação com mensagem traduzida e `role="alert"` para erros.
- Impedir envio duplicado enquanto a operação estiver em andamento.

## Internacionalização e acessibilidade

- Toda mensagem visível segue `.ai/structure/rules/i18n.md`.
- Elementos interativos acessíveis por teclado; rótulos e `aria-*` apropriados.

## Segurança

- Não armazenar token sensível em `localStorage` quando houver alternativa mais segura (ex.: cookie `HttpOnly`).
- Sanitização padrão do Angular; nunca `bypassSecurityTrust*` sem justificativa.
- Não expor segredo no bundle.

## Performance

- Orçamentos de bundle no `angular.json`; carregar o que a rota inicial precisa.
- Imagens com dimensões e `loading="lazy"`; ver `.ai/structure/rules/performance.md`.

## Testes

- Jest (ou Karma) para services, guards, interceptors e componentes relevantes; cobrir loading, vazio, erro e sucesso.
- Limite mínimo de cobertura na ferramenta (ver `.ai/structure/rules/testing.md`).

## Proibido

- Página/componente com regra de negócio complexa.
- Duplicar chamadas HTTP em múltiplos componentes.
- `any` sem justificativa.
- Rota sem lazy loading.
