# SkillWorkspace

Catalogo personale di skill riusabili per Claude Code. Fonte di verita':
`plugins/workspace-skills/skills/`. Si mantiene fresca dal registry skills.sh e
si propaga ai progetti **copiando file** in `.claude/skills/` (non via plugin
marketplace, che in cloud non carica le skill — vedi README). Dettagli del
flusso automatico nel README.

## Struttura

```
plugins/workspace-skills/skills/<nome>/SKILL.md   # fonte di verita' delle skill
scripts/refresh-from-registry.sh # refresh dal registry skills.sh (npx), funziona in cloud
scripts/sources.txt           # elenco sorgenti owner/repo per refresh-from-registry.sh
scripts/add-hook.sh           # onboarda una repo: installa il SessionStart hook
templates/sync-skills-hook.sh # template canonico dell'hook (installato da add-hook.sh)
templates/bootstrap-prompt.md # iniezione via sessione cloud, senza clone locale
```

## Workflow

- Modificare/aggiungere skill: editare sotto `plugins/workspace-skills/skills/`, commit, push.
- Rinfrescare dal registry (anche in cloud): `bash scripts/refresh-from-registry.sh`.
- Onboardare una repo (nuova o esistente): `bash scripts/add-hook.sh /path/repo`, poi commit/push nella repo.
- Propagare a una sessione cloud senza clone locale: incollare `templates/bootstrap-prompt.md`.

## Allineamento automatico

- **Fonte di verita' -> repo operativa**: ogni progetto ha un `SessionStart`
  hook (`.claude/hooks/sync-skills.sh`) che a ogni avvio sessione ricopia le
  skill da questo repo in `.claude/skills/`. La repo operativa si aggiorna
  quando ci si lavora.
- **Registry -> fonte di verita'**: una routine settimanale (cloud) lancia
  `scripts/refresh-from-registry.sh` e apre una PR se trova skill non allineate
  rispetto a `scripts/sources.txt`. Le skill la cui sorgente non e' ancora in
  `sources.txt` restano intatte.

Nessuna propagazione "a spinta": la repo operativa cambia solo quando ci si
lavora, non quando e' inattiva.
