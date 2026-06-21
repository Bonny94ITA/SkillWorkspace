# SkillWorkspace

Catalogo personale di **skill riusabili** per Claude Code: una sola fonte di
verità (`plugins/workspace-skills/skills/`) che propaghi nei progetti reali
con file committati, perché funzioni anche nelle sessioni cloud isolate.

## Il problema che risolve

Una sessione Claude Code on the web e' una sandbox isolata per **un solo
repository** (il progetto reale, che cambia spesso). All'avvio carica solo
cio' che e' committato in quella repo. Non eredita il tuo `~/.claude` o
`~/.agents/skills` locali.

## Perche' NON il plugin marketplace (testato, non funziona)

Sembrerebbe il meccanismo nativo giusto, e infatti e' stato il primo tentativo
di questo repo — ma **non funziona per le sessioni cloud di Claude Code**,
verificato empiricamente su piu' fronti:

- `extraKnownMarketplaces` + `enabledPlugins` in `.claude/settings.json` → non si
  auto-installa (nessun trust prompt nel cloud headless).
- Hook `SessionStart` che lancia `claude plugin marketplace add` + `install` →
  il marketplace si registra e il plugin si installa in cache, ma le skill non
  vengono **caricate** nella sessione (confermato anche da un bug noto upstream:
  [anthropics/claude-code#23910](https://github.com/anthropics/claude-code/issues/23910),
  validazione che esclude i marketplace custom da `getPluginSkills()`).
- Account Settings → Plugins/Skills (UI di claude.ai) → distribuisce a **Chat**
  e **Cowork**, non a Claude Code: per design non raggiunge le sessioni di
  coding. Vedi la [doc ufficiale](https://support.claude.com/en/articles/13837433-manage-plugins-for-your-organization).

Quindi niente submodule (Metodo A, fragile per-progetto) e niente marketplace
(DRY ma non funziona nel cloud). L'unico metodo verificato che carica le skill
in una sessione cloud e' committare i file `SKILL.md` **dentro il repo**, in
`.claude/skills/`.

## Come usarlo

### Lavori da questo Mac, progetto gia' clonato in locale

```bash
bash scripts/inject-skills.sh /percorso/progetto              # tutte le skill curate
bash scripts/inject-skills.sh /percorso/progetto seo accessibility   # solo alcune
```

Copia i file in `<progetto>/.claude/skills/`. Poi nel progetto:

```bash
git add .claude/skills && git commit -m "Add shared skills" && git push
```

### Sessione cloud su un progetto che non hai in locale

Incolla come primo prompt il contenuto di
[`templates/bootstrap-prompt.md`](templates/bootstrap-prompt.md): fa fare a
Claude, dentro la sandbox, un clone sparse + copia + commit, senza toccare
questo Mac.

## Aggiungere / modificare skill

1. Crea `plugins/workspace-skills/skills/<nome>/SKILL.md` (frontmatter `name` + `description`).
2. `git commit` + `git push`.
3. Ripropaga ai progetti che la usano con `scripts/inject-skills.sh` (o il bootstrap cloud).

### Sync dalle skill installate in locale

Le skill sotto `plugins/workspace-skills/skills/` sono uno **snapshot** copiato
dalla install locale `~/.agents/skills` (skills.sh). Per rinfrescarle:

```bash
bash scripts/sync-skills.sh
git add -A && git commit -m "Sync skills" && git push
```

Poi ripropaga ai progetti con `scripts/inject-skills.sh`. Lo script ricopia
solo il set curato elencato al suo interno (`SKILLS=(...)`): modifica quella
lista per aggiungere/togliere skill. Lo snapshot **non** si aggiorna da solo
quando skills.sh cambia l'originale — devi rilanciare il sync.

## Nota sulla "freschezza"

Non c'e' propagazione automatica: ogni progetto ha una **copia** fissata al
momento dell'iniezione. Quando aggiorni una skill qui, i progetti che la usano
restano alla versione vecchia finche' non rilanci `inject-skills.sh` (o il
bootstrap) su ciascuno. E' il costo del metodo che funziona davvero nel cloud.

## Note

- Repo: `Bonny94ITA/SkillWorkspace` (pubblico). Se lo rendi privato, sia
  l'iniezione locale (serve `gh auth`/credenziali git) sia il bootstrap cloud
  (serve rete autenticata) richiedono accesso in lettura.
