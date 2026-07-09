# Bounded Contexts

> **Exemplo ilustrativo.** Estes bounded contexts são os reais de um projeto
> de referência (AgendaHub). Ao iniciar um projeto novo a partir deste
> template, substitua todo o conteúdo abaixo pelos bounded contexts reais do
> seu produto — veja `README.md` > "Como usar este repositório para iniciar
> um novo projeto".

## Identity Context

Status: Existente

Serviço:

- `identity-service`

Responsável por:

- Usuários e contas.
- Autenticação.
- Perfis e permissões.
- Sessão e introspecção de identidade para o gateway.
- Convite e validação de usuários vinculados a uma empresa.
- Solicitar envio de e-mails transacionais relacionados a cadastro, convite e recuperação de senha.

Não é responsável por:

- Cadastro de empresa.
- Regras de cliente, produto ou pedido.
- Entrega direta de e-mail via SMTP.
- Persistência de dados de outros contextos.

## Company Context

Status: Existente

Serviço:

- `company-service`

Responsável por:

- Empresas vinculadas ao usuário autenticado.
- Validação de CNPJ.
- Endereço comercial da empresa.
- Consulta de endereço por CEP.
- Ownership dos dados cadastrais da empresa.

Não é responsável por:

- Autenticação do usuário.
- Entrega direta de e-mail.
- Regras de cliente, produto, pedido ou pagamento.

## Client Context

Status: Existente

Serviço:

- `client-service`

Responsável por:

- Cadastro e manutenção de clientes.
- Validação de telefone, e-mail e endereço opcional.
- Consulta de endereço por CEP para clientes.
- Inativação de cliente.
- Ownership dos dados de clientes.

Não é responsável por:

- Autenticação.
- Cadastro de empresa.
- Catálogo de produtos.
- Criação ou fechamento de pedido.

## Catalog Context

Status: Existente

Serviço:

- `catalog-service`

Responsável por:

- Cadastro e manutenção de produtos.
- Preço, valor, estoque e marca.
- Inativação de produto.
- Ownership dos dados de catálogo.

Não é responsável por:

- Fechamento de pedido.
- Pagamento.
- Cadastro de cliente.
- Validação de disponibilidade de carrinho fora do contrato de catálogo.

## Order Context

Status: Existente

Serviço:

- `order-service`

Responsável por:

- Pedido.
- Itens do pedido.
- Status do pedido.
- Regras de criação, edição, conclusão e cancelamento.
- Dashboard inicial de pedidos.
- Ownership dos dados de pedido.

Não é responsável por:

- Cadastro de cliente.
- Cadastro de produto.
- Captura ou liquidação de pagamento.
- Persistência de dados de outros contextos.

## Scheduling Context

Status: Existente

Serviço:

- `scheduling-service`

Responsável por:

- Disponibilidade da empresa e por profissional.
- Consulta de produtos agendáveis por contrato com o `catalog-service`.
- Consulta de horários disponíveis.
- Agendamento interno.
- Autoagendamento público.
- Remarcação, cancelamento, no-show e atendimento realizado.
- Recorrência inicial de agendamentos.
- Ownership dos dados de agenda.

Não é responsável por:

- Cadastro, preço, duração ou status do produto.
- Autenticação.
- Cadastro completo de cliente.
- Faturamento, itens do pedido ou pagamento.
- Entrega direta de notificações.
- Persistência de dados de outros contextos.

## Email Delivery Context

Status: Existente

Serviço:

- `email-service`

Responsável por:

- Receber solicitações de envio de e-mail de outros serviços.
- Validar destinatário, assunto e corpo.
- Entregar e-mails via SMTP ou provedor configurado.
- Isolar configurações e credenciais de e-mail.

Não é responsável por:

- Decidir quando uma notificação deve ser enviada.
- Gerenciar push notification, SMS ou WhatsApp.
- Conhecer regras internas dos contextos consumidores.

## Payment Context

Status: Planejado

Serviço:

- Ainda não definido.

Responsável por:

- Intenção de pagamento.
- Confirmação.
- Rejeição.
- Estorno.

Não é responsável por:

- Regra completa do pedido.
- Cadastro de cliente ou produto.

## Notification Context

Status: Planejado

Serviço:

- Ainda não definido.

Responsável por:

- Push notification.
- SMS ou WhatsApp, se aplicável.
- Orquestrar comunicações não relacionadas a e-mail quando aplicável.

Não é responsável por:

- Decidir regra principal de negócio.
- Envio de e-mail transacional.
