# CLAUDE.md

Agent-maintained knowledge base for AI/ML research papers. PDFs land in `raw/`, agents ingest them, the wiki accretes.

**This file is always resident. It stays thin on purpose** — every token here is spent from a budget that degrades before it fills. It tells you *where things go*. It does not repeat the reasoning; that lives in the files it points to.

**Before your first write in this repo, read `BEHAVIORAL_AND_CULTURE.md`.** It governs how you learn and what you leave behind. This file governs only this repo's mechanics.

---

## Three purposes, three directories

This wiki serves reference lookup, human learning, and discovery. **Those three want opposite things from a page** — reference wants zero friction, learning wants preserved difficulty, discovery wants unresolved tension left visible. They do not share files.

| Directory | Mode | Optimized for | Friction |
|---|---|---|---|
| `wiki/wiki/` | Reference | Paper notes - lookup by human or agent | **None.** Dense, flat, scannable. |
| `wiki/topics/` | Explanation + Tutorial | A human learning the field | **Preserved.** Retrieval prompts, attempt-before-reveal. |
| `wiki/open/` | Discovery | Generating the next question | **Deliberate.** Tensions stay unresolved. |

Writing a learning exercise into `wiki/` breaks agent retrieval. Writing a terse reference into `topics/` produces a pleasant page nobody learns from. Check which directory you are in before choosing a register.

---

## Repo map

```
raw/                    PDFs. READ-ONLY for existing files. New PDFs from /scout land here.
wiki/
  index.md              Routing table. Every artifact gets exactly one row.
  overview.md           The map of the field at low resolution. Global before local.
  glossary.md           Canonical names. The defense against private vocabulary.
  log.md                Append-only ledger. Provenance and inventory.
  wiki/                 One file per ingested paper. Reference mode.
  raw/                  Source PDFs for Obsidian access. Gitignored.
  topics/               Cross-paper synthesis. Explanation mode. (create as needed)
  open/                 Contradictions, gaps, stale claims. Discovery mode. (create as needed)
flake.nix               Nix dev shell: pandoc, ripgrep, fd, fzf, jq, lazygit.
to-do.md                Planned: auto-inventory on ingest; VTT transcript support.
```

---

## Routing

Load only what the task needs.

| If you are… | Load |
|---|---|
| Ingesting a PDF from `raw/` | `.claude/skills/ingest.md` |
| Writing or editing any wiki prose | `wiki/CLAUDE.md` |
| Looking for gaps, contradictions, or questions inside the corpus | `.claude/skills/discover.md` |
| Finding new papers via ArXiv author lineage (external, forward-looking) | `.claude/skills/scout.md` |
| Adding new terms to Dictionary_AI from ingested papers | `.claude/skills/update-glossary.md` |
| Unsure how to learn or hand off in a new domain | `BEHAVIORAL_AND_CULTURE.md` |
| Answering a question from the wiki | Nothing. Read `wiki/index.md`, follow the row. |

---

## Non-negotiables

**N1. `raw/` is read-only.** The PDFs are the ground truth and the only oracle this repo has. Never modify one.

**N2. No claim without a locator.** Every factual statement in `wiki/` traces to a source and a position in it — section, figure, or table. A claim you cannot locate is a claim you delete.

**N3. Never write a paper note from the abstract.** Abstracts systematically overstate. If you have not read the method and the limitations, you have not ingested the paper. Mark it `UNVERIFIED` and stop.

**N4. One paper per session.** Do not batch. Your per-step error rate rises as a run continues, so paper 1 gets a good note and paper 12 gets a confabulated one. Fresh context per paper, every time.

**N5. Contradictions open a file; they never overwrite.** If a new paper conflicts with an existing wiki claim, write `wiki/open/<question>.md`. Silently replacing the older claim destroys the disagreement, which is the most valuable thing in the corpus.

**N6. Date everything, and mark what would falsify it.** This corpus spans 2022–2026 in a field where capability claims decay in months. A 2022 claim about what models can do is a historical artifact, not a current fact. Undated claims propagate as though current.

**N7. The log is append-only.** Correct a past entry by adding a new one that supersedes it. Never edit history — the record of what you believed and when is the repo's error-correction machinery.

---

## The log protocol

`wiki/log.md` is the provenance ledger. Append on every ingest, synthesis, or correction. Never edit prior entries.

```markdown
## 2026-07-25 — ingest: shinn-2023-reflexion
- Source: raw/papers/2303.11366.pdf
- Read: full (method §3, results §4, limitations §5)
- Wrote: wiki/wiki/reflexion-verbal-reinforcement-learning.md
- Index: row added
- Glossary: +verbal reinforcement learning, +episodic memory buffer
- Contradictions: conflicts with huang-2024-self-correct → opened wiki/open/does-self-reflection-work.md
- Confidence: VERIFIED
- Inventory after: 4/17 ingested
```

**Inventory drift is a known failure here.** Recount `raw/` on every append and write the true ratio. A ledger that silently disagrees with the filesystem is worse than no ledger.

---

## Definition of done

An ingest is finished when a **fresh agent with no memory of your session**, given only `wiki/index.md`, can find the paper, state its central claim, name its boundary conditions, and say what would show it wrong.

Not when the file exists. Not when it reads well.
