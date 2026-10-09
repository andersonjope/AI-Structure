# Story: Épico ou funcionalidade

Especificação de produto em `docs/stories/NN-<assunto>.md`: **o que** a funcionalidade faz
e **por que**. Decisões técnicas vão em ADRs; o relato do que foi feito vai em
`docs/implementation/`. Regras de uso em `.ai/structure/rules/documentation.md`.

Não inventar regra crítica: registrar lacunas em "Premissas e perguntas em aberto".

## Visão

- Problema ou oportunidade:
- Quem se beneficia (personas/papéis):
- Resultado esperado (como saber que deu certo):
- Fora de escopo (o que esta entrega não faz):

## Histórias de usuário

Identificadores estáveis (`US01`, `US02`...): nunca renumerar, apenas acrescentar.

### Épico 1: Nome

- **US01**: Como <papel>, quero <ação>, para <benefício>.

## Critérios de aceite

Por história, em formato verificável (cada item vira cenário de teste):

- **US01**
  - Dado <contexto>, quando <ação>, então <resultado>.
  - Caso de erro: dado <contexto inválido>, quando <ação>, então <resposta/mensagem>.

## Regras de negócio e invariantes

-

## Rastreabilidade

| História | Endpoint(s) / evento(s) | Tela(s) / consumidor(es) | Testes |
|---|---|---|---|
| US01 | `GET /recurso` | `/rota` | `NomeDoTeste` |

## Fases e status

| Fase | Escopo | Status |
|---|---|---|
| 1 | | planejada / em andamento / implementada |

## Premissas e perguntas em aberto

-

## Referências

- ADRs:
- Contratos (`.ai/structure/templates/rest-api-template.md`, `event-contract-template.md`):
- Relatos de implementação:
