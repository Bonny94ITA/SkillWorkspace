# Bootstrap di ripiego (Metodo B)

Da usare SOLO sui progetti dove non vuoi/puoi committare `.claude/settings.json`.
Incolla questo come **primo prompt** della sessione web. NON persiste: va rifatto
ogni sessione. La via consigliata e' invece il `.claude/settings.json` committato
(vedi `README.md`).

---

Aggiungi il mio marketplace di skill personale e abilita il plugin, poi conferma
quali skill sono disponibili:

/plugin marketplace add Bonny94ITA/SkillWorkspace
/plugin install workspace-skills@skillworkspace

---

Note:
- Sostituisci `Bonny94ITA/SkillWorkspace` se il repo e' su un altro account/nome.
- Se il repo e' privato, la sessione deve avere accesso in lettura (auth git/gh).
