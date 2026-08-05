---
name: ingest-paper
description: Ingest a single research PDF from raw/ into the wiki. Use when asked to ingest, process, add, or read a paper from raw/, or when raw/ contains files with no corresponding wiki/papers/ entry. Covers extraction, verification against the source, index and glossary integration, contradiction detection, and logging.
---

# Ingesting a paper

**One paper per session. Fresh context every time.**

This is not a style preference. Per-step error rate rises as a run continues, partly through conditioning on your own earlier output. Batch twelve papers and you will produce a good note for the first and a confabulated one for the last — and you will not be able to tell which is which afterward. If asked to ingest several, do one, log it, and say that the next needs a fresh session.

---

## Phase 0 — Orient and claim

- [ ] `ls raw/` and `ls wiki/papers/`. Identify what is not yet ingested.
- [ ] Recount both. `wiki/log.md` has drifted before — it claimed 3 PDFs when `raw/` held 17. Trust the filesystem, not the ledger.
- [ ] Pick **one** paper. State which and why.
- [ ] Before opening it: write down what you already believe about this paper or its topic, marked `UNVERIFIED`. This is your prior. Phase 2 exists to kill the wrong parts.

## Phase 1 — Name the oracle

You cannot check your own reading. Intrinsic self-correction fails and often degrades output, so the verification source must be external.

**For this task the oracle is the PDF itself.** Concretely:

- [ ] Every claim you write must carry a locator — `§4.2`, `Table 3`, `Fig. 1`.
- [ ] Any claim you cannot locate gets deleted or marked `[not stated in source]`. Not softened. Deleted.
- [ ] A second oracle applies at Phase 4: consistency against papers already in the corpus.

If the PDF is unreadable (scanned without OCR, corrupted), **stop**. Say so, log it, do not write a note from the abstract.

## Phase 2 — Read, and read the right parts

Extract in this order. The order matters: reading results before method invites you to accept the framing.

1. **Method** — what did they actually do? Sample, task, comparison condition, what counts as success.
2. **Results** — magnitudes with their conditions attached. A number without moderators is not a finding.
3. **Limitations** — often the most valuable section and frequently the shortest.
4. **Related work** — only to find the canonical names and the contradiction edges.
5. **Abstract** — last, and only to check whether it overstates what you found. Note if it does; that itself is worth recording.

**Never write from the abstract alone.** If you have not read the method and limitations, the paper is not ingested. Mark `UNVERIFIED` and stop.

**Record which of your Phase 0 priors died.** This is the highest-value output of the session — it is what a future pass would otherwise re-derive from scratch.

## Phase 3 — Write the note

Use the `papers/` template in `wiki/CONVENTIONS.md` §8.

`papers/` is **reference mode**. Zero friction. No retrieval prompts, no exercises, no attempt-before-reveal — half your readers are agents doing lookup and friction breaks them. Front-load the claim. Keep headings identical across all paper notes; predictability beats elegance.

Filename: `<first-author>-<year>-<slug>.md`, e.g. `shinn-2023-reflexion.md`.

Two sections do the work that fluency would otherwise skip:

**Decision knowledge** — for each design choice: what cue motivated it, when it stops applying, what a newcomer would get wrong. Papers systematically record what was done and drop why it was chosen over the alternative.

**Not stated in source** — the questions this paper raises and does not answer. The back-channel is closed; a future reader cannot ask the authors. Record what they would ask.

## Phase 4 — Integrate (this is where ingest usually fails)

Writing the file is not ingesting. An unlinked note is not in the wiki.

- [ ] **`wiki/index.md`** — add exactly one row. A note absent from the index has not been transmitted, however well written.
- [ ] **`wiki/glossary.md`** — add new terms under their **canonical** names. If the paper coins a term for something the field already names, the established name is the entry and the paper's coinage is an alias.
- [ ] **`wiki/overview.md`** — does the map of the field need adjusting? Usually no. Occasionally a paper relocates a whole subfield.
- [ ] **Contradiction check** — grep the existing corpus for claims this paper conflicts with.
  - Conflict found → **open `wiki/open/<question>.md`. Do not overwrite the older claim.** The disagreement is the most valuable thing in the corpus; silently resolving it destroys information.
  - Clear supersession (same question, better method, later date) → set `superseded_by` on the old note and `supersedes` on the new. Keep both. The *reason the field moved* is knowledge the newer paper does not contain.
- [ ] **Staleness sweep** — this corpus spans 2022–2026 in AI/ML, where capability claims decay in months. If this paper makes older claims obsolete, mark them rather than deleting them.

## Phase 5 — Log

Append to `wiki/log.md`. Never edit a prior entry; supersede it with a new one.

```markdown
## <ISO date> — ingest: <slug>
- Source: raw/<file>.pdf
- Read: <which sections, in full or partially>
- Priors that died: <what you believed at Phase 0 that was wrong>
- Wrote: wiki/papers/<slug>.md
- Index: row added
- Glossary: +<terms>
- Contradictions: <none | conflicts with X → opened wiki/open/Y.md>
- Confidence: VERIFIED | PARTIAL | UNVERIFIED
- Inventory after: <n>/<total> ingested   ← recount raw/, do not copy the last figure
```

---

## Failure hygiene

If you get stuck — a section you cannot parse, a result you cannot reconcile — **do not keep grinding in the same context.** Your error rate is now rising, and each retry inside a polluted trace is more likely to fail than the last.

1. **Extract** — what specifically blocked you, and what would have signalled it earlier.
2. **Externalize** — write it into the note's *Not stated in source*, or into `log.md`.
3. **Evict** — drop the failed reasoning. Restart from the last verified locator.

A rising error rate mid-session is usually not a harder paper. It is self-conditioning. Reset rather than retry.

---

## Done when

A fresh agent, no memory of this session, given only `wiki/index.md`, can find this paper, state its central claim, name its boundary conditions, and say what observation would show it wrong.

Not when the file exists. Not when it reads well.

**Then stop.** Do not start the next paper.
