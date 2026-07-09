# Integration Map

> **Exemplo ilustrativo.** Este mapa de integrações é o real de um projeto de
> referência (AgendaHub). Ao iniciar um projeto novo a partir deste template,
> substitua todo o conteúdo abaixo pelas integrações reais do seu produto —
> veja `README.md` > "Como usar este repositório para iniciar um novo
> projeto".

## Mobile App

App:

- `apps/mobile-app`

Consome APIs via:

- `api-gateway` em ambientes integrados.
- Serviços diretamente apenas em ambiente local quando explicitamente configurado.

Consome:

- `identity-service` para login, cadastro, recuperação de senha, sessão e usuários da empresa.
- `company-service` para empresa e consulta de CEP da empresa.
- `client-service` para clientes e consulta de CEP de clientes.
- `catalog-service` para produtos.
- `order-service` para pedidos e dashboard inicial.
- `scheduling-service` para agenda, disponibilidade, atendimentos e autoagendamento.

## API Gateway

Componente:

- `apps/backend/platform/api-gateway`

Responsável por:

- Roteamento para os microservices.
- Propagação de identidade autenticada por headers internos.
- Proteção de rotas não públicas.
- Padronização de erro de indisponibilidade upstream.
- Monitoramento agregado dos health checks definidos em `monitor.services`.

Propaga para serviços:

- `X-User-Id`
- `X-Company-Id`, quando aplicável.
- `X-User-Roles`, quando aplicável.
- Token interno de gateway, quando exigido pelo serviço.

## identity-service

Expõe:

- APIs de autenticação.
- APIs de cadastro, validação e recuperação de conta.
- APIs de usuários de empresa.
- API de introspecção de sessão para o gateway.

Consome:

- `email-service` para envio de códigos de cadastro, convite e recuperação de senha.

## company-service

Expõe:

- API de cadastro e consulta de empresa.
- API pública de listagem mínima de empresas para autoagendamento.
- API de consulta de endereço por CEP.

Consome:

- Headers de identidade propagados pelo gateway.
- API externa de CEP/Correios por adapter de infraestrutura.

## client-service

Expõe:

- API de cadastro, listagem, atualização e inativação de clientes.
- API de consulta de endereço por CEP.
- API interna idempotente para localizar ou cadastrar cliente por telefone no autoagendamento.

Consome:

- Headers de identidade propagados pelo gateway.
- API externa de CEP/Correios por adapter de infraestrutura.

## catalog-service

Expõe:

- API de cadastro, listagem, atualização e inativação de produtos.
- Flag e duração que definem se o produto pode ser agendado.

Consome:

- Headers de identidade propagados pelo gateway.

## order-service

Expõe:

- API de cadastro, listagem, atualização, conclusão e cancelamento de pedidos.
- API de itens do pedido.
- API de dashboard inicial de pedidos.

Consome:

- Headers de identidade propagados pelo gateway.
- Dados informados por contrato do cliente mobile.

Observação:

- O serviço não deve consultar diretamente bancos de `client-service`, `catalog-service` ou `company-service`.
- Qualquer necessidade de sincronização entre contextos deve ser feita por API explícita ou evento documentado.

## scheduling-service

Expõe:

- API de disponibilidade.
- API administrativa de listagem, alteracao e exclusao de disponibilidade.
- API de agendamentos internos.
- API pública de autoagendamento.
- API de atendimento realizado.

Consome:

- Headers de identidade propagados pelo gateway em rotas internas.
- API do `catalog-service` para validar e listar produtos agendáveis.
- API interna do `client-service` para localizar ou cadastrar cliente por telefone.
- API interna do `order-service` para gerar pedido ao finalizar atendimento.
- Dados informados por contrato do cliente mobile.

Observação:

- O serviço não deve consultar diretamente bancos de `identity-service`, `client-service`, `company-service` ou `order-service`.
- Quando um atendimento gerar pedido, a integração deve ocorrer por contrato explícito com `order-service` ou evento documentado.

## email-service

Expõe:

- API de envio de e-mail transacional.

Consome:

- SMTP ou provedor externo de e-mail configurado por variáveis de ambiente.

## notification-service

Status: Planejado.

Consome:

- Eventos de notificação, quando aplicável.

Envia:

- Push notification.
- SMS ou WhatsApp, se aplicável.
