# ARCHITECTURE.md

**How this repo is organized, and why.**

Implements Karpathy's LLM Wiki pattern (immutable sources → agent-maintained wiki → schema), extended with the learning and transmission machinery in `learning-transmission-principles.md`.

---

## The one idea that shapes everything

> **The wiki keeps the *agent's* knowledge current. It does nothing for *yours*.**

This is the gap in the base LLM Wiki pattern. Every ingest makes the wiki richer, and the agent re-reads it from scratch each session at full fidelity. You don't. Your memory of *why* you concluded something decays on a normal human forgetting curve while the wiki sits there looking maintained.

Worse, the two substrates have **opposite learning properties**:

| | Agent | Human |
|---|---|---|
| Retrieval practice | No effect — frozen weights, re-reading is re-reading | Strong effect (*g* ≈ 0.51 vs restudy) |
| Spacing | Meaningless within a session | Strong (*g* ≈ 0.74 spaced vs massed) |
| Difficulty in the text | **Harms** output — context rot | **Helps** retention |
| Practice across a long run | **Degrades** — self-conditioning on own errors | Improves |

So the repo has **two memory systems** that must not be merged:

- `wiki/` — dense, frictionless, findable. Serves the agent and human lookup.
- `review/` — spaced retrieval over the pages whose *rationale* rots. Serves the human only.

Trying to serve both from one artifact produces a wiki that's mildly annoying to query and useless for learning.

---

## Layers

Four tiers, each with different write permissions and versioning discipline.

```
raw/        IMMUTABLE.   No agent writes here, ever. Enforced by tool allowlist,
                         not by instruction.
staging/    DERIVED.     1:1 extraction per source, no cross-page synthesis.
                         Cheap to regenerate. Low review bar.
wiki/       SYNTHESIZED. Agent-owned. Git-tracked. This is where editorial
                         judgment lives, so it never regenerates identically.
schema/     GOVERNING.   CLAUDE.md, CLAUDE.md, skills, agents.
                         Highest scrutiny — every future run reads these.
```

`staging/` is the tier the base pattern omits and it earns its place: it separates *what the source says* (deterministic, re-runnable, low stakes) from *what it means in context* (non-deterministic, carries decisions, expensive to redo). When you improve the synthesis prompt you re-run from staging, not from PDFs.

---

## Layout

```
llm-wiki/
├── CLAUDE.md                    # schema. Always resident. Thin router.
├── BEHAVIORAL_AND_CULTURE.md    # how agents learn and hand off
├── ARCHITECTURE.md              # this file
│
├── raw/                         # LAYER 1 — immutable
│   ├── papers/                  #   the 19 PDFs
│   ├── transcripts/             #   VTT (planned)
│   └── assets/                  #   extracted figures
│
├── staging/                     # LAYER 2 — per-source extraction, regenerable
│   └── <slug>.md                #   claims + locators, no synthesis
│
├── wiki/                        # LAYER 3 — synthesis, agent-owned
│   ├── CLAUDE.md           #   how to write anything here
│   ├── index.md                 #   catalog. Content-oriented. Read first on query.
│   ├── overview.md              #   the map. Global before local.
│   ├── glossary.md              #   canonical names + aliases
│   ├── log.md                   #   append-only, grep-parseable
│   │
│   ├── wiki/                    #   REFERENCE  — one per source, zero friction
│   ├── raw/                     #   source PDFs for Obsidian access (gitignored)
│   ├── concepts/                #   REFERENCE  — cross-source entities/concepts
│   ├── topics/                  #   EXPLANATION — human learning, friction preserved
│   ├── open/                    #   DISCOVERY  — contradictions, gaps, unresolved
│   └── decisions/               #   YOUR calls. What you concluded and why.
│
├── review/                      # LAYER 3.5 — the human's memory system
│   ├── queue.md                 #   spaced-retrieval schedule
│   └── calibration.md           #   predicted vs actual. Your metacognitive record.
│
├── scripts/                     # deterministic checks — the oracle
│   ├── inventory.sh             #   raw/ vs wiki/ drift
│   ├── links.sh                 #   dead links, orphans
│   ├── refs.py                  #   dependency DAG → push-based staleness
│   └── review-due.py            #   what's due today
│
└── .claude/
    ├── skills/                  # loaded on activation
    ├── agents/                  # subagents with restricted tools
    └── commands/                # /ingest /lint /discover /ask /review
```

---

## Why each wiki subdirectory exists

**`wiki/` — reference, per source.** Mirrors one PDF. Zero friction; half the readers are agents doing lookup, and friction breaks them. Never restated elsewhere.

**`concepts/` — reference, cross-source.** The entity and concept pages that make the wiki compound. A concept mentioned in five papers gets one page that five paper notes link to. **This is where the wiki stops being a stack of summaries.**

*New page vs. edit heuristic:* create a page when it's a distinct thing you would link to from elsewhere; edit in place when it's an attribute or update of something that exists. Agents get this right about nine times in ten once the page types are enumerated — and wrong the rest, which is what `lint` catches.

**`topics/` — explanation and tutorial.** Human learning. This is the only place friction belongs: retrieval prompts, attempt-before-reveal, faded scaffolding, declared prior knowledge. Links to `wiki/` and `concepts/`; never restates their numbers.

**`open/` — discovery.** Contradictions and gaps, stated at full strength and left unresolved. A resolved `open/` page should have become a `topics/` page — but keep the file, because the record that the field changed its mind is how you calibrate trust in current certainty.

**`decisions/` — your own conclusions.** The page type the base pattern lacks. When you decide "we're using approach X because Y," that reasoning is *yours*, it exists nowhere in `raw/`, and it is the single most expensive thing to reconstruct once forgotten. These pages feed `review/`.

---

## The four loops

Borrowed from harness engineering, with a fourth that knowledge work needs and code doesn't.

**Inner — the writer checks itself while drafting.** Locators present, frontmatter complete, no claim without a source. Cheap, runs before anything is shown.

**Outer — review at publication.** Two things a self-check structurally cannot do:
1. **Deterministic checks across the whole wiki** — `scripts/`. Dead links, orphans, inventory drift, ref-DAG staleness. These are the oracle.
2. **A fresh-eyes agent that did not write the page and cannot see the writer's reasoning.** Models struggle to self-correct without external feedback and often degrade when they try. A reviewer subagent with read-only tools and no access to the drafting context is a genuine external signal — the only cheap one available.

**Meta — the schema evolves.** A defect caught twice becomes a rule in `CLAUDE.md`. Otherwise you re-teach it every session forever.

**Decay — knowledge goes stale on its own.** Shipped code stays correct until the spec changes. A claim about model capability from 2022 rots while sitting still. This loop has no analogue in software and it is why `lint` runs on a timer rather than on change.

---

## Drift is the failure mode

Every production report of this pattern names the same thing: the agent under-updates cross-references on ingest, and pages silently go stale. Not hallucination. Not bad summaries. **Bookkeeping decay.**

Four stacked defenses, none sufficient alone:

1. **Tool boundaries.** `raw/` is unwritable by the ingest agent — not by instruction but by allowlist. A sloppy turn cannot corrupt the source layer even in principle.
2. **Mandatory index check before creating a page.** Schema-enforced, not agent judgment. This is what stops near-duplicate sprawl.
3. **`refs:` in frontmatter → a computed DAG.** When a source or upstream page changes, you query *which downstream pages depend on it* instead of waiting for a scan to stumble on the drift. Push-based, not poll-based.
4. **Scheduled lint.** Nightly or on merge. Catches what the first three miss — stale prose claims, orphans, missing cross-refs.

---

## Scale expectations

The `index.md`-first retrieval strategy works well to roughly a few hundred pages. At 19 papers you are nowhere near the limit; do not build search infrastructure yet. When `index.md` no longer fits comfortably in context, add hybrid search (SQLite FTS5, or `qmd`) as a **script the agent shells out to**, not as a service.

Deterministic work belongs in scripts, not in LLM calls. Counting files, checking links, and computing what's due for review are classical computation. Spending tokens on them is both expensive and *less reliable* than a five-line shell script.
