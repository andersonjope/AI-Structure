# Business Context

> **Exemplo ilustrativo.** Este arquivo mostra o contexto de negócio real de
> um projeto de referência (AgendaHub). Ao iniciar um projeto novo a partir
> deste template, substitua todo o conteúdo abaixo pelo contexto real do seu
> produto — veja `README.md` > "Como usar este repositório para iniciar um
> novo projeto".

## Visão geral

Este sistema é composto por microservices e aplicativo mobile Ionic.

Objetivo do produto:

- Pendente de definição explícita pelo produto.
- Enquanto não houver definição, agentes não devem inventar regra crítica de negócio.
- Toda implementação de comportamento de negócio deve registrar premissas ou pedir esclarecimento quando a decisão for irreversível.

## Capacidades principais

- Autenticação e identidade.
- Empresa.
- Usuário.
- Agendamento.
- Notificações.

## Regras gerais de negócio

- Regras ainda não documentadas devem ser tratadas como premissas temporárias.
- Regras novas devem ser registradas no contexto do bounded context afetado ou em ADR quando alterarem arquitetura/contratos.
- Todos os fluxos devem ter cenários de teste antes da implementação.

## Métricas de sucesso

- Tempo de resposta.
- Conversão.
- Retenção.
- Redução de erro operacional.

## Lacunas conhecidas

- Problema de negócio principal.
- Público-alvo.
- Jornada principal do usuário.
- Políticas de autenticação, autorização e recuperação de conta.
- Regras de empresa, usuário, agendamento e notificação.
- Prioridades de produto por fase.

## Orientação para agentes

- Se a tarefa for técnica e reversível, registrar a premissa e seguir com implementação mínima.
- Se a tarefa definir regra de negócio, contrato público ou fluxo crítico, confirmar a premissa antes de implementar quando a documentação não for suficiente.
- Não criar nomes alternativos para conceitos já definidos em `ubiquitous-language.md`.
