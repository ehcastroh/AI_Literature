# BOOTSTRAP.md

**Instructions for Claude Code to build out the LLM Wiki harness.**

Save this at the repo root. Then, in Claude Code:

```
Read BOOTSTRAP.md and execute Phase 0. Stop when Phase 0's checkpoint passes.
```

Run one phase per session. Do not batch.

---

## Read this first

You are building the automation harness for an agent-maintained research wiki. Three layers, per Karpathy's LLM Wiki pattern: immutable sources → agent-maintained wiki → schema that governs the agent.

Three governing documents already exist or will be created in Phase 2. Read them before writing anything in `wiki/`:

- `ARCHITECTURE.md` — the layout and why it is what it is
- `CLAUDE.md` — always-resident router and non-negotiables
- `BEHAVIORAL_AND_CULTURE.md` — how agents learn and hand off
- `wiki/CLAUDE.md` — how to write wiki pages

**Rules for this bootstrap itself:**

1. **One phase per session.** Your per-step error rate rises across a long run through self-conditioning. A seven-phase build in one context produces good scaffolding and broken skills. After each phase's checkpoint, stop and say the next phase needs a fresh session.
2. **Build the oracle before the things that depend on it.** Scripts come before agents. Deterministic verification is the only external error signal available here, so it must exist first.
3. **Deterministic work goes in scripts, not prompts.** Counting files, checking links, computing review schedules — these are classical computation. A shell script is cheaper *and more reliable* than an LLM doing arithmetic.
4. **Ask before inventing.** Where this document is ambiguous, ask rather than guessing. A wrong convention baked into the schema layer costs every future session.
5. **Append to `wiki/log.md` at every phase completion.**

---

## Phase 0 — Environment and inventory

**Goal:** a working dev shell and an honest count.

1. **Fix `flake.nix`.** It currently fails to evaluate — `ripgrep` is missing a character and indentation mixes tabs and spaces. Repair it and confirm `nix develop` succeeds. Required packages: `pandoc`, `ripgrep`, `fd`, `fzf`, `jq`, `lazygit`, `python3`, `poppler_utils` (for `pdftotext`).
2. **Take inventory.** Count `raw/**/*.pdf`. Count `wiki/wiki/*.md`. Report both.
3. **Correct the log.** `wiki/log.md` claims 3 PDFs; reality is 17. Do not edit the historical entry — the log is append-only. Append a correction entry that supersedes it.
4. **Report, do not fix, anything else broken.** List it and stop.

**Checkpoint:** `nix develop` enters a shell where `rg`, `fd`, `jq`, `pdftotext`, and `python3` all resolve. Inventory reported. Log corrected by appending.

---

## Phase 1 — Directory scaffold and the deterministic oracle

**Goal:** structure plus the four scripts that verify everything built later.

### 1a. Directories

Create, each with a `.gitkeep`:

```
raw/papers/  raw/transcripts/  raw/assets/
staging/
wiki/wiki/  wiki/concepts/  wiki/topics/  wiki/open/  wiki/decisions/
review/
scripts/
.claude/skills/  .claude/agents/  .claude/commands/
```

Move the existing 19 PDFs into `raw/papers/`.

### 1b. Scripts

Write these four. Keep them dependency-free (POSIX shell and Python stdlib only). Each must exit non-zero on failure so agents can use exit codes as a signal.

**`scripts/inventory.sh`**
Counts sources in `raw/papers/` and notes in `wiki/wiki/`. Lists un-ingested sources by name. Prints `INGESTED: n/m`. Exits 1 if `wiki/log.md`'s most recent inventory line disagrees with the true count — this is the drift detector, and drift is the primary failure mode of this pattern.

**`scripts/links.sh`**
Extracts every `[[wikilink]]` across `wiki/`. Reports: dead links (target file absent), orphans (page with zero inbound links, excluding `index.md`, `overview.md`, `log.md`, `glossary.md`), and empty pages (frontmatter only). Exits 1 if any dead links found.

**`scripts/refs.py`**
Parses YAML frontmatter across `wiki/` and builds a dependency DAG from the `refs:` field. Given a changed file, reports every downstream page that depends on it — transitively. This makes staleness detection push-based instead of waiting for a scan to stumble onto it. Also flags cycles.

**`scripts/review-due.py`**
Reads `review/queue.md`, returns items due today on a spaced schedule of **1, 3, 7, 16, 35, 60 days**. On a correct recall, advance to the next interval; on a miss, reset to day 1. Output as markdown suitable for pasting into a session.

Write each script's usage into `scripts/README.md`.

**Checkpoint:** all four scripts run clean on the current (nearly empty) wiki and return sensible output. `inventory.sh` correctly reports 0/19 ingested.

---

## Phase 2 — Schema layer

**Goal:** the governing documents in place.

Install `CLAUDE.md`, `BEHAVIORAL_AND_CULTURE.md`, `ARCHITECTURE.md`, and `wiki/CLAUDE.md` (provided separately — do not rewrite them from scratch; adapt paths if the layout shifted in Phase 1).

Then create the four wiki spine files, empty but structurally valid:

- **`wiki/index.md`** — table with columns: Page · Type · One-line summary · Sources · Updated. This is read first on every query, so keep it dense and current.
- **`wiki/overview.md`** — the map of the field at low resolution. Empty scaffold with a note that it gets written after ~5 ingests, not before. Global before local, but you cannot map a field you have not read.
- **`wiki/glossary.md`** — table: Canonical name · Aliases · One-line definition · Defined in. Canonical name is the primary key; a paper's private coinage is always an alias, never the entry.
- **`wiki/log.md`** — append-only. Every entry starts `## [YYYY-MM-DD] <op> | <subject>` so `grep "^## \[" wiki/log.md | tail -5` works.

**Checkpoint:** all documents present. `rg "^## \[" wiki/log.md` returns the Phase 0 correction entry.

---

## Phase 3 — Subagents

**Goal:** role separation enforced by tool allowlists, not by instruction.

This is the load-bearing phase. The layer contract must be **physically unviolable**: a sloppy turn should be unable to corrupt `raw/` even in principle. Instructions get forgotten as context fills; allowlists do not.

Create in `.claude/agents/`:

### `ingestor.md`
Reads one source, writes staging and wiki pages.
- **Tools:** Read, Write, Edit, Glob, Grep, Bash (restricted to `scripts/`)
- **Denied:** any write path under `raw/`, any write to `.claude/` or `CLAUDE.md`
- Handles one source per invocation. Refuses batches.

### `reviewer.md`
**The oracle.** Fresh eyes on a drafted page.
- **Tools:** Read, Glob, Grep — **read-only, no Write, no Edit, no Bash**
- Receives the *drafted page and the source*, and explicitly **not** the drafting conversation. It must not be able to see the writer's reasoning; that is the entire point. A reviewer that inherits the author's context is the author, and self-review does not work.
- Returns a structured verdict: claims lacking locators, claims not supported by the source, missing boundary conditions, frontmatter defects, mode violations (friction in `papers/`, terseness in `topics/`).

### `linter.md`
Whole-wiki health.
- **Tools:** Read, Glob, Grep, Bash (`scripts/`), Edit
- **Edit is permitted only for mechanical breakage** — dead links, malformed frontmatter, orphan tags. **Never content claims.** Anything content-level becomes a report for human review, not an edit.

### `discoverer.md`
Cross-corpus pattern hunting.
- **Tools:** Read, Glob, Grep, WebSearch, Write (restricted to `wiki/open/`)
- WebSearch exists solely so it can distinguish "absent from this corpus" from "absent from the field." Without it, every finding caps at `GAP-IN-CORPUS`.

**Checkpoint:** each agent definition states its allowlist explicitly. Verify `ingestor` genuinely cannot write to `raw/` — attempt it and confirm refusal.

---

## Phase 4 — Skills

**Goal:** the workflows, loaded on activation rather than resident.

Create in `.claude/skills/<name>/SKILL.md`, each with YAML frontmatter (`name`, `description` — the description is how the skill gets discovered, so state both what it does *and when to use it*).

Two skills are provided separately and should be installed as-is: **`ingest`** and **`discover`**. Write the remaining three.

### `wiki-lint`
Runs the decay loop. Order matters — mechanical fixes first, so content review isn't polluted by noise:
1. `scripts/inventory.sh` — drift between `raw/` and `wiki/`
2. `scripts/links.sh` — dead links, orphans, empty pages
3. `scripts/refs.py` — downstream staleness from changed sources
4. Content pass (`linter` agent): contradictions between pages, claims superseded by newer sources, concepts mentioned repeatedly but lacking a page, missing cross-references
5. Emit a report; **mechanical fixes applied automatically, content findings held for review**

Also: flag any page whose `expires_when` condition now appears met, and any claim older than 18 months about model capability — this corpus spans 2022–2026 and capability claims decay in months.

### `wiki-query`
Answering from the wiki.
1. Read `wiki/index.md` first — always. It is the retrieval layer at this scale.
2. Follow rows to relevant pages; read those, not the whole wiki.
3. Answer with `[[wikilinks]]` as citations. Every claim traces to a page, every page to a source.
4. **If the answer required synthesis that isn't yet in the wiki, offer to file it** — as a `topics/` page if it's an explanation, `open/` if it surfaced a tension, `decisions/` if the user concluded something.

Note the live disagreement here: Karpathy holds that good answers should be filed back so exploration compounds; some implementers argue derived pages add scan cost without new information. **Default to offering, never to auto-filing.** File only what the user accepts.

### `wiki-review`
The human's memory system. This is the skill with no analogue in other implementations of this pattern, and the reason the repo has a `review/` directory.
1. `scripts/review-due.py` for today's items
2. Draw **only** from `wiki/decisions/` and `wiki/topics/` — the pages whose *rationale* decays. Never from `papers/`; reference material is for lookup, not recall.
3. Ask for **free recall before revealing** — retrieval, not recognition. Recognition feels like knowing and is not.
4. Ask the user to **predict their own accuracy before answering.** Log predicted vs actual to `review/calibration.md`. Learners are systematically overconfident about fluent material; this is the only measurement that catches it.
5. Grade, update the interval, append to `review/queue.md`.

**Checkpoint:** each skill's description would trigger correctly on a plausible user phrasing. Run `wiki-lint` end to end on the empty wiki without errors.

---

## Phase 5 — Commands

Thin wrappers in `.claude/commands/`. Each delegates to a skill and does no work itself.

| Command | Delegates to | Notes |
|---|---|---|
| `/ingest <file>` | `ingest-paper` via `ingestor` | Refuses more than one file |
| `/lint` | `wiki-lint` via `linter` | Safe to run any time |
| `/discover [pattern]` | `wiki-discovery` via `discoverer` | Defaults to asking which of the six patterns |
| `/ask <question>` | `wiki-query` | Index-first |
| `/review` | `wiki-review` | Human-facing; the only interactive one |

**Checkpoint:** each command resolves and dispatches to the right agent with the right allowlist.

---

## Phase 6 — End-to-end proof on one paper

**Goal:** demonstrate the whole loop before touching the other eighteen.

1. Pick the single most foundational paper in `raw/papers/`. State why.
2. `/ingest` it. Follow `ingest-paper` exactly — including reading method and limitations rather than the abstract.
3. Invoke `reviewer` on the result **in a context that has not seen the drafting**. Report its verdict verbatim.
4. Fix whatever review found.
5. `/lint`. Confirm clean.
6. **The real test:** start a fresh session with no memory of this work. Give it only `wiki/index.md`. Ask it to state the paper's central claim, its boundary conditions, and what observation would show it wrong. **What that session gets wrong is what the note omitted** — and it will most often be decision knowledge, because that is what fluency hides.
7. Fix the gaps. Record what the fresh session missed in `wiki/log.md` — this is the highest-value output of the whole bootstrap, because it tells you what your ingest process systematically drops.

**Checkpoint:** a stranger session succeeds from artifacts alone, with no hints.

---

## Phase 7 — Meta loop

**Goal:** make the harness self-improving.

1. Review Phase 6's findings. **Any defect that appeared twice becomes a rule** in `wiki/CLAUDE.md` or the relevant SKILL.md. Otherwise you re-teach it every session forever.
2. Add a `## Merge log` section to `CLAUDE.md` recording what changed and why, with confidence markers.
3. Optionally add a git hook: run `scripts/links.sh` and `scripts/inventory.sh` pre-commit; block on dead links, warn on drift.
4. Write `to-do.md` fresh, carrying forward the VTT transcript support item.

**Checkpoint:** at least one rule in the schema layer traces to an observed defect rather than to this document.

---

## After the bootstrap

Ingest the remaining eighteen papers **one per session**. After roughly five, `wiki/overview.md` becomes writable — you will have enough of the field to map it. After roughly eight, `/discover` becomes worth running; below that you are pattern-matching on noise.

Run `/lint` weekly regardless of activity. Knowledge decays while sitting still, which is why it goes on a timer rather than on change.

Run `/review` whenever `scripts/review-due.py` returns anything. That is the half of the system that spends your time instead of saving it, and it is the only part that makes *you* — rather than the wiki — smarter.
