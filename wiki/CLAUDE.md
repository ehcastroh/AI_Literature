# CLAUDE.md

Agent-maintained knowledge base for AI/ML research papers. Drop a PDF in `raw/`, run `/ingest`, and the wiki accretes. Start at [[overview]] if you're new here.

---

## Folder structure

```
wiki/          One note per paper. Reference mode: dense, flat, scannable.
raw/           Source PDFs for Obsidian access. Gitignored — not committed.
concepts/      Cross-paper entities and concepts. One page per concept.
topics/        Explanation and tutorial. Human learning; friction preserved.
open/          Contradictions, gaps, unresolved tensions. Discovery mode.
decisions/     Your own conclusions. What you decided and why.
```

Root files:

| File | Purpose |
|---|---|
| `overview.md` | Start here. Field map at low resolution. |
| `index.md` | Full paper catalog. Read first on every query. |
| `glossary.md` | Canonical names and definitions. |
| `log.md` | Append-only ingest ledger. |
| `CLAUDE.md` | This file. |

---

## Ingest workflow

Run `/ingest` with a PDF. Each paper is one session — error rate rises in long runs.

1. **Identify** - `ls raw/` vs `ls wiki/`. Pick one unprocessed PDF.
2. **Read** - method first, then results, then limitations. Never write from the abstract alone.
3. **Write** - create `wiki/<first-author>-<year>-<slug>.md`. Front-load the claim. Every factual statement carries a section locator (§3.1, Table 2, Fig. 1).
4. **Integrate** - add a row to `index.md`, add new terms to `glossary.md`, check for contradictions with existing notes.
5. **Log** - append to `log.md` with source, sections read, terms added, contradictions found, and current inventory count.

A note is done when a fresh agent - given only `index.md` - can state the paper's central claim, boundary conditions, and what would falsify it.

---

## Question Answering workflow

When a question arrives:

1. Read `index.md` first to find relevant pages.
2. Read those pages and synthesize an answer.
3. Cite specific wiki pages in your response using `[[wikilinks]]`.
4. If the answer is not in the wiki, say so clearly - do not fill gaps with inference.
5. If the synthesized answer is valuable and not already captured, offer to save it as a new `topics/` or `decisions/` page.

---

## Writing conventions

### Three modes - never mix them

| Directory | Mode | Optimized for | Friction |
|---|---|---|---|
| `wiki/` | Reference | Lookup by agent or human | **None** - friction here is a defect |
| `topics/` | Explanation | A human learning the field | **Preserved** - retrieval prompts, attempt-before-reveal |
| `open/` | Discovery | Generating the next question | **Deliberate** - tensions left unresolved |

### Filename convention

**3-5 words from the paper title, hyphen-separated, lowercase.** Use the most distinctive words - the ones a reader would search for. Avoid author names and years.

- "Reflexion: Language Agents with Verbal Reinforcement Learning" → `reflexion-verbal-reinforcement-learning.md`
- "Optimizing Prompts for Large Language Models: A Causal Approach" → `causal-prompt-optimization.md`

### Note template (`wiki/<title-slug>.md`)

```markdown
---
title: ""
type: reference
audience: both
created: YYYY-MM-DD
verified: YYYY-MM-DD
confidence: VERIFIED
sources: [arxiv:XXXXXXX]
supersedes: []
superseded_by: []
expires_when: "Condition that would retire this claim."
tags: []
---

# Title
Authors, venue, year.

## Claim
One or two sentences. What this paper asserts.

## Method / Core Mechanism
What they did. Enough to judge the claim. Use section locators.

## Results
| Finding | Magnitude | Conditions | Locator |

## Failure Mode / Boundary Conditions
Where this stops applying.

## Decision Knowledge
What cue motivates each design choice. When it stops applying. What a newcomer gets wrong.

## Not Stated in Source
Questions the paper raises and does not answer.

## Relations
- Cluster: [[concept-slug]]   ← link to concepts/ page (see cluster table below)
- Complements: [[slug]]
- Contradicts: [[slug]]
- Superseded by: [[slug]]
```

### Cluster assignment

Every note links to at least one concept page via `- Cluster: [[concept-slug]]`. The four current clusters:

| Concept page | Covers |
|---|---|
| [[retrieval-and-context]] | Dense retrieval, RAG, prompt compression, long-context, context engineering |
| [[prompt-optimization]] | APE, meta-prompting, causal prompt selection, prompt search |
| [[inference-efficiency]] | LLM routing, cascading, local-cloud split, edge deployment, token efficiency |
| [[agents-and-memory]] | Agent architectures, memory systems, self-improvement, multi-agent orchestration |

A paper may link to more than one cluster. If it fits none, check whether a new concept page is warranted.

### Frontmatter fields

**`expires_when`** - the falsification condition. Without it the note can never be retired. Write the observation that would make it wrong, not a date.

**`superseded_by`** - set when a newer paper answers the same question with better evidence. Keep both notes; the reason the field moved is knowledge the newer paper does not contain.

### Links

Use `[[slug]]` for all internal cross-references. Markdown links `[text](path)` are for external URLs only. Wikilinks survive file moves and power the graph view.

### Non-negotiables

- **No claim without a locator.** A claim you cannot locate gets deleted.
- **Never write from the abstract.** Abstracts overstate. Read method and limitations.
- **Contradictions open a file; they never overwrite.** New note conflicts with an existing one? Write `open/<question>.md`. Silently replacing the older claim destroys the disagreement.
- **The log is append-only.** Correct by appending a new entry that supersedes; never edit history.
