# ADR-002 - Servico independente de entrega de e-mail

> **Exemplo ilustrativo.** Este é um ADR real de um projeto de referência
> (AgendaHub), mantido aqui como exemplo de como preencher
> `.ai/structure/templates/adr-template.md`. Ao iniciar um projeto novo,
> remova este ADR e crie os ADRs reais do seu produto conforme as decisões
> forem tomadas.

## Status

Aceito

## Contexto

Servicos como `identity-service` precisam enviar e-mails transacionais, por exemplo codigos de cadastro e recuperacao de senha.

Manter adapters SMTP ou implementacoes locais de notificacao dentro de cada servico aumenta duplicacao, espalha configuracoes sensiveis e mistura uma capacidade tecnica de entrega com regras dos bounded contexts consumidores.

## Decisao

Criar `email-service` em `apps/backend/services/email-service` como microservice independente de entrega de e-mail.

Outros servicos devem solicitar envio por contrato HTTP versionado, inicialmente `POST /api/v1/emails`, informando destinatario, assunto e corpo.

O `email-service` fica responsavel por validar a mensagem e entregar via SMTP ou provedor externo configurado por variaveis de ambiente. Servicos consumidores continuam decidindo quando enviar e qual conteudo solicitar, mas nao devem possuir adapters SMTP nem implementacoes locais de envio de e-mail.

## Consequencias

Positivas:

- Centraliza configuracao e credenciais de e-mail.
- Evita duplicacao de adapters de envio em cada microservice.
- Permite trocar SMTP por provedor externo sem alterar os consumidores.
- Mantem notification-service focado em notificacoes nao relacionadas a e-mail.

Negativas:

- Introduz dependencia operacional do `email-service`.
- Chamadas sincronas de e-mail devem considerar timeout, retry e idempotencia quando o fluxo exigir.
- Templates mais complexos podem exigir novo contrato ou armazenamento dedicado no futuro.

## Data

2026-05-26
