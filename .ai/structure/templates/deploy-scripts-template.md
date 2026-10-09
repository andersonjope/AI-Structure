# Deploy Scripts e Runbook: Projeto

Modelo reutilizável dos scripts que o workflow de deploy executa e do runbook da VPS.
O workflow está em `.ai/structure/templates/deploy-workflow-template.md`; as regras,
em `.ai/structure/rules/deploy.md`.

## Contexto

- Projeto:
- Serviços que precisam ficar saudáveis (lista usada na espera):
- Diretório da stack na VPS (`DEPLOY_PATH`):
- Variáveis de runtime que o deploy injeta (além de `IMAGE_TAG`/`IMAGE_REGISTRY`):

## Estrutura de arquivos

```text
infra/
├── docker-compose.prod.yml     # imagens do registry via ${IMAGE_REGISTRY}/${IMAGE_TAG}, sem build:
├── .env.prod.example           # todas as chaves, valores PREENCHER
└── deploy/
    ├── README.md               # runbook (seção abaixo)
    ├── deploy-remote.sh        # roda no runner: envia arquivos, loga no registry, chama o update
    └── update-remote.sh        # roda na VPS (via SSH): pull, up, espera healthy, rollback
```

Na VPS, o diretório da stack contém apenas:

```text
$DEPLOY_PATH/
├── docker-compose.prod.yml   (enviado pelo deploy, sobrescrito a cada execução)
├── .env.prod.example         (enviado pelo deploy)
├── .env                      (criado no 1º deploy, preenchido à mão, chmod 600, nunca editado pelo deploy)
└── .versao-atual             (commit em execução)
```

Nenhum código-fonte e nenhum clone do repositório na VPS.

## Parâmetros a substituir

| Placeholder | Descrição | Exemplo |
|---|---|---|
| `<PROJETO>` | Prefixo das imagens | `app-narrota` |
| `<SERVICOS_SAUDAVEIS>` | Serviços cujo health check libera o deploy | `backend frontend` |
| `<DEPLOY_PATH_PADRAO>` | Diretório padrão na VPS | `/opt/<PROJETO>` |

## `infra/deploy/deploy-remote.sh` (runner)

```bash
#!/usr/bin/env bash
# Roda no job "deploy": envia o compose e o .env.prod.example para a VPS, faz login
# no registry só durante o deploy e executa update-remote.sh lá.
set -euo pipefail

faltando=()
for variavel in DEPLOY_HOST DEPLOY_USER DEPLOY_SSH_KEY DEPLOY_KNOWN_HOSTS REGISTRY_USER REGISTRY_TOKEN IMAGE_TAG; do
  [[ -n "${!variavel:-}" ]] || faltando+=("$variavel")
done
if ((${#faltando[@]} > 0)); then
  echo "::error::Configure os secrets: ${faltando[*]} (ver infra/deploy/README.md)" >&2
  exit 1
fi

DEPLOY_PORT="${DEPLOY_PORT:-22}"
DEPLOY_PATH="${DEPLOY_PATH:-<DEPLOY_PATH_PADRAO>}"
IMAGE_REGISTRY="${IMAGE_REGISTRY:-ghcr.io/${GITHUB_REPOSITORY_OWNER,,}}"
raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

dir_ssh="$(mktemp -d)"
printf '%s\n' "$DEPLOY_SSH_KEY" >"$dir_ssh/chave"
chmod 600 "$dir_ssh/chave"
printf '%s\n' "$DEPLOY_KNOWN_HOSTS" >"$dir_ssh/known_hosts"

# Host conhecido obrigatório (StrictHostKeyChecking=yes): sem ele, um servidor
# no meio do caminho receberia o token do registry.
ssh_vps() {
  ssh -i "$dir_ssh/chave" -p "$DEPLOY_PORT" \
    -o BatchMode=yes -o IdentitiesOnly=yes -o ConnectTimeout=20 \
    -o StrictHostKeyChecking=yes -o UserKnownHostsFile="$dir_ssh/known_hosts" \
    "$DEPLOY_USER@$DEPLOY_HOST" "$@"
}

encerrar() {
  ssh_vps "docker logout ghcr.io" >/dev/null 2>&1 || true
  rm -rf "$dir_ssh"
}
trap encerrar EXIT

diretorio="$(printf '%q' "$DEPLOY_PATH")"

echo "Enviando compose e .env.prod.example para $DEPLOY_PATH"
ssh_vps "mkdir -p $diretorio && cat > $diretorio/docker-compose.prod.yml" <"$raiz/infra/docker-compose.prod.yml"
ssh_vps "cat > $diretorio/.env.prod.example" <"$raiz/infra/.env.prod.example"

# Token pela entrada padrão: não aparece em argumentos nem fica no script remoto.
printf '%s' "$REGISTRY_TOKEN" | ssh_vps "docker login ghcr.io -u $(printf '%q' "$REGISTRY_USER") --password-stdin" >/dev/null

echo "Atualizando para $IMAGE_REGISTRY/<PROJETO>-*:$IMAGE_TAG"
ssh_vps "bash -s -- $diretorio $(printf '%q %q' "$IMAGE_REGISTRY" "$IMAGE_TAG")" <"$raiz/infra/deploy/update-remote.sh"
```

## `infra/deploy/update-remote.sh` (VPS)

```bash
#!/usr/bin/env bash
# Roda na VPS, recebido por SSH: confere o .env, baixa as imagens do commit, sobe,
# espera o health check e, se não ficarem saudáveis, volta para a versão anterior
# e termina com erro.
#
# Uso: update-remote.sh <diretório> <registry> <tag>
set -euo pipefail

diretorio="$1"
registry="$2"
tag="$3"
espera="${ESPERA_SAUDAVEL_SEGUNDOS:-180}"
servicos=(<SERVICOS_SAUDAVEIS>)

cd "$diretorio"

# 1. O deploy nunca gera segredo: na primeira execução cria o .env e FALHA.
if [[ ! -f .env ]]; then
  cp .env.prod.example .env
  chmod 600 .env
  echo "::error::.env criado em $diretorio a partir do .env.prod.example. Troque os PREENCHER pelos valores reais e rode o deploy de novo." >&2
  exit 1
fi

pendentes="$(grep -E '^[A-Z_]+=PREENCHER' .env | cut -d= -f1 | paste -sd ' ' - || true)"
if [[ -n "$pendentes" ]]; then
  echo "::error::Preencha em $diretorio/.env: $pendentes" >&2
  exit 1
fi

# 2. A tag vai pelo ambiente do comando: o deploy não edita o .env.
compose() {
  local versao="$1"
  shift
  env IMAGE_REGISTRY="$registry" IMAGE_TAG="$versao" \
    docker compose -f docker-compose.prod.yml --env-file .env "$@"
}

saudaveis() {
  local versao="$1" limite=$((SECONDS + espera)) servico id estado todos
  while ((SECONDS < limite)); do
    todos=1
    for servico in "${servicos[@]}"; do
      id="$(compose "$versao" ps -q "$servico")"
      estado="ausente"
      [[ -n "$id" ]] && estado="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$id")"
      [[ "$estado" == "healthy" ]] || todos=0
    done
    ((todos)) && return 0
    sleep 5
  done
  return 1
}

anterior="$(cat .versao-atual 2>/dev/null || true)"

compose "$tag" pull
compose "$tag" up -d --remove-orphans

if saudaveis "$tag"; then
  printf '%s\n' "$tag" >.versao-atual
  # Mantém só a versão atual, a anterior (volta rápida) e a latest.
  for servico in "${servicos[@]}"; do
    imagem="<PROJETO>-$servico"
    docker images "$registry/$imagem" --format '{{.Tag}}' |
      { grep -vxF -e "$tag" -e "${anterior:-$tag}" -e latest || true; } |
      while read -r antiga; do docker rmi "$registry/$imagem:$antiga" >/dev/null || true; done
  done
  docker image prune -f >/dev/null
  echo "Deploy de $tag concluído."
  exit 0
fi

echo "::error::${servicos[*]} não ficaram saudáveis em ${espera}s." >&2
compose "$tag" ps >&2 || true
compose "$tag" logs --tail 50 >&2 || true

if [[ -n "$anterior" && "$anterior" != "$tag" ]]; then
  echo "Voltando para $anterior." >&2
  compose "$anterior" up -d --remove-orphans
fi
exit 1
```

Ajustes comuns: variáveis de runtime extras (ex.: prefixo de caminho do Traefik) entram como
quarto argumento e são repassadas dentro de `compose()` via `env`, nunca gravadas no `.env`.
O nome do serviço no compose deve coincidir com o sufixo da imagem (`<PROJETO>-<servico>`).

## Runbook: `infra/deploy/README.md`

Copiar a estrutura abaixo (o bloco já começa com o título `# Deploy na VPS`; não acrescentar outro) e preencher com os dados reais do projeto.

```markdown
# Deploy na VPS

Decisão na `ADR-<NNN>`. A VPS recebe só as imagens publicadas no registry, o compose de
produção e o `.env.prod.example`; nenhum código-fonte e nenhum clone do repositório.

## Fluxo

1. Push na branch de produção: o workflow **CI** roda lint, build e testes. Não muda com o deploy.
2. O workflow **Deploy** dispara quando o CI de um push na branch de produção deste
   repositório termina com sucesso, ou pelo botão *Run workflow* na branch de produção.
3. `build-and-push` builda os serviços no runner e publica `:latest` e `:<sha>`.
4. `deploy` (ambiente `production`): entra por SSH com host verificado, envia o compose,
   faz login no registry só durante o deploy, sobe as imagens **do commit**, espera os
   serviços ficarem `healthy` e, se não ficarem em 180 s, volta para a versão anterior e falha.

## Preparar a VPS (uma vez)

1. Docker Engine com o plugin `compose`.
2. Usuário de deploy dedicado, só com chave SSH, no grupo `docker` (equivale a root: não
   reaproveitar usuário pessoal).
3. Proxy reverso/redes externas necessárias, existentes antes do primeiro deploy.
4. Primeiro deploy: rode o workflow uma vez. Ele cria `$DEPLOY_PATH/.env` a partir do
   exemplo, com `chmod 600`, e falha pedindo os valores.
5. Troque todo `PREENCHER` no `.env` e rode de novo. O deploy nunca edita o `.env`.

## Secrets do GitHub (uma vez)

No ambiente `production` (Settings → Environments, restrito à branch de produção).

| Secret | Conteúdo |
|---|---|
| `DEPLOY_HOST` | IP ou domínio da VPS |
| `DEPLOY_USER` | Usuário de deploy |
| `DEPLOY_SSH_KEY` | Chave privada dedicada ao deploy (ed25519); a pública vai em `~/.ssh/authorized_keys` |
| `DEPLOY_KNOWN_HOSTS` | Saída de `ssh-keyscan -p <porta> <host>`, conferida com a impressão digital da VPS |
| `DEPLOY_PORT` | Opcional; padrão `22` |
| `DEPLOY_PATH` | Diretório da stack na VPS; opcional |
| `REGISTRY_PULL_USER` e `REGISTRY_PULL_TOKEN` | Opcionais: token com `read:packages`, se a VPS não baixar com o `GITHUB_TOKEN` do job |

## Migrações

Não rodam no deploy (pode haver migração destrutiva). Listar aqui, na ordem, cada migração
com: o que faz, se é idempotente/destrutiva e o comando `docker compose exec`.

## Comandos à mão e volta de versão

    cd $DEPLOY_PATH
    IMAGE_TAG="$(cat .versao-atual)" docker compose -f docker-compose.prod.yml ps
    IMAGE_TAG=<sha do commit> docker compose -f docker-compose.prod.yml up -d   # voltar uma versão

Para um commit cuja imagem já saiu da VPS, faça login no registry antes. Voltar a versão
não desfaz migrações.

## Cuidados

- O deploy sobrescreve `docker-compose.prod.yml` e `.env.prod.example`: ajuste local vai no `.env`.
- Backup do banco não faz parte deste fluxo.
- Logs dos containers com rotação configurada no compose.
```

## Validação

| Cenário | Como validar | Esperado |
|---|---|---|
| Secret obrigatório ausente | Remover `DEPLOY_HOST` | `deploy-remote.sh` falha listando o que falta, antes de abrir SSH |
| `.env` ausente | VPS sem `.env` | Cria a partir do exemplo e falha |
| Placeholder no `.env` | Deixar `PREENCHER` | Falha listando as chaves |
| Versão saudável | Deploy normal | `.versao-atual` atualizado; imagens antigas removidas, mantendo atual/anterior/`latest` |
| Versão doente | Health check quebrado | Logs impressos, versão anterior restaurada, job falha |
| Primeiro deploy sem versão anterior | VPS nova com imagem doente | Job falha sem rollback (não há versão anterior), sem loop |
| Token | Inspecionar `ps` na VPS durante o deploy | Token não aparece em argumentos |

## Riscos e pontos de atenção

- `docker logout` roda ao final (`trap`), mas uma queda de SSH pode deixá-lo para a próxima execução.
- Rollback restaura imagens, não dados.
- Os scripts presumem `healthcheck` declarado no compose; serviço sem health check cai em `State.Status`
  (`running`), que nunca é `healthy` — declarar o health check ou ajustar `saudaveis()`.

## ADR

Registrar ADR (`.ai/structure/templates/adr-template.md`) para a estratégia de deploy do projeto.
