# SkillWorkspace

Catalogo personale di skill riusabili per Claude Code. Fonte di verita':
`plugins/workspace-skills/skills/`. Si propaga ai progetti reali **copiando
file** in `.claude/skills/`, non via plugin marketplace (testato: non
funziona nelle sessioni cloud — vedi README per i dettagli e i link ai bug/doc
che lo confermano).

## Struttura

```
plugins/workspace-skills/skills/<nome>/SKILL.md   # fonte di verita' delle skill
scripts/sync-skills.sh        # refresh da ~/.agents/skills (skills.sh) locale
scripts/inject-skills.sh      # copia le skill in un progetto locale
templates/bootstrap-prompt.md # iniezione via sessione cloud, senza clone locale
```

## Workflow

- Modificare/aggiungere skill: editare sotto `plugins/workspace-skills/skills/`, commit, push.
- Rinfrescare dall'install locale skills.sh: `bash scripts/sync-skills.sh`.
- Propagare a un progetto locale: `bash scripts/inject-skills.sh /path/progetto [skill...]`.
- Propagare a una sessione cloud senza clone locale: incollare `templates/bootstrap-prompt.md`.

Nessuna propagazione automatica: ogni progetto ha uno snapshot fissato al
momento dell'iniezione, va ripetuta dopo ogni aggiornamento qui.
