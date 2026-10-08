# Perfil do Projeto

Manifesto das escolhas do projeto. É preenchido ao iniciar o projeto a partir deste template (skill
`iniciar-projeto`) e lido por outras skills (ex.: `pipeline-ci-deploy`, `migracao-dados`) para não
perguntar de novo o que já foi decidido. O mapa de cada escolha para os arquivos do template está em
`.ai/structure/stacks.md`.

Enquanto `status` for `nao-inicializado`, este repositório é o template-base e **nada** abaixo foi decidido.

```yaml
status: nao-inicializado     # nao-inicializado | em-andamento | inicializado

projeto:
  nome:                       # slug em kebab-case, usado em imagens e pastas
  descricao:                  # uma frase: o problema e para quem
  idioma: pt-BR

arquitetura:
  estilo:                     # microservices | monolito-modular
  bounded_contexts: []        # detalhados em .ai/context/bounded-contexts.md

stack:
  backend:                    # spring-boot | nestjs | nenhum
  frontend:                   # ionic-angular | angular | nenhum
  banco:                      # mongodb | outro:<nome>
  gerenciador_pacotes:        # maven | gradle | pnpm | npm | yarn

entrega:
  ci:                         # github-actions | outro:<nome>
  deploy:                     # vps-docker-compose | outro:<nome> | nenhum
  registry:                   # ghcr | outro:<nome>
  branch_producao: main

aplicado: []                  # etapas já aplicadas pela inicialização, para ser repetível
```

## Etapas registráveis em `aplicado`

`contexto-negocio`, `stack-backend`, `stack-frontend`, `banco`, `entradas-ia`, `readmes-apps`, `env-infra`, `pipeline`, `marcadores-removidos`, `validado`.

## Regras

- Não preencher com suposição: campo que o usuário não decidiu fica vazio e vira pergunta em aberto.
- Mudar uma escolha depois exige registrar ADR (`.ai/structure/templates/adr-template.md`) e reaplicar a seção correspondente de `.ai/structure/stacks.md`.
- Sem segredos neste arquivo.
