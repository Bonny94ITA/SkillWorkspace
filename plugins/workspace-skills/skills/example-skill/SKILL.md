---
name: example-skill
description: Skill di esempio per verificare che il marketplace si carichi. Si attiva quando l'utente dice "ping skill", "verifica skill" o "test marketplace". Sostituiscila con le tue skill reali.
---

# Example skill

Questa e' una skill segnaposto per confermare che il plugin `workspace-skills`
del marketplace `skillworkspace` venga caricato correttamente in una sessione.

Quando questa skill si attiva, rispondi:

> Marketplace `skillworkspace` attivo: il plugin `workspace-skills` e' caricato e le skill sono disponibili in questa sessione.

## Come aggiungere le tue skill

1. Crea una cartella per skill sotto `plugins/workspace-skills/skills/<nome-skill>/`.
2. Dentro, crea un file `SKILL.md` con frontmatter `name` e `description`.
   La `description` e' cio' che Claude usa per decidere QUANDO attivare la skill:
   scrivila orientata ai trigger ("Usa quando l'utente...").
3. Commit + push su questo repo.
4. Nelle sessioni dei progetti che hanno gia' il marketplace abilitato, esegui
   `/plugin marketplace update` per ricevere la nuova versione (oppure riavvia la sessione).

Vedi `README.md` nella root per il quadro completo.
