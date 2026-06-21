# Bootstrap per nuovo progetto (sessione cloud, anche senza clone locale)

Da incollare come **primo prompt** in una sessione Claude Code on the web aperta
su un progetto qualsiasi. Non richiede che il progetto esista in locale su
questo Mac: Claude lo fa direttamente dentro la sandbox cloud.

Copia/incolla questo blocco (sostituisci la lista skill se vuoi solo un
sottoinsieme — i nomi sono le cartelle in `plugins/workspace-skills/skills/`
di https://github.com/Bonny94ITA/SkillWorkspace):

---

Importa le skill condivise dal mio repo di skill in questo progetto:

1. Clona con sparse-checkout solo le skill, in una cartella temporanea:
   ```
   git clone --depth 1 --filter=blob:none --sparse https://github.com/Bonny94ITA/SkillWorkspace.git /tmp/skillworkspace
   cd /tmp/skillworkspace && git sparse-checkout set plugins/workspace-skills/skills
   ```
2. Copia tutte le cartelle skill dentro `/tmp/skillworkspace/plugins/workspace-skills/skills/`
   in `.claude/skills/` di questo progetto (crea la cartella se non esiste).
   Sovrascrivi eventuali skill omonime, non toccare altre skill custom gia' presenti.
3. Rimuovi `/tmp/skillworkspace`.
4. Fai commit di `.claude/skills/` con un messaggio chiaro e procedi secondo il
   tuo workflow normale (branch + PR, o commit diretto se hai i permessi).

---

## Perche' questo metodo (e non il plugin marketplace)

Le sessioni Claude Code on the web sono sandbox isolate per singolo repo: non
auto-installano marketplace di plugin esterni (testato: `extraKnownMarketplaces`,
hook `SessionStart` con `claude plugin install`, e la pagina account
Settings -> Plugins falliscono tutti nel caricare le skill nella sandbox — la
pagina Plugins serve solo Chat/Cowork, non Claude Code). L'unico metodo che
carica davvero le skill in una sessione cloud e' avere i file `SKILL.md` **dentro
il repo** in `.claude/skills/`. Vedi `README.md` per i dettagli.

## Variante: solo alcune skill

Nel punto 2, copia solo le cartelle che ti servono, ad esempio solo
`seo`, `accessibility`, `core-web-vitals` per un progetto web.
