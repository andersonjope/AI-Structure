# Ionic Angular Rules

## Estrutura

App Ionic deve seguir organização modular, só criar a estrutura de pastas se necessário:

```text
src/app
├── core
│   ├── auth
│   ├── http
│   ├── interceptors
│   └── guards
├── shared
│   ├── components
│   ├── pipes
│   └── directives
├── features
│   ├── catalog
│   ├── orders
│   └── profile
└── data-access
    ├── api
    └── models
```

## Performance

- Usar lazy loading por rota.
- Evitar importar tudo de `@ionic/angular` quando houver opção standalone.
- Usar componentes standalone quando possível.
- Evitar lógica pesada em templates.
- Usar trackBy em listas.
- Usar skeleton loading para melhorar percepção de performance.
- Evitar chamadas repetidas em lifecycle hooks.
- Cachear dados de baixa volatilidade.

## Integração com APIs

- Criar clients tipados.
- Centralizar interceptors.
- Tratar erro de forma padronizada.
- Não espalhar URL de API em componentes.
- Não chamar HttpClient diretamente em página quando houver camada data-access.
- Para CPF, CNPJ, CEP e telefone, seguir `.ai/structure/rules/standard-fields.md`.

## Internacionalização

- Seguir `.ai/structure/rules/i18n.md` para toda tela, componente e mensagem visível ao usuário.

## Estado

- Estado local simples pode ficar no componente.
- Estado complexo deve ter padrão claro e documentado.
- Evitar stores globais sem necessidade.
- Ler `.ai/structure/rules/frontend-state.md` antes de implementar fluxo com estado compartilhado, cache, autenticação, dados remotos ou store global.
- Fluxos assíncronos visíveis ao usuário devem tratar loading, empty, success e error.
- Estado compartilhado por feature deve ficar em services tipados da feature.
- Estado global exige justificativa clara, estratégia de limpeza/invalidação e testes.
- Não duplicar estado remoto em múltiplos componentes sem fonte única.

## Segurança

- Não armazenar token sensível em localStorage se houver alternativa mais segura.
- Sanitizar entradas do usuário.
- Não expor segredo no app.

## Proibido

- Página com regra de negócio complexa.
- Duplicar chamadas HTTP em múltiplos componentes.
- Criar componente gigante.
- Usar `any` sem justificativa.
