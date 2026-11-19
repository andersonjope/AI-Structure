---
name: versionamento-github
description: Conduz o versionamento Git/GitHub do projeto - branch por demanda, commit, push, Pull Request e promoção develop -> main. Toda demanda nova nasce em branch própria a partir da develop, entra na develop por PR e só chega à main depois de integrada na develop. Usar sempre que o usuário pedir para commitar, fazer push, abrir ou mergear PR, criar branch, subir uma alteração, publicar, promover para produção ou "fechar" uma entrega, mesmo sem citar Git ou GitHub.
---

# Versionamento GitHub

O objetivo é que `main` e `develop` só mudem por PR revisado e com CI verde, e que cada demanda seja isolada, rastreável e fácil de reverter. Por isso o fluxo é sempre o mesmo:

```
main  <-- PR (promoção) -- develop  <-- PR -- feat|fix|chore|docs/<demanda>
```

## Antes de qualquer coisa

1. `git status`, `git branch --show-current` e `git remote -v` para saber onde está e o que está pendente.
2. Confirmar se existe `develop` (`git ls-remote --heads origin develop`). Se não existir, propor criá-la a partir da `main` e **esperar o OK**; sem `develop` o fluxo abaixo não funciona. Depois lembrar o usuário de ativar a branch protection (CI obrigatório) em `develop` e `main`: é configuração do GitHub, feita por ele.
3. Ler `.ai/structure/rules/` quando a alteração tocar regra de negócio, API ou infra, para citar na descrição do PR.

## 1. Nova demanda: criar branch

Nunca commitar direto em `develop` nem em `main`. Se o usuário está nelas com alterações pendentes, mover o trabalho para uma branch nova (`git switch -c`), sem perder nada.

```bash
git fetch origin
git switch develop && git pull --ff-only
git switch -c <tipo>/<slug-curto-em-kebab-case>
```

- Tipos: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`.
- Uma branch por demanda. Se a branch atual é de outra demanda, criar nova em vez de misturar.
- Alterações pendentes que pertencem a outra demanda ficam de fora (stage seletivo, `git stash` só se o usuário concordar).
- Correção urgente em produção (hotfix) é a única exceção: nasce da `main`, vai por PR para a `main` e **depois** é trazida de volta à `develop` por merge, para as branches não divergirem.

## 2. Commit

1. Validar antes: rodar o comando de validação do projeto (testes, lint, `bash scripts/validate-ai-structure.sh` quando mudar `.ai/`, skills ou instruções). Não commitar com validação falhando; se falhar, corrigir ou avisar.
2. `git diff` para revisar o que entra. Adicionar arquivos **por nome** (`git add <arquivos>`); evitar `git add -A`, que leva `.env`, binários e arquivos gerados. Parar e avisar se aparecer segredo.
3. Mensagem em Conventional Commits, em português, no imperativo, descrevendo o porquê quando não for óbvio: `tipo(escopo opcional): resumo` (até ~72 caracteres) e corpo opcional.
4. **Sem linhas de atribuição** (`Co-Authored-By`, "Generated with…"): o autor é só o git user configurado.
5. Commits pequenos e coesos. Não usar `--amend` nem reescrever commits já enviados; não usar `--no-verify`.

## 3. Push

```bash
git push -u origin <branch>
```

Nunca `--force` (se for inevitável numa branch própria ainda sem PR, `--force-with-lease`, e só com pedido explícito). Nunca push direto para `develop` ou `main`.

## 4. Pull Request da demanda para a develop

```bash
gh pr create --base develop --title "<mensagem no padrão de commit>" --body "<corpo>"
```

Corpo com: o que mudou e por quê, como foi validado (comando e resultado), impacto em API/eventos/dados/segurança quando houver, riscos e pendências. Sem linha de atribuição.

- Depois de abrir, checar o status e os checks (`gh pr checks <n>`). CI falhando: corrigir na mesma branch, nunca contornar.
- Mergear só quando o usuário pedir e o CI estiver verde: `gh pr merge <n> --merge` (o histórico do projeto usa merge commit, não squash).
- Após o merge: `git switch develop && git pull --ff-only`. Apagar a branch (local e remota) somente se o usuário pedir.

## 5. Promoção: develop -> main

A `main` só recebe o que já está integrado e validado na `develop`. Por isso o merge na `develop` vem sempre primeiro, e a promoção é um PR próprio:

1. Confirmar que a `develop` está atualizada e com CI verde.
2. `gh pr create --base main --head develop --title "release: <resumo>" --body "<lista das demandas incluídas>"`.
3. Mergear (`--merge`) só com pedido do usuário e CI verde. Não apagar a `develop`.
4. Atualizar local: `git switch main && git pull --ff-only`.

Se a `main` tiver commits que a `develop` não tem (hotfix), trazer a `main` para a `develop` antes de promover.

## Regras de segurança do fluxo

- Push, abertura de PR e merge são ações visíveis para outras pessoas: executar o que o usuário pediu, não o passo seguinte. Pediu commit, não fazer push; pediu PR, não mergear.
- Não apagar branch, não reescrever histórico publicado e não alterar configurações do repositório (branch protection, regras) sem o usuário pedir; configurações ele faz no GitHub.
- Se algo inesperado aparecer (conflito, branch divergente, CI vermelho, arquivos que não são da demanda), parar e explicar em vez de forçar.

## Saída

Informar: branch usada, commits criados (hash + título), link do PR, estado do CI e o próximo passo que depende do usuário (revisar, mergear, promover).
