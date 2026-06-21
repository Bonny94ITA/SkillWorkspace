# SkillWorkspace

Repo "guscio": catalogo personale di skill riusabili, distribuito come **plugin
marketplace** di Claude Code. Non contiene codice di progetto: contiene skill e
contesto che i progetti reali abilitano e si portano dietro automaticamente.

## Architettura (perche' questo repo esiste)

Una sessione web/cloud di Claude Code e' legata a **una sola repo** — il progetto
reale. L'unica cosa che si auto-carica all'avvio e' cio' che e' committato in
quella repo (`CLAUDE.md` e `.claude/`). Quindi, per avere le skill sempre presenti
su progetti diversi, ogni progetto **referenzia** questo marketplace tramite un
piccolo `.claude/settings.json` committato. Le skill restano qui, in un solo posto.

## Struttura

```
.claude-plugin/marketplace.json     # catalogo del marketplace ("skillworkspace")
plugins/workspace-skills/           # il plugin con le skill condivise
  .claude-plugin/plugin.json
  skills/<nome>/SKILL.md            # una cartella per skill
templates/project-settings.json     # snippet da incollare in ogni progetto
templates/bootstrap-prompt.md       # ripiego manuale (Metodo B)
```

## Aggiungere una skill

1. `plugins/workspace-skills/skills/<nome>/SKILL.md` con frontmatter `name` + `description`.
2. Commit + push.
3. Nei progetti: `/plugin marketplace update` (o nuova sessione) per ricevere l'aggiornamento.

## Usarlo in un progetto reale

Copia `templates/project-settings.json` dentro `.claude/settings.json` del progetto,
committa, e ogni sessione futura su quel progetto carica le skill da qui.
Dettagli e alternativa manuale: vedi `README.md`.
