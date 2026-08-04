# wiki/CONVENTIONS.md

**How to write anything in `wiki/`.** Load when writing or editing wiki prose. Not resident.

Assumes you have read `CLAUDE.md` (repo mechanics) and `BEHAVIORAL_AND_CULTURE.md` (learning and handoff behavior). This file covers the third thing: what a good page looks like.

---

## 1. Frontmatter — required on every file

Retrieval scoring needs fields. An entry with no date and no importance signal surfaces at the wrong moments forever.

```yaml
---
title: Reflexion — verbal reinforcement learning for language agents
type: reference          # reference | explanation | tutorial | how-to | open-question
audience: both           # agent | human | both
created: 2026-07-25
verified: 2026-07-25     # last time a human or oracle confirmed this
confidence: VERIFIED     # VERIFIED | PARTIAL | UNVERIFIED
sources: [arxiv:2303.11366]
supersedes: []
superseded_by: []
expires_when: "A method reports weight-updating agents that outperform in-context reflection at equal cost"
tags: [agents, memory, self-improvement, in-context-learning]
---
```

Two fields carry unusual weight here.

**`expires_when`** is the falsification handle. Without it, a wiki becomes a fossil bed — high-fidelity transmission propagates errors exactly as faithfully as truths. Write the observation that would retire the claim, not a date.

**`superseded_by`** is the selection mechanism. In a corpus spanning 2022–2026 in AI/ML, most capability claims will eventually be superseded. Recording the edge preserves *why the field moved*, which is knowledge the newer paper does not contain.

---

## 2. Architecture discipline — never mix the four modes

Mixing modes is the largest single cause of unusable documentation. Each mode serves a different reader state and needs a different register.

| Mode | Reader | Does | Never does |
|---|---|---|---|
| **Reference** (`papers/`) | Working, looking something up | Mirrors the structure of the source. Strictly scannable. | Teaches, instructs, or argues |
| **Explanation** (`topics/`) | Learning, wants to understand | Gives context, rationale, rejected alternatives, why the field went this way | Walks through a procedure |
| **Tutorial** (`topics/`) | Learning, wants to do | A guided lesson with guaranteed success | Digresses into explanation |
| **How-to** (`topics/`) | Working, wants a result | A recipe assuming domain competence | Teaches principles |
| **Open question** (`open/`) | Discovering | States a tension and leaves it unresolved | Resolves it to feel finished |

**Explanation is the mode most often missing and the slowest to decay** — rationale outlives implementation. In this corpus especially, the *why did people try this* survives long after the benchmark numbers are worthless.

---

## 3. Register by directory

### `papers/` — reference, zero friction
The reader is looking something up, and half of them are agents. Optimize for retrieval, not for reading experience.

- Front-load the claim. First line after frontmatter states what the paper found.
- Flat structure, consistent headings across all paper notes. Predictable beats elegant.
- No retrieval prompts, no attempt-before-reveal, no exercises. **Friction here is a defect.**
- Numbers with their conditions attached. `d = 0.48 (435 studies, enormous heterogeneity)` not `d = 0.48`.
- Locators on every claim: `§4.2`, `Table 3`, `Fig. 1`.

### `topics/` — explanation and tutorial, friction preserved
The reader is a human trying to learn. Fluency is inversely related to durability: text that reads smoothly produces confident readers who retain nothing.

- **Declare assumed prior knowledge in the first line.** Do not average across skill levels — a page pitched at the midpoint serves neither end. Forced to choose, over-serve the newcomer.
- **Force retrieval.** At least one question per major section whose answer is not visible from the same screen.
- **Attempt before reveal.** Where there is a design decision, ask what the reader would do before saying what the field did.
- **Fade the scaffolding.** Early sections carry worked examples; later ones blank out steps. Support that is never withdrawn is not scaffolding, it is dependency.
- **Global before local.** Map the whole before drilling in, or the details have nowhere to attach.

### `open/` — discovery, tension preserved
The reader wants a question worth chasing. Resolving prematurely destroys the artifact's only value.

- State both positions at their strongest. If one is obviously wrong, this is not an open question.
- Name what evidence would settle it.
- Name who would have to be wrong.
- Do not conclude. An `open/` page that ends in a resolution should have been a `topics/` page.

---

## 4. Elicitation — surface what fluency hides

Unprompted experts omit roughly 70% of decision steps in procedures they know well. Papers do this too, systematically: methods sections record what was done and drop why it was chosen over the alternative.

For every method or design decision you record:
- **What cue triggered it?** What in the problem made this the right move?
- **What if the cue were absent?** When does this approach stop applying?
- **What would a newcomer get wrong here?** The trap that the authors navigated silently.

Where the paper does not say, write `[not stated in source]`. That gap is information — it tells a future reader what to go ask the authors, and it is the single most common thing lost between a paper and a note about it.

**Narrate regulation, not just reasoning.** When your own ingest got stuck, say so in the topic page: *"The connection between §3 and the results table is not obvious; what unlocked it was noticing that Table 2 reports a different metric."* A record of frictionless forward progress teaches the reader that confusion means they are unsuited.

---

## 5. Links — use wikilinks throughout

All cross-references between wiki files use Obsidian wikilink syntax: `[[slug]]` or `[[slug|display text]]`. Do not use markdown links `[text](path.md)` for internal wiki cross-references. Wikilinks power the graph view and survive file moves.

- Paper to paper: `[[shinn-2023-reflexion]]`
- Paper to glossary: `[[glossary]]` (link to the file; Obsidian will resolve)
- Paper to open question: `[[open/does-self-reflection-work]]`
- Index and glossary entries pointing to papers: `[[gao-2022-hyde]]`

Markdown links are fine for external URLs and for references to files outside `wiki/`.

---

## 6. Provenance and durability

**Triage.** Spend depth on what is causally opaque or expensive to rediscover. Spend nothing on what a reader could infer from the abstract in five minutes. You cannot maximize what is known by writing everything down — every added token degrades what surrounds it. **State what you chose to omit and why.**

**Canonical names only.** If the field calls it "expertise reversal," call it that — not "the support-expiry effect." Private vocabulary severs your page from every other page written on the topic, however good your explanation is. New terms go in `glossary.md` with the canonical name as the primary entry and your phrasing as an alias, never the reverse.

**Confidence markers are mandatory.** `VERIFIED` (checked against the source), `PARTIAL` (some claims checked), `UNVERIFIED` (from abstract or secondary source). "I am not sure" is transmissible. False certainty corrupts everything downstream.

**Numbers carry their moderators.** A pooled effect size stripped of its boundary conditions is misinformation with a decimal point. The useful unit is *claim + condition*, never claim alone.

---

## 7. Evaluation apparatus

`topics/` pages ship with a way for the reader to check themselves.

- **Progressive hints.** Hint → bigger hint → answer, in collapsed sections. How deep a reader dug is a free competence signal, and it degrades more gracefully than any quiz score.
- **Mastery standard, variable time.** State what "you've got this" looks like. Let time-to-reach-it vary; hold the standard fixed.
- **Test process, not product.** A reader who followed your instructions has proven your instructions are followable, which is not the same as understanding. Ask them to justify a step, or say what changes if a stated condition is false.
- **Delay matters.** Any self-check placed immediately after the material measures retrieval strength, not learning. Where you can, point the reader to a check a week out.

---

## 8. Templates

### `wiki/papers/<first-author>-<year>-<slug>.md`

```markdown
---
[frontmatter per §1]
---

# <Title>
<Authors, venue, year. arXiv ID.>

## Claim
<One or two sentences. What this paper asserts. Front-loaded.>

## Method
<What they actually did. Enough that a reader can judge the claim. §locators.>

## Results
| Finding | Magnitude | Conditions | Locator |

## Boundary conditions
<Where this stops applying. Often the most valuable section and usually
 buried in the paper's limitations, if stated at all.>

## Decision knowledge
| Design choice | Cue that motivated it | If absent | Newcomer trap |

## Not stated in source
<Questions the paper raises and does not answer. Closed back-channel:
 the reader cannot ask the authors, so record what they would ask.>

## Relations
- Supports: [[other-paper-slug]]
- Contradicts: [[other-paper-slug]] → see [[open/question-file]]
- Superseded by: [[newer-paper-slug]]

## Expiry
<What observation would retire this. Re-verify by: <trigger>>
```

### `wiki/topics/<slug>.md`

```markdown
---
[frontmatter; type: explanation]
---

# <Topic>

**Assumes you know:** <explicit list>
**After this you should be able to:** <observable capabilities, not "understand X">

## The whole thing at low resolution
<Global before local. Wrong-but-useful is fine here.>

## <Section>
<Explanation. Rationale. What was rejected and why.>

> **Before reading on:** <question whose answer is below, not beside>
> <details><summary>Hint</summary>…</details>
> <details><summary>Answer</summary>…</details>

## Where this is still unsettled
<Link to wiki/open/. Do not resolve here.>

## Sources
<Links to wiki/papers/. Never restate their numbers — link.>
```

### `wiki/open/<question-as-a-question>.md`

```markdown
---
[frontmatter; type: open-question]
---

# <Stated as an actual question>

## The tension
<Position A, strongest form, with sources.>
<Position B, strongest form, with sources.>

## Why it isn't already settled
<What makes this hard. If the answer is "nobody checked," say so — that is
 a research opportunity, not a gap in the wiki.>

## What would settle it
<The observation, experiment, or paper that would resolve this.>

## Who has to be wrong
<Name the position that fails under each resolution.>

## Status
Opened <date> · Last reviewed <date> · <OPEN | NARROWING | RESOLVED → link>
```

---

## 9. Anti-patterns

| Doing this | Why it fails |
|---|---|
| Retrieval prompts in `papers/` | Friction in reference mode breaks lookup for both readers |
| Terse reference prose in `topics/` | Pleasant, fast, and nothing is retained |
| Resolving an `open/` page to feel finished | Destroys the only thing that page was for |
| Effect size without moderators | Misinformation with a decimal point |
| Coining a term the field already names | Severs the page from all related literature |
| Writing a paper note from the abstract | Abstracts systematically overstate (N3) |
| Overwriting a claim a new paper contradicts | Deletes the disagreement, which was the signal (N5) |
| Undated claims in a 2022–2026 AI corpus | Historical artifacts read as current facts |
| Restating a paper's numbers in a topic page | Two copies drift; link instead |
| Omitting `expires_when` | The page cannot ever be retired, only silently trusted |
