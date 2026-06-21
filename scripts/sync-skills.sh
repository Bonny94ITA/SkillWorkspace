#!/usr/bin/env bash
# Rinfresca le skill curate dalla install locale (~/.agents/skills) dentro
# questo marketplace. Rilancia quando skills.sh aggiorna gli originali, poi:
#   git add -A && git commit -m "Sync skills" && git push
set -euo pipefail

SRC="${HOME}/.agents/skills"
DEST="$(cd "$(dirname "$0")/.." && pwd)/plugins/workspace-skills/skills"

# Set curato (no Azure/Microsoft). Aggiungi/togli nomi qui per cambiare lo scope.
SKILLS=(
  accessibility
  cavecrew
  caveman
  caveman-commit
  caveman-compress
  caveman-help
  caveman-review
  caveman-stats
  codebase-design
  core-web-vitals
  domain-modeling
  find-skills
  grilling
  improve-codebase-architecture
  performance
  seo
  seo-audit
  vercel-composition-patterns
  vercel-react-best-practices
  vercel-react-native-skills
  vercel-react-view-transitions
  web-design-guidelines
  web-quality-audit
)

echo "Sync di ${#SKILLS[@]} skill da ${SRC}"
mkdir -p "${DEST}"
for s in "${SKILLS[@]}"; do
  if [ ! -d "${SRC}/${s}" ]; then
    echo "  SKIP (mancante): ${s}"
    continue
  fi
  rm -rf "${DEST:?}/${s}"
  cp -R "${SRC}/${s}" "${DEST}/${s}"
  echo "  ok: ${s}"
done

# Rimuovi cruft macOS
find "${DEST}" -name '.DS_Store' -delete 2>/dev/null || true
echo "Fatto. Controlla con: git status"
