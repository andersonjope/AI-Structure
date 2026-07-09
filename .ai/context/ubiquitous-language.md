# Ubiquitous Language

> **Exemplo ilustrativo.** Este glossário é o real de um projeto de
> referência (AgendaHub). Ao iniciar um projeto novo a partir deste template,
> substitua todo o conteúdo abaixo pelos termos reais do seu produto — veja
> `README.md` > "Como usar este repositório para iniciar um novo projeto".

## Termos gerais

| Termo | Significado | Contexto |
|---|---|---|
| Customer | Usuario comprador | Identity/Order |
| Company | Empresa vinculada ao usuario autenticado | Company |
| CNPJ | Cadastro Nacional da Pessoa Juridica usado para identificar empresa | Company |
| CEP | Codigo de Enderecamento Postal usado para buscar endereco | Company |
| Product | Item disponivel no catalogo | Catalog |
| Cart | Lista temporaria de itens antes do pedido | Order |
| Order | Pedido confirmado pelo cliente | Order |
| SchedulableProduct | Produto ativo do Catalog marcado como agendavel e com duracao | Catalog/Scheduling |
| Professional | Usuario da empresa que pode executar servicos agendaveis | Scheduling |
| Availability | Janela de horario disponivel para a empresa ou profissional | Scheduling |
| Appointment | Reserva de data e horario para cliente e produto agendavel | Scheduling |
| Attendance | Execucao real do atendimento vinculado a um agendamento | Scheduling |
| RecurrenceRule | Regra para gerar agendamentos recorrentes | Scheduling |
| Timezone | Fuso horario operacional da empresa | Scheduling |
| Payment | Processo de pagamento de um pedido | Payment |
| Notification | Comunicacao enviada ao usuario | Notification |
| Email Delivery | Entrega de e-mail transacional solicitado por outro servico | Email Delivery |

## Regras de linguagem

- Usar os termos definidos neste arquivo nos nomes de classes, metodos e eventos.
- Nao criar sinonimos sem atualizar este documento.
- Quando houver conflito de significado, criar termo especifico por contexto.
