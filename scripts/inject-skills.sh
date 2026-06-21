#!/usr/bin/env bash
# Inietta le skill curate di SkillWorkspace in un altro progetto LOCALE.
# Uso (da qualsiasi cartella):
#   bash /Users/giacomo/Claude/SkillWorkspace/scripts/inject-skills.sh /percorso/progetto
#   bash .../inject-skills.sh /percorso/progetto seo accessibility   # solo alcune skill
#
# Copia i file in <progetto>/.claude/skills/ (mirror per le skill scelte: le
# rimuove e ricopia, senza toccare altre skill custom del progetto). NON fa
# commit/push: lo decidi tu dopo aver controllato il diff.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)/plugins/workspace-skills/skills"
TARGET="${1:-}"
shift || true

if [ -z "${TARGET}" ] || [ ! -d "${TARGET}" ]; then
  echo "Uso: $0 /percorso/progetto [skill1 skill2 ...]" >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
  SKILLS=("$@")
else
  SKILLS=()
  for d in "${SRC}"/*/; do
    SKILLS+=("$(basename "${d}")")
  done
fi

DEST="${TARGET}/.claude/skills"
mkdir -p "${DEST}"

echo "Inietto ${#SKILLS[@]} skill in ${DEST}"
for s in "${SKILLS[@]}"; do
  if [ ! -d "${SRC}/${s}" ]; then
    echo "  SKIP (non esiste in SkillWorkspace): ${s}"
    continue
  fi
  rm -rf "${DEST:?}/${s}"
  cp -R "${SRC}/${s}" "${DEST}/${s}"
  echo "  ok: ${s}"
done

find "${DEST}" -name '.DS_Store' -delete 2>/dev/null || true

echo
echo "Fatto. Ora, dentro ${TARGET}:"
echo "  git add .claude/skills && git commit -m 'Add shared skills' && git push"
