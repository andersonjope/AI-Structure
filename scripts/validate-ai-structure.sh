#!/usr/bin/env bash
# Valida a integridade da governanca em .ai/:
#   1. Todo caminho `.ai/**/*.md` referenciado em algum arquivo .md do repo precisa existir.
#   2. Todo slug de agente citado nas matrizes de roteamento (linhas com "->" ou na
#      tabela de .ai/structure/agents/README.md) precisa corresponder a um arquivo
#      real em .ai/structure/agents/.
#   3. Todo arquivo real em .ai/structure/agents/ precisa aparecer, como slug entre
#      crases, no roster de AGENTS.md ("Papeis disponiveis") e de CLAUDE.md (time
#      tecnico) — evita agente orfao, nunca listado como papel disponivel.
#   4. Toda skill em .claude/skills/<nome>/SKILL.md precisa ter frontmatter com
#      `name` igual ao diretorio e `description` preenchida.
#
# Uso: scripts/validate-ai-structure.sh
# Saida: exit 0 se tudo ok, exit 1 se encontrar qualquer inconsistencia.

set -uo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

status=0

echo "== 1. Links .ai/**/*.md =="
missing_links=""
while IFS= read -r path; do
  [ -f "$path" ] || missing_links="${missing_links}${path}"$'\n'
done < <(grep -rohE '\.ai/[A-Za-z0-9_./-]+\.md' --include='*.md' . | sort -u)

if [ -n "$missing_links" ]; then
  echo "FALHA: referencias a arquivos .ai/*.md inexistentes:"
  echo "$missing_links" | sed '/^$/d' | sed 's/^/  - /'
  status=1
else
  echo "OK"
fi

echo
echo "== 2. Slugs de agente nas matrizes de roteamento =="
agents_dir=".ai/structure/agents"
real_agents="$(find "$agents_dir" -maxdepth 1 -name '*.md' ! -name 'README.md' -exec basename {} .md \; | sort)"

to_slug() {
  # "Domain Designer" -> "domain-designer" ; "domain-designer" -> "domain-designer"
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-'
}

bad_routing=""
routing_lines="$(grep -rn -- '->' --include='*.md' CLAUDE.md AGENTS.md .github/copilot-instructions.md "$agents_dir/README.md" 2>/dev/null || true)"
while IFS= read -r line; do
  [ -z "$line" ] && continue
  file="${line%%:*}"
  rest="${line#*:}"
  content="${rest#*:}"
  # a linha segue o padrao "Descricao da tarefa: agente1 -> agente2 -> agente3."
  # descarta a descricao da tarefa (antes do primeiro ':' restante) para nao
  # tratar palavras do enunciado (ex: "Frontend Ionic Angular") como agente.
  case "$content" in
    *:*) chain="${content#*:}" ;;
    *) chain="$content" ;;
  esac
  # extrai tokens entre backticks OU sequencias de Palavras-Com-Maiuscula separadas por espaco
  tokens="$(echo "$chain" | grep -oE '`[a-zA-Z][a-zA-Z0-9 -]*`|\b([A-Z][a-z]+ )+[A-Z][a-z]+\b' | tr -d '`')"
  while IFS= read -r token; do
    [ -z "$token" ] && continue
    slug="$(to_slug "$token")"
    if ! printf '%s\n' "$real_agents" | grep -qx "$slug"; then
      bad_routing="${bad_routing}${file}: \"${token}\" -> esperado agente \`${slug}\` inexistente em ${agents_dir}/"$'\n'
    fi
  done <<< "$tokens"
done <<< "$routing_lines"

# tabela markdown de .ai/structure/agents/README.md (celulas com `slug`)
table_tokens="$(grep -E '^\| .* \| `' "$agents_dir/README.md" | grep -oE '`[a-z][a-z0-9-]*`' | tr -d '`' | sort -u)"
while IFS= read -r slug; do
  [ -z "$slug" ] && continue
  if ! printf '%s\n' "$real_agents" | grep -qx "$slug"; then
    bad_routing="${bad_routing}${agents_dir}/README.md: tabela cita \`${slug}\`, agente inexistente"$'\n'
  fi
done <<< "$table_tokens"

if [ -n "$bad_routing" ]; then
  echo "FALHA: matrizes de roteamento citam agentes que nao existem como arquivo:"
  echo "$bad_routing" | sed '/^$/d' | sed 's/^/  - /'
  status=1
else
  echo "OK"
fi

echo
echo "== 3. Agentes orfaos (arquivo existe mas nao esta listado nos entry points) =="
orphans=""
roster_files="AGENTS.md CLAUDE.md"
for roster_file in $roster_files; do
  while IFS= read -r agent; do
    [ -z "$agent" ] && continue
    grep -q "\`${agent}\`" "$roster_file" || orphans="${orphans}${roster_file}: falta \`${agent}\`"$'\n'
  done <<< "$real_agents"
done

if [ -n "$orphans" ]; then
  echo "FALHA: agentes sem entrada no roster de algum entry point:"
  echo "$orphans" | sed '/^$/d' | sed 's/^/  - /'
  status=1
else
  echo "OK"
fi

echo
echo "== 4. Skills em .claude/skills =="
bad_skills=""
if [ -d .claude/skills ]; then
  for dir in .claude/skills/*/; do
    [ -d "$dir" ] || continue
    skill="$(basename "$dir")"
    file="${dir}SKILL.md"
    if [ ! -f "$file" ]; then
      bad_skills="${bad_skills}${skill}: falta SKILL.md"$'\n'
      continue
    fi
    front="$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$file")"
    name="$(printf '%s\n' "$front" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
    desc="$(printf '%s\n' "$front" | sed -n 's/^description:[[:space:]]*//p' | head -1)"
    [ "$name" = "$skill" ] || bad_skills="${bad_skills}${skill}: frontmatter 'name' (\"${name}\") diferente do diretorio"$'\n'
    [ -n "$desc" ] || bad_skills="${bad_skills}${skill}: frontmatter sem 'description'"$'\n'
  done
fi

if [ -n "$bad_skills" ]; then
  echo "FALHA: skills invalidas:"
  echo "$bad_skills" | sed '/^$/d' | sed 's/^/  - /'
  status=1
else
  echo "OK"
fi

echo
if [ "$status" -eq 0 ]; then
  echo "Validacao da estrutura .ai/ passou."
else
  echo "Validacao da estrutura .ai/ FALHOU."
fi

exit "$status"
