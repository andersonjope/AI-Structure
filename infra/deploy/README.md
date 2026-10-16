# Deploy na VPS

Runbook de deploy do projeto. Este arquivo é o **esqueleto**: ao adotar o pipeline, preencher os
marcadores abaixo com os dados reais e adicionar os scripts `deploy-remote.sh` e
`update-remote.sh` desta pasta (modelos em `.ai/structure/templates/deploy-scripts-template.md`).

Regras: `.ai/structure/rules/deploy.md`. Workflow: `.ai/structure/templates/deploy-workflow-template.md`.
Decisão: `ADR-<NNN>` (registrar a estratégia de deploy do projeto).

A VPS recebe só as imagens publicadas no registry, o compose de produção e o `.env.prod.example`;
nenhum código-fonte e nenhum clone do repositório.

## Fluxo

1. Push na branch de produção: o workflow **CI** roda lint, build e testes. Não muda com o deploy.
2. O workflow **Deploy** dispara quando o CI de um push na branch de produção deste repositório
   termina com sucesso, ou pelo botão *Run workflow* na branch de produção.
3. `build-and-push` builda os serviços no runner e publica `:latest` e `:<sha>`.
4. `deploy` (ambiente `production`): entra por SSH com host verificado, envia o compose, faz login
   no registry só durante o deploy, sobe as imagens **do commit**, espera os serviços ficarem
   `healthy` e, se não ficarem em 180 s, volta para a versão anterior e falha.

## Migrações

Não rodam no deploy (pode haver migração destrutiva). Listar aqui, na ordem, cada migração com:
o que faz, se é idempotente/destrutiva e o comando `docker compose exec`.

- (nenhuma registrada)

## Guia de primeira configuração (GitHub + VPS)

Legenda de onde executar:

- 💻 **Local**: terminal da sua máquina.
- 🖥️ **VPS (admin)**: terminal da VPS, logado com um usuário com `sudo`.
- 🖥️ **VPS (deploy)**: terminal da VPS, como `<USUARIO_DEPLOY>` (via `sudo -u <USUARIO_DEPLOY> ...`).
- 🐙 **GitHub**: navegador, no repositório.

Marcadores a substituir: `<PROJETO>`, `<DEPLOY_PATH>` (ex.: `/opt/<PROJETO>`), `<USUARIO_DEPLOY>`,
`SEU_HOST` (IP ou domínio da VPS), `NOME_MONGO` (container do Mongo), `ADMIN` (usuário
administrador do Mongo), `SENHA_*` (senhas geradas por você). Remover as etapas que a stack do
projeto não usa (ex.: Etapa 6 sem MongoDB).

### Resumo: o que vai em cada variável

#### Secrets do GitHub (ambiente `production`)

| Secret | Obrigatório | O que colocar | De onde copiar |
|---|---|---|---|
| `DEPLOY_HOST` | sim | IP ou domínio da VPS | você já sabe |
| `DEPLOY_USER` | sim | `<USUARIO_DEPLOY>` | fixo |
| `DEPLOY_SSH_KEY` | sim | chave **privada**, arquivo inteiro com as linhas `BEGIN` e `END` | 💻 `cat ~/.ssh/<PROJETO>_deploy` |
| `DEPLOY_KNOWN_HOSTS` | sim | arquivo inteiro gerado pelo `ssh-keyscan` | 💻 `cat /tmp/known_hosts_vps` |
| `DEPLOY_PORT` | não | porta SSH, só se não for `22` | você já sabe |
| `DEPLOY_PATH` | não | diretório na VPS, só se não for o padrão | você já sabe |
| `REGISTRY_PULL_USER` | não | seu usuário GitHub | só se o `docker pull` falhar |
| `REGISTRY_PULL_TOKEN` | não | token clássico com escopo `read:packages` | GitHub → Developer settings |

`GITHUB_TOKEN` é automático e não deve ser cadastrado.

#### Arquivo `<DEPLOY_PATH>/.env` na VPS

Lista exata em `infra/.env.prod.example` (e `docs/env/README.md`). Resumo por tipo:

| Tipo de variável | O que colocar | De onde vem |
|---|---|---|
| `*_MONGODB_URI` (uma por serviço) | `mongodb://USUARIO:SENHA@NOME_MONGO:27017/BANCO?authSource=BANCO` | Etapa 6 |
| Tokens internos entre serviços | um valor distinto de `openssl rand -hex 32` para cada | Etapa 7 |
| URL pública do app e CORS | origem do app, sem barra no final | seu domínio |
| Integrações externas (SMTP, APIs de terceiros) | credenciais do provedor | painel do provedor |

Chaves com valor padrão no `.env.prod.example` não precisam ser alteradas. O deploy injeta
`IMAGE_REGISTRY` e `IMAGE_TAG` sozinho; eles não entram no `.env`.

---

### Etapa 1 – Gerar a chave SSH de deploy

💻 **Local**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/<PROJETO>_deploy -C "<PROJETO>-deploy" -N ""
cat ~/.ssh/<PROJETO>_deploy.pub
```

- Copie a **linha inteira** do `.pub`. É a chave pública e não é segredo. Ela vai para a Etapa 2.
- O arquivo **sem** `.pub` é a chave privada. Ela só vai para o secret `DEPLOY_SSH_KEY` (Etapa 5),
  nunca para a VPS, chat ou repositório.

### Etapa 2 – Autorizar a chave na VPS

🖥️ **VPS (admin)**

```bash
sudo -u <USUARIO_DEPLOY> mkdir -p /home/<USUARIO_DEPLOY>/.ssh
echo "COLE_AQUI_A_LINHA_INTEIRA_DO_PUB" | sudo -u <USUARIO_DEPLOY> tee -a /home/<USUARIO_DEPLOY>/.ssh/authorized_keys
sudo chmod 700 /home/<USUARIO_DEPLOY>/.ssh
sudo chmod 600 /home/<USUARIO_DEPLOY>/.ssh/authorized_keys
sudo chown -R <USUARIO_DEPLOY>:<USUARIO_DEPLOY> /home/<USUARIO_DEPLOY>/.ssh
```

### Etapa 3 – Conferir pré-requisitos da VPS

🖥️ **VPS (admin)**

```bash
id <USUARIO_DEPLOY>                          # deve listar o grupo "docker"
sudo -u <USUARIO_DEPLOY> docker compose version
docker network ls | grep NOME_REDE_MONGO     # a rede do Mongo deve existir
docker ps --format '{{.Names}}'              # anote o nome do container do Mongo (NOME_MONGO)
sudo mkdir -p <DEPLOY_PATH>
sudo chown <USUARIO_DEPLOY>:<USUARIO_DEPLOY> <DEPLOY_PATH>
```

- Se `id` não mostrar `docker`: `sudo usermod -aG docker <USUARIO_DEPLOY>`.
- Se a rede do Mongo tiver outro nome, ajuste a variável de rede no `.env` (Etapa 9).

### Etapa 4 – Testar o login e gerar o known_hosts

1. 💻 **Local**: testar o acesso.

   ```bash
   ssh -i ~/.ssh/<PROJETO>_deploy <USUARIO_DEPLOY>@SEU_HOST "docker ps >/dev/null && echo OK"
   ```

   Deve imprimir `OK`.

2. 🖥️ **VPS (admin)**: impressão digital do servidor.

   ```bash
   ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
   ```

3. 💻 **Local**: gerar o arquivo e conferir.

   ```bash
   ssh-keyscan -p 22 -t ed25519 SEU_HOST > /tmp/known_hosts_vps
   ssh-keygen -lf /tmp/known_hosts_vps
   cat /tmp/known_hosts_vps
   ```

   - O `SHA256:...` do passo 3 deve ser **igual** ao do passo 2. Se for diferente, pare.
   - Se a porta SSH não for 22, troque o `-p 22`.
   - O conteúdo do `cat` (uma linha: `SEU_HOST ssh-ed25519 AAAA...`) é o valor de `DEPLOY_KNOWN_HOSTS`.
   - O `SEU_HOST` dessa linha deve ser idêntico ao valor de `DEPLOY_HOST`.

### Etapa 5 – Cadastrar os secrets no GitHub

🐙 **GitHub**

1. **Settings → Environments → New environment**, nome `production`.
2. Em *Deployment branches*: *Selected branches* → adicionar `main`.
3. Em *Environment secrets → Add secret*, cadastre cada item da tabela de secrets acima:
   - `DEPLOY_SSH_KEY`: cole o resultado de 💻 `cat ~/.ssh/<PROJETO>_deploy` (inclui `-----BEGIN` e `-----END`).
   - `DEPLOY_KNOWN_HOSTS`: cole o resultado de 💻 `cat /tmp/known_hosts_vps`.
   - Os demais: valores simples, como na tabela.
4. 💻 **Local**, depois de cadastrar, se não precisar mais da privada local:

   ```bash
   shred -u ~/.ssh/<PROJETO>_deploy
   ```

### Etapa 6 – Criar os usuários e as URIs do MongoDB

Só se o projeto usa MongoDB com um banco e um usuário por serviço.

1. 🖥️ **VPS (admin)**: gerar uma senha forte por banco. O `tr` troca `/` e `+`, que quebrariam a URI.

   ```bash
   openssl rand -base64 24 | tr '/+' '_-'
   ```

2. 🖥️ **VPS (admin)**: entrar no Mongo.

   ```bash
   docker exec -it NOME_MONGO mongosh -u ADMIN -p --authenticationDatabase admin
   ```

3. Dentro do `mongosh`, repetir para cada banco (nomes conforme o script de inicialização do Mongo do projeto):

   ```js
   use BANCO
   db.createUser({user:"USUARIO_BANCO", pwd:"SENHA_BANCO", roles:[{role:"readWrite", db:"BANCO"}]})
   ```

4. Montar cada URI para o `.env` (host = nome do container do Mongo na rede compartilhada):

   ```
   mongodb://USUARIO_BANCO:SENHA_BANCO@NOME_MONGO:27017/BANCO?authSource=BANCO
   ```

   Senha com caractere especial precisa de URL-encode.

### Etapa 7 – Gerar os tokens internos

🖥️ **VPS (admin)**: rodar uma vez por token interno exigido pelo `.env.prod.example`, guardando
cada resultado (todos diferentes).

```bash
openssl rand -hex 32
```

### Etapa 8 – Primeiro deploy (falha de propósito)

🐙 **GitHub**: **Actions → Deploy → Run workflow** na branch `main`.

Ele cria `<DEPLOY_PATH>/.env` a partir do exemplo e falha pedindo os valores. É o esperado.

### Etapa 9 – Preencher o `.env`

🖥️ **VPS (deploy)**

```bash
sudo -u <USUARIO_DEPLOY> nano <DEPLOY_PATH>/.env
```

Preencha cada `PREENCHER` conforme a tabela do `.env` no início deste guia. Depois confira:

```bash
sudo -u <USUARIO_DEPLOY> chmod 600 <DEPLOY_PATH>/.env
grep PREENCHER <DEPLOY_PATH>/.env     # não deve retornar nada
```

Valores externos (ex.: SMTP, APIs de terceiros): obtenha no provedor de cada integração. Tokens
de API costumam expirar; confirme validade e renovação no portal do provedor. Para e-mail,
verifique o domínio e configure SPF e DKIM no DNS, senão as mensagens caem no spam.

### Etapa 10 – Proxy reverso com TLS

🖥️ **VPS (admin)**, no proxy já existente (Nginx, Caddy ou outro):

- domínio do app → `127.0.0.1:<PORTA_APP>`
- domínio da API → `127.0.0.1:<PORTA_API>`

Os dois domínios precisam apontar no DNS para a VPS, com certificado TLS válido.

### Etapa 11 – Deploy definitivo

🐙 **GitHub**: **Actions → Deploy → Run workflow** na branch `main`.

O job espera os serviços listados em `<SERVICOS_SAUDAVEIS>` ficarem `healthy` por até 180 s. Se
algum não ficar, volta para a versão anterior e falha.

### Etapa 12 – Verificar

🖥️ **VPS (deploy)**

```bash
cd <DEPLOY_PATH>
IMAGE_TAG="$(cat .versao-atual)" docker compose -f docker-compose.prod.yml ps
```

---

### Se o deploy falhar no `docker pull`

1. 🐙 **GitHub** → Settings → Developer settings → Personal access tokens (classic): gerar token com
   escopo `read:packages`.
2. 🐙 **GitHub** → Environment secrets (`production`): cadastrar `REGISTRY_PULL_USER` (seu usuário
   GitHub) e `REGISTRY_PULL_TOKEN` (o token).
3. Rodar o workflow **Deploy** de novo.

### Voltar uma versão

🖥️ **VPS (deploy)**

```bash
cd <DEPLOY_PATH>
IMAGE_TAG=<sha do commit> docker compose -f docker-compose.prod.yml up -d
```

Para um commit cuja imagem já saiu da VPS, faça `docker login ghcr.io` antes. Voltar a versão não
desfaz migrações.

### Cuidados

- Nunca versione o `.env` nem a chave privada.
- O deploy sobrescreve `docker-compose.prod.yml` e `.env.prod.example`; ajuste local vai no `.env`.
- Backup do banco não faz parte deste fluxo.
- Logs dos containers com rotação configurada no compose.
