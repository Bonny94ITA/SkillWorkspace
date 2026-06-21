# SkillWorkspace

Catalogo personale di **skill riusabili** per Claude Code, distribuito come
[plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).

## Il problema che risolve

Una sessione web/cloud di Claude Code e' legata a **una sola repository** (il
progetto reale, che cambia spesso). All'avvio si auto-carica solo cio' che e'
committato in quella repo: `CLAUDE.md` e la cartella `.claude/`. Non esiste un
interruttore "inietta queste skill in ogni sessione": le sessioni cloud sono
sandbox per-repo e non ereditano il tuo `~/.claude` locale.

Soluzione: tenere le skill **una volta sola** qui, e far sì che ogni progetto le
**referenzi** con poche righe in `.claude/settings.json`. Aggiorni in un posto,
tutti i progetti ricevono l'ultima versione.

## Come usarlo (consigliato, automatico e persistente)

In ogni repo di progetto reale, crea/aggiorna `.claude/settings.json` con il
contenuto di [`templates/project-settings.json`](templates/project-settings.json):

```json
{
  "extraKnownMarketplaces": {
    "skillworkspace": {
      "source": { "source": "github", "repo": "Bonny94ITA/SkillWorkspace" }
    }
  },
  "enabledPlugins": {
    "workspace-skills@skillworkspace": true
  }
}
```

Committa nel progetto. Da quel momento **ogni** sessione futura su quella repo
carica automaticamente le skill di questo marketplace. Costo: toccare ogni repo
progetto una volta — molto piu' leggero di un git submodule, e a differenza del
clone-via-prompt **persiste**.

> Se il progetto ha gia' un `.claude/settings.json`, aggiungi solo le chiavi
> `extraKnownMarketplaces` e `enabledPlugins` (non sovrascrivere il file intero).

## Ripiego manuale (Metodo B)

Sui progetti dove non vuoi committare nulla, incolla come primo prompt il
contenuto di [`templates/bootstrap-prompt.md`](templates/bootstrap-prompt.md):

```
/plugin marketplace add Bonny94ITA/SkillWorkspace
/plugin install workspace-skills@skillworkspace
```

Funziona ma e' **manuale a ogni sessione** e non persiste. Usalo solo come ripiego.

## Perche' NON git submodule (Metodo A) ne' clone-via-prompt

- **Submodule per ogni progetto** → da aggiungere a ogni repo, fragile, ingestibile su molti progetti.
- **Clone via prompt** → manuale ogni sessione, non persiste: l'opposto di "all'avvio ho gia' tutto".

Il marketplace + `settings.json` ottiene l'auto-load persistente con un puntatore
di 6 righe per progetto e una sola fonte di verita' per le skill.

## Aggiungere / modificare skill

1. Crea `plugins/workspace-skills/skills/<nome>/SKILL.md` (frontmatter `name` + `description`).
2. `git commit` + `git push`.
3. Nei progetti: `/plugin marketplace update` (o avvia una nuova sessione).

## Validare

```bash
claude plugin validate .
```

## Note

- `repo: "Bonny94ITA/SkillWorkspace"` presuppone username GitHub `Bonny94ITA`: cambialo se diverso.
- Se rendi il repo **privato**, le sessioni devono avere accesso in lettura
  (credenziali git / `gh auth` / `GITHUB_TOKEN`).
