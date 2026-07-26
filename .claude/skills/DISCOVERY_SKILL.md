---
name: wiki-discovery
description: Find what the corpus knows that no single paper states — contradictions between papers, untested shared assumptions, stale claims, single-study findings treated as settled, and unexplored transfers between methods and problems. Use when asked to find gaps, contradictions, open questions, research directions, or what to read next, or when running a periodic corpus review.
---

# Discovery

Ingest records what each paper says. Discovery finds what is true of **the corpus** and stated in **no paper**. That is where the wiki stops being a filing cabinet.

Output goes to `wiki/open/`. Not to `papers/` — those mirror single sources. Not to `topics/` — those explain settled things.

**Prerequisite: at least ~5 ingested papers.** Below that you are pattern-matching on noise.

---

## The honesty constraint

You cannot verify that a finding is new. You can only verify that it is absent from *this corpus*, which is 17 papers.

Most apparent discoveries are things you do not know the name for. Before writing anything to `wiki/open/`, **search for the canonical name.** If the field already calls this something, you have found a gap in the wiki, not a gap in the literature — still useful, but a different claim, and it belongs in the glossary rather than in `open/`.

Every `open/` page states which it is:

- `GAP-IN-WIKI` — the corpus lacks it; the field probably has it. Go find it.
- `GAP-IN-CORPUS` — nothing among these 17 papers addresses it. Says nothing about the field.
- `GAP-IN-FIELD` — searched, found nothing. **The highest bar and the rarest. Requires an actual external search, and say what you searched.**

Overclaiming here poisons the wiki, because a false `GAP-IN-FIELD` looks exactly like a research direction.

---

## Six patterns worth hunting

Run these as passes. Each has a mechanical starting point — you have `ripgrep`, `fd`, and `jq` in the dev shell.

### D1 — Direct contradiction
Paper A claims X; paper B claims not-X. Both cannot be right, and the reason one is wrong is usually more interesting than either claim.

*Find it:* grep the `## Claim` lines across `papers/`. Look for the same dependent variable with opposite signs.

*Do not resolve it.* Write both positions at their strongest. If one is obviously wrong, this is not an open question — it is a superseded claim, so set `superseded_by` and move on.

### D2 — Unexamined shared assumption
Every paper assumes Y. None tests Y. This is the highest-value pattern in any corpus and the hardest to see, because the assumption is invisible precisely by being universal.

*Find it:* read the `## Method` sections consecutively, ignoring results. Ask what every method takes for granted — about the task, the metric, the population, the baseline. Then ask: *does any paper here vary that?*

*Example shape:* every agent-memory paper evaluates on tasks where the memory is helpful. None tests whether retrieval hurts when the store contains irrelevant material.

### D3 — Silent staleness
A claim that was true when written and is not now. This corpus spans 2022–2026 in AI/ML; capability claims decay in months, and a 2022 statement about what models can do reads as current fact unless marked.

*Find it:* sort `papers/` by publication year. For anything before the last 18 months, ask whether its *premise* still holds — not its finding, its premise. "Models cannot do X" ages fastest.

*Output:* usually a `superseded_by` edge rather than an `open/` page. Reserve `open/` for cases where whether it is stale is itself contested.

### D4 — Single study treated as settled
One paper, one lab, one benchmark, cited as established. Look for claims everything else in the corpus rests on and nothing replicates.

*Find it:* count inbound references in the `## Relations` sections. A note that many others support-link and nobody contradicts is either genuinely solid or unchecked. Check which.

*Ask:* has anyone replicated this on different data, with a different harness, by a different group? For agent results specifically, scaffold choice alone substantially shifts outcomes, so "different harness" is a real test rather than a pedantic one.

### D5 — Unexplored transfer
Method from paper A has never been applied to problem B, and nothing rules it out. This is the most generative pattern and the one most prone to producing plausible nonsense.

*Find it:* build the method × problem grid from `tags`. Look at the empty cells.

*Discipline:* an empty cell is only interesting if you can say **why it might work** and **what would make it fail**. Most empty cells are empty for good reasons. If you cannot name the reason it is empty, you have not found anything yet.

### D6 — Claim/method mismatch
The finding does not support the framing. The abstract says one thing; the method licenses something narrower.

*Find it:* for each note, read `## Claim` against `## Method` and `## Boundary conditions` with the abstract's framing set aside.

*Output:* usually a correction to the paper note plus a glossary entry, not an `open/` page. If the mismatch is widespread across the corpus, that is a D2.

---

## Procedure

**Phase 0 — Scope.** Pick one pattern. Do not run all six in one session; the passes interfere, and your error rate rises across a long run. State which pattern and which subset of papers.

**Phase 1 — Oracle.** Discovery has a weak oracle, which is why the honesty constraint above is load-bearing. Available checks, in order of strength:
1. External literature search for the canonical name — the only thing separating `GAP-IN-FIELD` from ignorance.
2. Re-read the source PDFs, not your notes. Your notes are a lossy compression and the gap may live in what you compressed away.
3. Internal consistency across `papers/`.

If you cannot run at least (2), cap the claim at `GAP-IN-CORPUS`.

**Phase 2 — Sweep.** Mechanical pass per the pattern above. Collect candidates without judging them.

**Phase 3 — Kill.** Most candidates are wrong. For each, actively look for the reason it is not interesting:
- Already named in the field?
- Already answered in a paper you skimmed?
- Empty cell that is empty for an obvious reason?
- An artifact of your own note-taking rather than of the papers?

**Whatever survives deliberate attempts to kill it is worth writing up.** What survives only inattention is not.

**Phase 4 — Write.** Use the `open/` template in `wiki/CONVENTIONS.md` §7. State the classification (`GAP-IN-WIKI` / `-CORPUS` / `-FIELD`) and what you searched. Add the row to `wiki/index.md`.

**Phase 5 — Log.** Append to `wiki/log.md`: pattern run, papers swept, candidates found, candidates killed and why, pages opened. **Record the kills.** A future pass that does not know what was already ruled out will re-derive the same dead ends.

---

## Reviewing open questions

`open/` decays faster than anything else in the wiki — questions get answered by papers that arrive later.

On each ingest, check whether the new paper touches any open question. On a periodic sweep, update `Status`:

- `OPEN` — still live
- `NARROWING` — evidence accumulating, note which way
- `RESOLVED` — link the resolution, **keep the page**. The record of what was once uncertain is how a future reader calibrates how much to trust current certainty.

Never delete a resolved question. Deleting it removes the evidence that the field changed its mind, which is exactly the information that makes the next disagreement legible.

---

## Anti-patterns

| Doing this | Why it fails |
|---|---|
| Claiming `GAP-IN-FIELD` without an external search | You found something you don't know the name for |
| Resolving an open question to feel productive | Destroys the only thing the page was for |
| Listing empty grid cells as research directions | Most are empty for good reasons; without the reason it is noise |
| Running all six patterns in one session | Passes interfere and long runs degrade |
| Working from notes without re-reading sources | The gap often lives in what your note compressed away |
| Deleting resolved questions | Removes the record that the field changed its mind |
| Not logging killed candidates | The next pass re-derives the same dead ends |
