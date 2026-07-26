# LLM Wiki

An agent-maintained research knowledge base for AI/ML papers — built on [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), extended with the learning-science machinery the original pattern leaves out.

Drop a PDF in `raw/`. An agent reads it, files it, cross-references it, flags what it contradicts, and logs what it did. The wiki compounds. You never write it.

**Status:** working. 17 sources, ingesting. Expect rough edges.

---

## Why another one of these

There are a couple of dozen LLM Wiki implementations now. Most differ in retrieval strategy — vector DB vs. graph vs. grep. This one differs in a way that has nothing to do with retrieval.

**Every implementation I've seen optimizes the agent's memory. None optimize yours.**

That's a real gap, and it isn't cosmetic. The wiki gets richer with every ingest, and the agent re-reads it at full fidelity every session. You don't. Your memory of *why* you concluded something decays on an ordinary forgetting curve while the repo sits there looking beautifully maintained.

So this repo runs two memory systems that deliberately never merge:

| | Agent (`wiki/`) | Human (`review/`) |
|---|---|---|
| Retrieval practice | no effect (frozen weights) | *g* ≈ 0.51 vs restudy |
| Spacing | meaningless in-session | *g* ≈ 0.74 spaced vs massed |
| Difficulty in the text | **degrades** output | **improves** retention |
| Practice across a long run | **degrades** (self-conditioning) | improves |

Four properties, four opposite signs. They cannot share a file, so they don't.

The second differentiator: every design decision here traces to a citation, and the reasoning is auditable. `learning-transmission-principles.md` carries the effect-size table, the boundary conditions, and a merge log recording what was **rejected** and why. If you think a decision is wrong, the evidence it rests on is right there to argue with.

---

## Core idea in one diagram

```
raw/          immutable sources. No agent writes here — enforced by tool
              allowlist, not by instruction.
   │ ingest
   ▼
staging/      per-source extraction. 1:1 with raw. Cheap to regenerate.
   │ synthesize
   ▼
wiki/         the compounding artifact. Agent-owned, git-tracked.
   │
   ├──────────────────────────────┐
   │                              │
   ▼                              ▼
lookup (agent + human)      review/ (human only)
zero friction               spaced retrieval, friction required
```

---

## Quickstart

**Prerequisites:** Nix (flakes enabled), Claude Code or another agent harness that reads `CLAUDE.md` / `AGENTS.md`.

```bash
git clone <your-repo> llm-wiki && cd llm-wiki
nix develop              # pandoc, ripgrep, fd, fzf, jq, lazygit, python3, poppler
./scripts/inventory.sh   # should report 0/N ingested on a fresh clone
```

Then, in your agent:

```
Read BOOTSTRAP.md and execute Phase 0. Stop when Phase 0's checkpoint passes.
```

Run **one phase per session**. This is not politeness — per-step error rate rises across a long agent run, so a seven-phase build in one context gives you good scaffolding and broken skills.

---

## Daily use

| Command | What it does |
|---|---|
| `/ingest <file>` | Read one source, file it, cross-reference it, log it. Refuses batches. |
| `/ask <question>` | Answer from the wiki. Index-first. Cites by `[[wikilink]]`. |
| `/lint` | Health check: drift, dead links, orphans, stale claims, contradictions. |
| `/discover [pattern]` | Hunt for what the corpus knows that no single paper says. |
| `/review` | Spaced retrieval. The half that costs you time instead of saving it. |

Run `/lint` weekly regardless of activity. Knowledge decays while sitting still — that's why it's on a timer rather than on change.

`/discover` is worth running after ~8 ingests. Below that you're pattern-matching on noise.

---

## Layout

```
CLAUDE.md                     always-resident router + non-negotiables
BEHAVIORAL_AND_CULTURE.md     how agents learn and hand off
ARCHITECTURE.md               the layout and why it is what it is
BOOTSTRAP.md                  phased build instructions for the agent
learning-transmission-principles.md   the evidence base, with merge log

raw/          papers/ transcripts/ assets/     immutable
staging/                                        regenerable extraction
wiki/
  index.md      catalog — read first on every query
  overview.md   the map of the field, low resolution
  glossary.md   canonical names + aliases
  log.md        append-only, grep-parseable
  papers/       REFERENCE   one per source, zero friction
  concepts/     REFERENCE   cross-source entities and concepts
  topics/       EXPLANATION human learning, friction preserved
  open/         DISCOVERY   contradictions and gaps, left unresolved
  decisions/    YOUR calls — what you concluded and why
review/         queue.md, calibration.md
scripts/        deterministic checks — the oracle
.claude/        skills/ agents/ commands/
```

Full rationale in [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## Design decisions you might disagree with

Stated up front so you can reject them deliberately rather than discovering them by surprise.

**One paper per session, enforced.** `/ingest` refuses batches. Per-step error rate rises through self-conditioning, so batching gives you a careful note for paper 1 and a confabulated one for paper 12 — with no way to tell which is which afterward. This is the most-questioned decision here and the one I'm most confident about.

**Contradictions open a file; they never overwrite.** When a new paper conflicts with an existing claim, the naive move is updating the old page. That deletes the disagreement, which is the highest-value signal in the corpus. Instead: a page in `wiki/open/`, both positions at full strength, plus `supersedes` / `superseded_by` edges.

**Agents cannot write to `raw/`.** Not by instruction — by tool allowlist. Instructions get forgotten as context fills; allowlists don't.

**The reviewer subagent has no write tools and never sees the drafting conversation.** Models struggle to self-correct without external feedback and often degrade when they try. A reviewer that inherits the author's context *is* the author.

**Deterministic work lives in `scripts/`, not in prompts.** Counting files and checking links is classical computation. A shell script is cheaper *and more reliable* than an LLM doing arithmetic — and it's the only external error signal in the system.

**No vector database.** At a few hundred pages, `index.md` is sufficient and inspectable. A missed lookup is a bad line in a file you can open and fix. Add hybrid search (SQLite FTS5, or [`qmd`](https://github.com/tobi/qmd)) as a script the agent shells out to *when index-first retrieval visibly fails* — not before.

---

## Replicating this from zero

For your own corpus, in any domain.

**1. Decide what your `raw/` is.** Papers, transcripts, clipped articles, meeting notes. The only requirement is that it's immutable and you didn't write it.

**2. Take the four schema files.** `CLAUDE.md`, `BEHAVIORAL_AND_CULTURE.md`, `ARCHITECTURE.md`, `wiki/CONVENTIONS.md`. `BEHAVIORAL_AND_CULTURE.md` is domain-independent — take it as-is. The other three need domain edits, mostly in the non-negotiables and the page-type definitions.

**3. Adjust the page types to your domain.** This is the highest-leverage change and the one most people skip. `papers/` and `concepts/` are right for a literature corpus. For a book, you'd want `characters/` and `themes/`. For an internal team wiki, `systems/` and `incidents/`. The agent's new-page-vs-edit judgment is right about nine times in ten *once the page types are enumerated*, and much worse when they aren't.

**4. Keep `decisions/` and `review/` whatever your domain is.** They're the parts that don't depend on subject matter — and the parts that make the system serve you rather than just the wiki.

**5. Run `BOOTSTRAP.md` one phase per session.** Phase 6 is the real test: ingest one source, then start a fresh session with only `wiki/index.md` and ask it to state the central claim, the boundary conditions, and what would falsify it. Whatever that session gets wrong is what your ingest process systematically drops. It will be decision knowledge, because that's what fluency hides.

**6. Let the schema co-evolve.** A defect caught twice becomes a rule in `CONVENTIONS.md`. Otherwise you re-teach it every session forever.

**Expected effort:** the bootstrap is roughly 6–8 focused sessions. First useful answers after ~5 ingests. `overview.md` becomes writable around then too — you can't map a field you haven't read.

---

## Known limitations

- **Index-first retrieval breaks somewhere in the low thousands of pages**, when `index.md` no longer fits comfortably in context. Not close to that yet.
- **`/discover` overclaims by default.** It self-classifies findings as `GAP-IN-WIKI` / `GAP-IN-CORPUS` / `GAP-IN-FIELD`, and the last requires an actual external search. Treat unclassified findings as unverified.
- **The agent-side research this rests on ages in months.** Part II of the principles document is drawn substantially from 2023–2026 preprints about systems that may not exist in their current form soon. Part I ages in decades; Part II does not. Re-verify before trusting.
- **Untested above ~20 sources.** Everything about scale here is inference, not measurement.

---

## Credits

Built on [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) and shaped substantially by the people building in that thread. Full attribution — including which specific ideas came from whom — in [`CREDITS.md`](CREDITS.md).

---

## License

MIT for the tooling and schema files. The `raw/` corpus is third-party copyrighted material and is **not** distributed with this repo — bring your own sources.
