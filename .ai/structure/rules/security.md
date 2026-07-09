# Security Rules

## Objetivo

Garantir segurança mínima obrigatória para autenticação, autorização,
proteção de dados, APIs e dependências em todos os serviços.



# Backend

- Todas as APIs devem possuir autenticação quando não forem públicas.
- Toda autorização deve ser baseada em papel, escopo ou política.
- Validar entrada de dados nas bordas da aplicação.
- Nunca confiar em dados enviados pelo cliente.
- Sanitizar entradas quando necessário.
- Aplicar princípio do menor privilégio.
- Usar HTTPS obrigatório em produção.
- Aplicar timeout em integrações externas.
- Evitar exposição desnecessária de endpoints internos.
- Separar claramente autenticação de autorização.
- Garantir idempotência quando aplicável.
- Toda alteração crítica deve possuir trilha de auditoria.



# JWT / OAuth2

## Obrigatório

Toda implementação JWT deve validar:

- assinatura;
- issuer;
- audience;
- expiração;
- algoritmo permitido;
- permissões/roles necessárias.

## Regras JWT

- Validar assinatura usando chave confiável ou JWKS.
- Validar `issuer`.
- Validar `audience` quando aplicável.
- Validar expiração (`exp`).
- Validar `nbf` quando existir.
- Validar `iat` quando aplicável.
- Rejeitar tokens expirados.
- Rejeitar tokens sem assinatura válida.
- Rejeitar algoritmo `none`.
- Restringir algoritmos permitidos (ex: `RS256`).
- Não confiar em claims sem validação.
- Validar scopes/roles antes de acessar recursos.
- Access token deve possuir curta duração.
- Refresh token deve possuir rotação quando aplicável.
- Garantir estratégia de revogação de tokens.
- Não armazenar JWT em local inseguro no frontend.
- Não trafegar token fora de HTTPS.



# APIs

- Aplicar rate limit em endpoints críticos.
- Aplicar proteção contra brute force.
- Aplicar proteção contra enumeração de usuários.
- Validar payloads obrigatórios.
- Validar tamanho máximo de payload.
- APIs não devem retornar detalhes internos da aplicação.
- APIs não devem retornar stack trace em produção.
- APIs devem retornar mensagens padronizadas.
- Registrar logs de falha de autenticação e autorização.
- Endpoints administrativos devem possuir proteção adicional.



# Dados Sensíveis

- Criptografar dados sensíveis quando necessário.
- Mascarar informações sensíveis em logs.
- Nunca logar:
  - senha;
  - token;
  - Authorization header;
  - CPF completo;
  - cartão;
  - segredo;
  - refresh token.
- Minimizar exposição de dados pessoais.
- Aplicar LGPD quando aplicável.
- Dados críticos devem possuir controle de acesso explícito.



# Segredos e Configuração

- Nunca armazenar segredo em código-fonte.
- Nunca versionar senha em `application.yml`.
- Usar variáveis de ambiente ou secret manager.
- Rotacionar segredos periodicamente.
- Não compartilhar credenciais entre ambientes.
- Ambientes DEV/HML/PRD devem possuir segredos distintos.



# Dependências

- Evitar bibliotecas sem manutenção.
- Verificar vulnerabilidades periodicamente.
- Não adicionar dependência pesada sem justificativa.
- Remover dependências não utilizadas.
- Fixar versões críticas quando necessário.
- Atualizar dependências vulneráveis imediatamente.
- Validar licenciamento das bibliotecas utilizadas.



# Banco de Dados

- Usuário da aplicação não deve ser administrador do banco.
- Aplicar menor privilégio para acesso ao banco.
- Queries devem utilizar parâmetros.
- Evitar SQL Injection.
- Dados críticos devem possuir rastreabilidade.
- Backup deve ser protegido e criptografado quando necessário.



# Logs e Observabilidade

- Logs nunca devem expor informações sensíveis.
- Logs devem possuir correlação (`traceId`/`requestId`).
- Registrar falhas de autenticação e autorização.
- Monitorar tentativas suspeitas.
- Alertar excesso de erro 401/403.
- Alertar volume anormal de requisições.



# Checklist Obrigatório de Review

## Security Reviewer

Antes de aprovar um PR validar:

- [ ] Autenticação aplicada corretamente.
- [ ] Autorização aplicada corretamente.
- [ ] JWT validando assinatura, issuer, audience e expiração.
- [ ] Nenhum segredo exposto.
- [ ] Nenhum log sensível.
- [ ] APIs protegidas contra brute force.
- [ ] Rate limit aplicado quando necessário.
- [ ] Dependências verificadas.
- [ ] Sem exposição de stack trace.
- [ ] Uso obrigatório de HTTPS em produção.
- [ ] Inputs validados corretamente.
- [ ] Menor privilégio aplicado.



# Proibido

- Segredo hardcoded.
- Senha em código-fonte.
- Token fixo em código.
- Logar Authorization header.
- Retornar stack trace em produção.
- Desabilitar validação JWT.
- Usar algoritmo JWT inseguro.
- Compartilhar credenciais entre ambientes.
- Expor endpoint administrativo publicamente.