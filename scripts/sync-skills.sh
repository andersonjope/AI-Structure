#!/usr/bin/env bash
# Copia as skills de .claude/skills (fonte unica) para .agents/skills, pasta lida pelo
# Codex e pelo GitHub Copilot (o Claude Code le .claude/skills). Remove do destino o que
# nao existe mais na fonte.
#
# Uso: scripts/sync-skills.sh          (sincroniza)
#      scripts/sync-skills.sh --check  (so confere; exit 1 se houver diferenca)

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if [ ! -d .claude/skills ]; then
  echo "ERRO: .claude/skills nao existe." >&2
  exit 1
fi

if [ "${1:-}" = "--check" ]; then
  if [ -d .agents/skills ] && diff -r .claude/skills .agents/skills >/dev/null 2>&1; then
    exit 0
  fi
  exit 1
fi

mkdir -p .agents
rm -r -- .agents/skills 2>/dev/null || true
cp -R .claude/skills .agents/skills
echo "Skills sincronizadas: .claude/skills -> .agents/skills ($(find .agents/skills -name SKILL.md | wc -l) skills)"
