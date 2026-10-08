# Auditoria de qualidade, segurança e cobertura

Relatório datado em `docs/auditoria-<assunto>-AAAA-MM-DD.md`. Registra o que foi **medido**,
cada achado com evidência e o plano de correção. Regras de uso em
`.ai/structure/rules/documentation.md`.

Um relatório é fotografia de uma revisão: não reescrever depois. Mudanças de status dos
achados entram na seção própria de cada um, com a branch ou o commit que corrigiu.

- **Data do registro:**
- **Revisão auditada:** `<commit>`
- **Status:** <resumo: quantos achados corrigidos, quantos abertos>
- **Escopo:** <módulos, apps, testes, dependências, CI, infraestrutura>
- **Agentes aplicados:** `code-reviewer`, `security-reviewer`, ...

> Este documento registra os resultados na revisão indicada. Antes de implementar,
> verificar se cada problema permanece presente no HEAD atual.

## Conclusão

Dois ou três parágrafos: o projeto está de acordo com as regras internas? Onde estão os
maiores riscos? O que foi (ou não) alterado durante a auditoria.

## Resultados das verificações

| Verificação | Resultado |
|---|---|
| Testes unitários | n passaram, em n suítes |
| Testes de integração | |
| Lint | |
| Typecheck / compilação | |
| Build de produção | |
| Validação da estrutura `.ai/` (`scripts/validate-ai-structure.sh`) | |
| Auditoria de dependências | n alertas: n altos, n moderados, n baixos |

### Cobertura

| Aplicativo/módulo | Linhas | Instruções | Funções | Ramificações |
| --- | ---: | ---: | ---: | ---: |
| | | | | |

Declarar o método (arquivos incluídos/excluídos, se mapas de suítes diferentes foram
combinados) e se há `coverageThreshold`/`jacoco:check` no CI. Listar arquivos com lacunas
relevantes de ramificações.

## Achados e plano de implementação

Gravidade: crítica, alta, média ou baixa. IDs estáveis (`AUD-01`...).

### AUD-01: Título do achado

- **Gravidade:**
- **Contexto:**
- **Evidência:** reprodução, comando e saída observada (não opinião).
- **Causa:**
- **Impacto:** (sem exagerar: uma reprodução local não é um ataque em produção)
- **Arquivos:**
- **Referências:** regras `.ai/structure/rules/*.md`, ADRs
- **Status:** aberto / corrigido na branch `fix/aud-01-...` (resumo da correção e dos testes)

Ações e critérios de aceite:

- [ ] Ação verificável 1.
- [ ] Teste que falha sem a correção.

## Dependências

| Pacote | Gravidade | Corrigido em | Status |
|---|---|---|---|
| | | | |

## Outros pontos de conformidade e qualidade

Melhorias que não são defeito: ferramental, métricas, documentação, performance.

## Ordem sugerida

1. Itens de gravidade alta (segurança e integridade de dados).
2. Gate de cobertura e dependências.
3. Demais itens.
