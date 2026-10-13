---
name: validar-estrutura
description: Roda scripts/validate-ai-structure.sh e explica e corrige as falhas (links .ai quebrados, slugs de agente inexistentes, agentes órfãos). Usar depois de alterar .ai/, CLAUDE.md, AGENTS.md ou instruções do Copilot, e antes de abrir PR.
---

# Validar estrutura `.ai/`

## Passos

1. Rodar `bash scripts/validate-ai-structure.sh`.
2. Se passar, informar em uma linha.
3. Se falhar, tratar por verificação:
   - **1. Links `.ai/**/*.md`**: o arquivo citado não existe. Corrigir o caminho, criar o arquivo ou remover a referência. Conferir se não foi renomeado (`git log --stat`).
   - **2. Slugs de agente**: uma matriz de roteamento cita agente sem arquivo em `.ai/structure/agents/`. Corrigir o slug ou criar o agente.
   - **3. Agente órfão**: existe arquivo de agente que falta no roster de `AGENTS.md` ou `CLAUDE.md`. Adicionar `` `slug` `` ao roster.
4. Corrigir na causa (não editar o script para a falha sumir), rodar de novo até passar.

## Ao criar agente, rule ou template novo

Referenciar o arquivo em pelo menos um agente relevante (`.ai/structure/agents/*.md` e `README.md`), para não ficar órfão no fluxo de trabalho.
