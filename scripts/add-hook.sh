#!/usr/bin/env bash
# Onboarda una repo operativa: installa il SessionStart hook che allinea
# .claude/skills/ a SkillWorkspace ad ogni avvio sessione (cloud e locale).
#
# Uso:
#   bash scripts/add-hook.sh /percorso/della/repo
#
# Cosa fa:
#   - copia templates/sync-skills-hook.sh -> <repo>/.claude/hooks/sync-skills.sh
#   - registra l'hook in <repo>/.claude/settings.json (crea o fa merge)
# NON committa: controlli il diff e committi tu.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/templates/sync-skills-hook.sh"
TARGET="${1:-}"

if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
  echo "Uso: $0 /percorso/della/repo" >&2
  exit 1
fi
[ -f "$TEMPLATE" ] || { echo "ERRORE: template mancante: $TEMPLATE" >&2; exit 1; }

HOOK_DIR="$TARGET/.claude/hooks"
SETTINGS="$TARGET/.claude/settings.json"
mkdir -p "$HOOK_DIR"

cp "$TEMPLATE" "$HOOK_DIR/sync-skills.sh"
chmod +x "$HOOK_DIR/sync-skills.sh"
echo "ok: installato $HOOK_DIR/sync-skills.sh"

# Registra/mergia l'hook in settings.json mantenendo la config eventualmente esistente.
CMD='$CLAUDE_PROJECT_DIR/.claude/hooks/sync-skills.sh'
node - "$SETTINGS" "$CMD" <<'NODE'
const fs = require("fs");
const [file, cmd] = process.argv.slice(2);
let cfg = {};
if (fs.existsSync(file)) {
  try { cfg = JSON.parse(fs.readFileSync(file, "utf8")); }
  catch (e) { console.error("ERRORE: settings.json non valido, non lo tocco:", e.message); process.exit(1); }
}
cfg.hooks = cfg.hooks || {};
const arr = (cfg.hooks.SessionStart = cfg.hooks.SessionStart || []);
const has = JSON.stringify(arr).includes("sync-skills.sh");
if (!has) {
  arr.push({ hooks: [{ type: "command", command: cmd }] });
  fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + "\n");
  console.log("ok: hook registrato in " + file);
} else {
  console.log("gia' presente: hook in " + file + " (nessuna modifica)");
}
NODE

echo
echo "Fatto. Ora, dentro $TARGET:"
echo "  git add .claude && git commit -m 'Add skills sync SessionStart hook' && git push"
