# NestJS Rules

## Versão e runtime

- Node.js LTS e TypeScript em modo `strict`, conforme definido no projeto.
- Gerenciador de pacotes fixo no projeto (`packageManager` no `package.json`) com lockfile versionado.
- Preferir NestJS com Mongoose (`@nestjs/mongoose`) quando o banco for MongoDB.

## Organização

Um módulo NestJS por contexto de negócio, com camadas explícitas:

```text
src/<modulo>
├── domain            # entidades, value objects, invariantes (sem Nest, HTTP ou Mongoose)
├── application       # casos de uso e portas (interfaces de repositório)
├── infrastructure    # adapters: Mongoose, clientes externos, filas
├── dto               # contratos HTTP com class-validator
├── <modulo>.controller.ts
└── <modulo>.module.ts
```

Para módulos simples, é aceitável colapsar camadas, desde que a regra de negócio continue fora do controller e do repositório.

## Controllers

Controllers devem:

- Receber o request e validar entrada por DTO.
- Chamar o caso de uso.
- Retornar o response.
- Não conter regra de negócio nem acessar Mongoose diretamente.
- Validar CPF, CNPJ, CEP e telefone conforme `.ai/structure/rules/standard-fields.md`.

## Validação e erros

- `ValidationPipe` global com `whitelist: true` e `forbidNonWhitelisted: true`.
- DTOs com `class-validator`/`class-transformer`; diferenciar campo ausente de `null` (um `@IsOptional` aceita `null`: usar validador que rejeite `null` em campo não anulável).
- Exception filter global com erro público padronizado, sem stack trace nem detalhe interno (ver `.ai/structure/rules/api-contracts.md`).

## Segurança

- Autenticação por guard (JWT ou equivalente) e autorização explícita por papel nas rotas administrativas.
- Configuração por `ConfigModule` validada na subida; nunca segredo no código (ver `.ai/structure/rules/security.md`).
- Rate limiting nas rotas públicas e de autenticação; `helmet` e CORS restritivo.
- Operação de uso único (ex.: rotação de refresh token) deve ser atômica no banco, condicionada ao estado lido.

## Persistência (Mongoose)

- Repositórios concretos em `infrastructure`; o domínio não importa Mongoose.
- Referências entre coleções com `@Prop({ type: SchemaTypes.ObjectId, ref })` (ver `.ai/structure/rules/mongodb.md`).
- `runValidators: true` em atualizações que dependam de validação do schema.

## Observabilidade

- Endpoint de saúde que falha quando a dependência crítica (MongoDB) está indisponível, com tempo limite.
- Logs estruturados e correlation id (ver `.ai/structure/rules/observability.md`).

## Testes

- Jest e `@nestjs/testing`; unitários de domínio e casos de uso primeiro.
- Integração com banco real de teste (Testcontainers ou MongoDB em memória) para persistência, concorrência e migrações.
- E2E (`supertest`) para fluxos críticos e autorização.
- Ver `.ai/structure/rules/testing.md` e `.ai/structure/rules/tdd.md`.

## Documentação de contrato

- OpenAPI (`@nestjs/swagger`) para as APIs públicas, coerente com `.ai/structure/rules/api-contracts.md`.

## Proibido

- Regra de negócio em controller ou repositório.
- `any` sem justificativa.
- Expor documento Mongoose ou entidade de domínio diretamente na resposta.
- Segredo em código ou em log.
