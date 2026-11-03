---
name: sugerir-funcionalidades
description: Valida o projeto (estado real, lacunas, aderência às regras), pesquisa o mercado (alternativas, tendências, lacunas) e propõe funcionalidades priorizadas e 100% aderentes ao contexto, para melhorar o produto e ganhar visibilidade. Usar quando o usuário pedir ideias de funcionalidades, roadmap, análise de concorrência, diferenciais ou "o que falta no projeto".
---

# Sugerir funcionalidades

Entrega um relatório em `docs/produto/` com o diagnóstico do projeto, o panorama de mercado e funcionalidades priorizadas. **Só sugere; não implementa.** Cada sugestão aprovada vira `nova-story` (e `nova-adr` se houver decisão arquitetural).

Regras e contexto: manifesto do projeto (`project.md` dentro de `.ai/`, quando existir), `.ai/context/` (negócio, bounded contexts, ADRs, requisitos não funcionais), `.ai/structure/rules/`, `.ai/structure/agents/README.md`.

## Passos

1. **Entender o produto.** Ler o manifesto `project.md` dentro de `.ai/` (se existir) e `.ai/context/business-context.md`. Registrar: problema, público, estilo de arquitetura, stack e `status`. Sem manifesto, deduzir do `CLAUDE.md`, do README e do código, e declarar a premissa. Se `status: nao-inicializado`, o produto analisado é o próprio template (governança de IA para monorepo) e o público são times que o adotam. Contexto de negócio ausente: perguntar ao usuário em vez de inventar.
2. **Validar o estado real (medir, não supor).** Aplicar `code-reviewer`, `microservice-architect` e `refactor-guard`:
   - inventário do que existe (apps, serviços, skills, regras, templates, pipeline), por leitura do repositório;
   - `bash scripts/validate-ai-structure.sh` e, se houver código, testes/lint/build, registrando o resultado real (ou "não executado" com o motivo);
   - lacunas e inconsistências entre o que a documentação promete e o que existe;
   - funcionalidades já planejadas em `docs/stories/` e ADRs, para não duplicar nem contradizer.
3. **Pesquisar o mercado.** Usar busca na web (WebSearch/WebFetch) e registrar a fonte e a data de cada afirmação:
   - 3 a 6 alternativas diretas e adjacentes (produtos, templates, frameworks, projetos open source relevantes);
   - o que cada uma oferece, modelo de adoção, pontos fortes e fracos;
   - tendências recentes do nicho e expectativas do público;
   - lacunas que nenhuma alternativa cobre bem (oportunidade de diferenciação).
   Não copiar texto das fontes; resumir com as próprias palavras. Dado que não foi confirmado é marcado "não verificado"; sem fonte, não entra como fato.
4. **Gerar candidatas e filtrar por aderência.** Cada candidata precisa passar em **todos** os filtros, senão é descartada e listada em "Descartadas" com o motivo:
   - resolve problema do público definido no passo 1;
   - respeita `CLAUDE.md`, as rules e as ADRs (sem regra de negócio em controller, sem banco compartilhado, sem overengineering);
   - cabe na stack e no estilo de arquitetura escolhidos (ou propõe ADR explícita para mudar);
   - mantém neutralidade entre Claude, Codex e Copilot quando o projeto for o template;
   - é testável e entregável em incrementos pequenos.
5. **Priorizar.** Para cada sugestão, pontuar de 1 a 5 e justificar: valor para o usuário, diferenciação/visibilidade no mercado, esforço (inverso), risco (inverso) e aderência. Ordenar por valor/esforço e agrupar em **Agora**, **Próximo** e **Depois**. Visibilidade é um critério, não o único: nada entra só por "ser chamativo".
6. **Salvar** em `docs/produto/sugestoes-funcionalidades-AAAA-MM-DD.md` com a estrutura abaixo. Não reescrever relatório antigo: criar um novo e citar o anterior.
7. **Fechar** com as 3 principais recomendações, as premissas assumidas e a pergunta de quais viram `nova-story`. Informar que nada foi implementado.

## Estrutura do relatório

1. Contexto e escopo (produto, público, revisão `git rev-parse --short HEAD`).
2. Diagnóstico do estado atual (inventário, validações executadas e resultado, lacunas).
3. Panorama de mercado (tabela: alternativa, o que oferece, pontos fortes, lacunas, fonte e data).
4. Funcionalidades sugeridas, uma por bloco: `FUN-NN` estável, problema que resolve, descrição, usuário beneficiado, evidência (repositório e/ou mercado), diferencial/visibilidade, pontuação, esforço, risco, impacto em APIs/eventos/dados/segurança/observabilidade, papéis envolvidos, critério de aceite resumido, próxima ação (`nova-story`/`nova-adr`).
5. Roadmap (Agora, Próximo, Depois).
6. Descartadas e por quê.
7. Premissas, fontes não verificadas e riscos.

## Proibido

- Sugerir sem evidência (repositório ou fonte datada) ou inventar dado de mercado, número, cliente ou concorrente.
- Sugestão que viole rule, ADR ou stack escolhida sem apontar a ADR necessária.
- Implementar, criar story ou alterar código durante a análise.
- Copiar conteúdo protegido das fontes pesquisadas.
