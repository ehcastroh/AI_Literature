---
name: update-glossary
description: Sweep ingested papers for new AI terms and add them to Dictionary_AI. Use when asked to update the glossary or dictionary, after ingesting new papers, or as the second step in the /scout flow. Dictionary_AI is the single source of truth — never write to wiki/glossary.md.
---

# Updating Dictionary_AI from AI_Literature

All AI terminology for the LLM_Wikis project lives in `~/Projects/LLM_Wikis/Dictionary_AI/dictionary/`. This skill extracts term candidates from ingested papers and adds them following the protocol in `Dictionary_AI/.claude/skills/dictionary-update.md`.

**Read `Dictionary_AI/.claude/skills/dictionary-update.md` before writing any files.** That skill governs file format, status lifecycle, and tag assignments. This skill governs what to extract and what is worth adding.

---

## Phase 0 — Scope the Sweep

Determine what to sweep before starting:

**Triggered after a specific ingest** (e.g., called from `/scout` after ingesting a new paper): sweep only that paper's wiki note and its log entry. The paper slug should be available from the ingest session.

**Standalone invocation**: check `wiki/log.md` for the most recent entries. Look for papers whose log entry includes `Glossary: +<terms>` or `Glossary: no new field-standard terms` — the latter means terms were deferred or the agent was uncertain. Sweep those notes.

**Full sweep** (first run or after a long gap): sweep all `wiki/wiki/` notes. The duplication check in Phase 1 prevents double entries.

State the scope explicitly before proceeding.

---

## Phase 1 — Extract Term Candidates

For each note in scope, collect candidates from:

1. **`wiki/log.md` glossary lines** - the `Glossary: +<term>` entries from the ingest log. These are terms the ingesting agent identified but may not have added to Dictionary_AI.

2. **Bold and backtick terms in `## Method` and `## Claim`** - field-specific techniques, frameworks, architectures, and named mechanisms that appear in those sections. Scan with:
   ```bash
   grep -h "^\*\*\|^\`" wiki/wiki/<slug>.md
   ```

3. **Terms flagged as "emerging" or "not yet canonical"** in log entries - these are stub candidates even if not ready for a full entry.

Check which terms are already in Dictionary_AI:
```bash
ls ~/Projects/LLM_Wikis/Dictionary_AI/dictionary/ | sed 's/\.md$//'
```

Remove any candidate already present. If a candidate is present as a stub, flag it for promotion rather than creation.

---

## Phase 2 — Evaluate Each Candidate

For each remaining candidate, apply three tests:

**Test A — Field-standard or paper-specific?**
A term is field-standard if it appears in multiple papers in the corpus, is used in related-work sections without definition, or is a named method/benchmark/framework that the broader community references. A term is paper-specific if only one paper uses it and it does not appear in any other corpus note's related-work or background sections.

- Field-standard → eligible for `introduced` status with a full definition
- Paper-specific → eligible for `stub` status only; do not write a full definition from a single source

**Test B — Is it a proper noun or a concept?**
Proper nouns (AlphaEvolve, GAPG, IPPg, MinionS, UniRoute, HyDE) are codenames for specific systems, not reusable field vocabulary. Do not add them unless the name has become the field's standard term for the concept it introduced (e.g., "Reflexion" may be becoming the canonical name for verbal reinforcement learning in agents).

Benchmark names (HumanEval, BEIR, GAIA) — do not add unless the benchmark is itself a methodological concept reused across the field.

**Test C — Does it belong in Dictionary_AI or somewhere else?**
Do not add terms that are primarily Claude Code / AI coding workflow vocabulary (context window, token, prompt caching) — those belong in `mattpocock/dictionary-of-ai-coding`.

---

## Phase 3 — Assign Tags

Map each approved candidate to exactly one section tag from `dictionary-update.md`:

| Tag | Assign when the term primarily concerns… |
|---|---|
| `gpu-hardware` | GPU memory, bandwidth, compute units |
| `inference-loop` | Decoding, attention, KV cache, token generation |
| `parallelism` | Distributed training/serving across devices |
| `serving` | Batching, scheduling, latency optimization |
| `retrieval` | Dense retrieval, RAG, prompt compression, context assembly |
| `agent-memory` | Agent architectures, memory systems, self-improvement, multi-agent |
| `profiling` | Benchmarking, evaluation, metrics |

Add a second tag only if the cross-section relationship is load-bearing — a user filtering by either section would reasonably expect to find this term. Most terms belong to one section.

---

## Phase 4 — Write Entries

Follow `Dictionary_AI/.claude/skills/dictionary-update.md` exactly for file creation. Summary:

- **Filename**: exact term casing and spacing used in the corpus (e.g., `Contrastive perplexity.md`, `LLM routing.md`, `Model cascading.md`)
- **Frontmatter**: `description` under 140 chars, `tags: [tag]`, `status: stub | introduced`
- Do NOT add `introduced-in` — that field is for Teach curriculum modules only
- **Body for `introduced` terms**: 200+ words; define precisely, give the intuition, name the boundary conditions. Source the definition from the paper's method section, not the abstract.
- **Body for `stub` terms**: omit or write one sentence only; a stub claims the term without defining it
- **Cross-link** from related terms already in the dictionary using `[Term](./Term%20name.md)` (URL-encode spaces as `%20`)

For terms where the paper coins a name for something the field already calls something else, the established name is the entry and the paper's coinage is listed under `_Avoid:_`.

---

## Phase 5 — Log

After writing all entries, append to `wiki/log.md`:

```markdown
## <ISO date> — glossary update
- Swept: <paper slugs swept, or "all N notes">
- Added to Dictionary_AI: +<term>, +<term>
- Promoted stubs: <none | list>
- Skipped (paper-specific): <codenames not added>
- Skipped (already present): <terms already in Dictionary_AI>
```

If invoked as part of a `/scout` flow, this log entry is still required — the scout log covers paper discovery, not term extraction.

---

## Anti-patterns

| Doing this | Why it fails |
|---|---|
| Writing to `wiki/glossary.md` | Dictionary_AI is the single source of truth; `wiki/glossary.md` is not authoritative |
| Adding paper-specific codenames as field terms | Pollutes the dictionary with vocabulary nobody outside the paper uses |
| Writing a full `introduced` definition from one corpus paper | Single-source definitions are stubs; the field's definition may differ |
| Skipping the duplication check | Creates two files for the same term with diverging definitions |
| Adding `introduced-in` for AI_Literature terms | That field tracks Teach curriculum modules only |
| Promoting a stub to `introduced` speculatively | Status reflects demonstrated user understanding, not agent confidence |

---

## Done when

All candidates have been evaluated, approved or rejected with reasons, and approved terms are written to `Dictionary_AI/dictionary/`. The log entry is appended and `scripts/lint.sh` runs clean.

If invoked from `/scout`, return to the scout flow after completing Phase 5.
