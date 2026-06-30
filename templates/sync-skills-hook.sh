#!/usr/bin/env bash
# SessionStart hook: allinea .claude/skills/ alla fonte di verita' (SkillWorkspace).
#
# Ad ogni avvio di sessione (cloud o locale) clona SkillWorkspace in shallow e
# ricopia nel progetto tutte le skill curate. Cosi' la repo operativa si porta
# dietro l'ultima versione delle skill nel momento in cui ci lavori.
#
# Principi: idempotente, non interattivo, non fatale (se il clone fallisce la
# sessione parte comunque con le skill gia' committate). Tutti i messaggi vanno
# su stderr per non inquinare il contesto della sessione.
#
# Questo file e' il TEMPLATE canonico mantenuto in SkillWorkspace; viene
# installato nelle repo operative da scripts/add-hook.sh.
set -uo pipefail

SKILLS_REPO="https://github.com/bonny94ita/skillworkspace"
SRC_SUBDIR="plugins/workspace-skills/skills"
DEST="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/skills"

log() { echo "[skills-sync] $*" >&2; }

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

if ! git clone --depth 1 --quiet "$SKILLS_REPO" "$TMP/sw" 2>/dev/null; then
  log "WARN: clone di SkillWorkspace fallito; mantengo le skill gia' committate"
  exit 0
fi

SRC="$TMP/sw/$SRC_SUBDIR"
if [ ! -d "$SRC" ]; then
  log "WARN: cartella skill non trovata in SkillWorkspace ($SRC_SUBDIR); nessuna modifica"
  exit 0
fi

mkdir -p "$DEST"
changed=0
synced=0
# Mirror per ogni skill presente nella fonte di verita'. Le skill eventualmente
# presenti solo nel progetto (custom) NON vengono toccate.
for srcdir in "$SRC"/*/; do
  [ -d "$srcdir" ] || continue
  s="$(basename "$srcdir")"
  if ! diff -rq "$srcdir" "$DEST/$s" >/dev/null 2>&1; then
    changed=1
  fi
  rm -rf "${DEST:?}/$s"
  cp -R "$srcdir" "$DEST/$s"
  synced=$((synced + 1))
done

# Rimuovi cruft macOS che puo' arrivare dallo snapshot
find "$DEST" -name '.DS_Store' -delete 2>/dev/null || true

if [ "$changed" -eq 1 ]; then
  log "$synced skill sincronizzate da SkillWorkspace (rilevate modifiche)"
else
  log "$synced skill verificate, gia' allineate a SkillWorkspace"
fi
exit 0
