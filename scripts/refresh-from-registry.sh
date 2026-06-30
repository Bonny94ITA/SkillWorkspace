#!/usr/bin/env bash
# Rinfresca le skill curate di SkillWorkspace dal registry skills.sh (npx skills).
#
# A differenza di sync-skills.sh (che legge l'install locale ~/.agents/skills),
# questo scarica le sorgenti dichiarate in scripts/sources.txt: funziona quindi
# anche in una sessione cloud isolata, senza install locale e senza il Mac.
#
# Semantica MERGE: sovrascrive i file forniti dalla sorgente ma PRESERVA i file
# extra gia' presenti nello snapshot (es. metadata.json, che npx non rigenera),
# cosi' la sync cloud e quella locale non si combattono. Rispecchia SOLO le skill
# gia' presenti in plugins/workspace-skills/skills/ (il set curato); le skill la
# cui sorgente non e' ancora in sources.txt restano INTATTE. Non fa commit/push.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCES="$ROOT/scripts/sources.txt"
DEST="$ROOT/plugins/workspace-skills/skills"

log() { echo "[refresh] $*" >&2; }

[ -f "$SOURCES" ] || { log "ERRORE: $SOURCES mancante"; exit 1; }
[ -d "$DEST" ]    || { log "ERRORE: $DEST mancante"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/install"

# Leggo le sorgenti in un array PRIMA del loop: npx legge da stdin e altrimenti
# divorerebbe il resto del file (installando solo la prima riga).
mapfile -t LINES < "$SOURCES"
for line in "${LINES[@]}"; do
  src="${line%%#*}"
  src="$(echo "$src" | xargs)"   # rimuove spazi e commenti inline
  [ -n "$src" ] || continue
  log "npx skills add $src"
  if ! ( cd "$TMP/install" && timeout 300 npx -y skills add "$src" --yes </dev/null >/dev/null 2>&1 ); then
    log "WARN: 'npx skills add $src' fallito; salto questa sorgente"
  fi
done

SRC="$TMP/install/.agents/skills"
if [ ! -d "$SRC" ]; then
  log "ERRORE: nessuna skill installata (rete? sorgenti?); nessuna modifica"
  exit 1
fi

# Rispecchia solo le skill curate gia' presenti. Set fisso = cartelle esistenti.
updated=0; aligned=0; nosource=0
for d in "$DEST"/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  if [ ! -d "$SRC/$name" ]; then
    nosource=$((nosource + 1))
    log "senza sorgente in sources.txt (lasciata intatta): $name"
    continue
  fi

  # Drift = un qualsiasi file fornito dalla sorgente manca o differisce in dest.
  drift=0
  while IFS= read -r f; do
    rel="${f#"$SRC/$name/"}"
    if ! cmp -s "$f" "$DEST/$name/$rel"; then drift=1; break; fi
  done < <(find "$SRC/$name" -type f)

  if [ "$drift" -eq 1 ]; then
    cp -R "$SRC/$name/." "$DEST/$name/"   # overwrite dei file sorgente, extra preservati
    updated=$((updated + 1))
    log "AGGIORNATA: $name"
  else
    aligned=$((aligned + 1))
  fi
done

find "$DEST" -name '.DS_Store' -delete 2>/dev/null || true
log "Riepilogo: $updated aggiornate, $aligned gia' allineate, $nosource senza sorgente"
