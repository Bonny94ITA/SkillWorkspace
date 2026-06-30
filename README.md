# SkillWorkspace

Catalogo personale di **skill riusabili** per Claude Code. Una sola fonte di
verità — `plugins/workspace-skills/skills/` — che si mantiene aggiornata dal
registry [skills.sh](https://www.skills.sh) e si propaga ai progetti reali
copiando i file in `.claude/skills/`.

## Come funziona

```
                 skills.sh (npx skills)
                         │  refresh settimanale (cloud) → PR
                         ▼
   plugins/workspace-skills/skills/   ← FONTE DI VERITÀ (questo repo)
                         │  SessionStart hook, ad ogni sessione
                         ▼
   repo operativa/.claude/skills/     ← si aggiorna quando ci lavori
```

Due meccanismi automatici, una sola cosa da curare a mano (le skill qui dentro):

1. **Registry → fonte di verità.** Una routine settimanale in cloud lancia
   `scripts/refresh-from-registry.sh`, che reinstalla le sorgenti elencate in
   `scripts/sources.txt` via `npx skills` e apre una PR se trova skill non
   allineate. Funziona senza il Mac.
2. **Fonte di verità → repo operativa.** Ogni progetto ha un `SessionStart`
   hook che, a ogni avvio sessione (cloud o locale), ricopia le skill da questo
   repo in `.claude/skills/`. La repo operativa si aggiorna quando ci si lavora,
   non a vuoto.

> **Perché file committati e non il plugin marketplace.** Nelle sessioni cloud
> di Claude Code il marketplace non carica le skill (verificato; vedi
> [claude-code#23910](https://github.com/anthropics/claude-code/issues/23910)).
> L'unico metodo che le carica davvero è avere i `SKILL.md` committati in
> `.claude/skills/` — ed è quello che fa l'hook.

## Struttura

```
plugins/workspace-skills/skills/<nome>/SKILL.md   # fonte di verità delle skill
scripts/refresh-from-registry.sh   # refresh dal registry skills.sh (cloud/locale)
scripts/sources.txt                # mappa owner/repo delle sorgenti
scripts/add-hook.sh                # onboarda una repo con il SessionStart hook
scripts/sync-skills.sh             # refresh dalla install locale ~/.agents/skills
scripts/inject-skills.sh           # copia one-shot delle skill in un progetto locale
templates/sync-skills-hook.sh      # template canonico dell'hook
templates/bootstrap-prompt.md      # iniezione via sessione cloud, senza clone locale
```

## Operazioni comuni

**Aggiungere / modificare una skill**
1. Edita `plugins/workspace-skills/skills/<nome>/SKILL.md`, commit, push.
2. Se viene da una sorgente skills.sh, aggiungi `owner/repo` a `scripts/sources.txt`
   (così la routine la tiene aggiornata). Altrimenti resta gestita a mano.

**Onboardare una repo (nuova o esistente)**
```bash
bash scripts/add-hook.sh /percorso/della/repo
# poi, dentro quella repo:
git add .claude && git commit -m "Add skills sync hook" && git push
```
Installa l'hook (merge sicuro se esiste già un `settings.json`). Da lì in poi la
repo si auto-allinea a ogni sessione.

**Rinfrescare la fonte di verità dal registry**
```bash
bash scripts/refresh-from-registry.sh   # in cloud lo fa già la routine settimanale
```

**Iniezione one-shot in un progetto locale** (senza hook)
```bash
bash scripts/inject-skills.sh /percorso/progetto [skill...]
```

## Note

- Repo `Bonny94ITA/SkillWorkspace` (pubblico). Se lo rendi privato, hook,
  refresh e bootstrap richiedono accesso in lettura autenticato.
- L'hook clona da `origin`: vede ciò che hai **pushato**, non gli edit locali
  non committati.
