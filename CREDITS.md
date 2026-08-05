# CREDITS.md

Provenance for a repo whose whole premise is provenance. Where a specific idea came from a specific person, they're named.

---

## The pattern

**[Andrej Karpathy — *LLM Wiki*](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** (April 2026)

The foundation. Three layers (immutable sources → agent-maintained wiki → schema), three operations (ingest, query, lint), and two special files (`index.md` content-oriented, `log.md` chronological and append-only). The grep-parseable log prefix convention — `## [YYYY-MM-DD] op | subject` — is taken directly from the gist.

The framing that stuck: *"Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."* Taking that literally is what justifies importing software-engineering discipline into knowledge work.

**[Greener-Dalii — *Karpathy LLM Wiki* Obsidian plugin](https://community.obsidian.md/plugins/karpathywiki)**

The most complete implementation of the pattern, and the source of several conventions here: mandatory page aliases for cross-language and abbreviation duplicate detection, the contradiction state machine (`detected → review-passed → resolved` / `unresolved`), `reviewed: true` frontmatter as overwrite protection, and the pre-ingest requirements gate that rejects empty or frontmatter-only sources before spending a single token.

---

## Ideas taken from the gist discussion

The comment thread on Karpathy's gist is, at time of writing, more useful than most published work on this pattern. Specific debts:

**[@suwonleee](https://github.com/suwonleee)** — *the reason `review/` exists.* Observed that the pattern puts judgment on the human but contains nothing to stop that side decaying: your wiki stays current, your memory of why you decided things doesn't. Also the source of the 1·3·7·16·35·60 day spaced schedule, and the restriction of spaced review to decision and insight pages — the ones whose *why* rots — rather than reference material. Two further findings imported: that citations pointing at local session files are provenance for exactly one person, and that indexing inline evidence excerpts *hurts* page findability through BM25 length normalization.

**[@frankchu91](https://github.com/frankchu91)** — *tool boundaries over instructions.* The finding that the biggest drift reducer wasn't better prompts but making the layer contract physically unviolable via tool allowlists, so a sloppy turn cannot corrupt the source layer even in principle. This is why `raw/` is unwritable by the ingest agent rather than merely declared off-limits, and why `reviewer` has no write tools at all.

**[@xXgordonXx](https://github.com/xXgordonXx)** — *the four-tier storage discipline* (raw never in git / staging lightly versioned / wiki fully reviewed / schema at higher scrutiny), the `refs:` frontmatter → computed DAG enabling **push-based** staleness detection, and page-level locking plus a mandatory index check before page creation as schema-enforced rules rather than agent judgment.

**[@distorx](https://github.com/distorx)** (via the same thread) — *drift is the primary failure mode*, not hallucination: the agent under-updating cross-references on ingest so pages silently go stale. Also the new-page-vs-edit heuristic — new page when it's a distinct thing you'd link to from elsewhere, edit in place when it's an attribute of something existing — which works about nine times in ten *once the schema enumerates the page types*. And the observation that scheduled lint is not optional.

**[@alfadur7](https://github.com/alfadur7)** — *the four-loop harness framing*: inner (self-check while drafting), outer (review at publication), meta (schema evolves; a defect caught twice becomes a rule), plus a fourth loop that knowledge work needs and software doesn't, because shipped code stays correct until the spec changes while knowledge rots on its own. The specific requirement that the outer loop needs *a fresh-eyes agent that didn't write the page and can't see the writer's reasoning* is the design basis for the `reviewer` subagent.

**[@sturlese](https://github.com/sturlese)** — the argument for radical inspectability: a missed lookup should be a bad line in a file you can open and fix, not an opaque similarity score. Reinforced the decision against a vector database at this scale.

**[@simontaurus](https://github.com/simontaurus)** — the warning that unqualified links plus free text is what actually fails to scale, and that write-time entity resolution against a live graph is the hard part. Informed the frontmatter schema.

**[@DaveMikeP](https://github.com/DaveMikeP)** — the principle that deterministic operations should run as classical computation rather than LLM calls. Directly responsible for `scripts/` existing.

**[@gavischneider](https://github.com/gavischneider)** — [awesome-llm-wiki](https://github.com/gavischneider/awesome-llm-wiki), the running catalogue of implementations. Useful for seeing what's been tried.

---

## Documentation architecture

**[Daniele Procida — Diátaxis](https://diataxis.fr/)**

The four-mode framework — tutorial, how-to, reference, explanation — and the argument that documentation fails primarily by *conflating* them. The directory split in `wiki/` is Diátaxis applied. Procida's observation that explanation is both the most-often-missing mode and the slowest to decay is why `wiki/topics/` and `wiki/open/` exist as separate things.

**[Anthropic — Agent Skills](https://agentskills.io/)**

Three-tier progressive disclosure: name and description at discovery, full body on activation, references on demand. Convergent with 4C/ID's supportive-vs-just-in-time information split, discovered independently in a different field forty years later.

---

## The learning science

Full citations with effect sizes, sample counts, and boundary conditions are in [`learning-transmission-principles.md`](learning-transmission-principles.md) §12. The load-bearing ones:

**Sullivan, Yates, Inaba, Lam & Clark (2014)**, *Academic Medicine* — the 70% rule. Surgeons describing routine procedures from unaided recall omitted an average of 71% of clinical knowledge steps and 73% of decision steps. The single most actionable finding in this repo, and the basis for the elicitation structure in `wiki/CLAUDE.md`.

**Soderstrom & Bjork (2015)**, *Perspectives on Psychological Science* — learning versus performance. That the two can move in opposite directions is why fluent documentation is not good documentation.

**Sinha & Kapur (2021)**, *Review of Educational Research* — productive failure, and its dependence on an explicit comparison phase.

**Adesope, Trevisan & Sundararajan (2017)**; **Latimier, Peyre & Ramus (2021)**; **Brunmair & Richter (2019)** — retrieval practice, spacing, and interleaving, with the moderators that make them conditional rather than universal.

**Collins, Brown & Newman (1989)** — cognitive apprenticeship. Used here as design vocabulary, explicitly *not* as an evidence claim; it's a multi-component framework that doesn't yield a defensible pooled effect size.

**van Merriënboer & Kirschner (2018)**, *Ten Steps to Complex Learning* — 4C/ID, and the transfer paradox.

## The agent science

**Sinha, Arun, Goel et al. (2025)**, [arXiv:2509.09677](https://arxiv.org/abs/2509.09677) — self-conditioning. Per-step error rate *rises* as a task progresses, and models conditioned on their own prior errors become more error-prone. The reason `/ingest` refuses batches and failure traces get evicted rather than retained.

**Zheng, Pei, Logeswaran, Lee & Jurgens (2024)**, [arXiv:2311.10054](https://arxiv.org/abs/2311.10054) — personas in system prompts do not improve performance. The reason no file here contains an identity claim.

**Huang, Chen, Mishra et al. (2024)**, ICLR, [arXiv:2310.01798](https://arxiv.org/abs/2310.01798) — LLMs cannot reliably self-correct reasoning without external feedback. The reason every workflow names an oracle before starting.

**Hong, Troynikov & Huber (2025)**, [Context Rot](https://www.trychroma.com/research/context-rot), Chroma Research — degradation across 18 frontier models well before nominal limits, with structured input degrading attention *more* than shuffled.

**Shinn, Cassano, Gopinath, Narasimhan & Yao (2023)**, [Reflexion](https://arxiv.org/abs/2303.11366) — verbal reinforcement via an episodic buffer. Note what it reflects *on*: environmental feedback.

**Wang, Xie, Jiang et al. (2023)**, [Voyager](https://arxiv.org/abs/2305.16291) — skill library as durable, verified, compositional store. The argument for preferring executable artifacts to prose.

**Park, O'Brien, Cai et al. (2023)** — Generative Agents. Multi-factor memory retrieval (recency × relevance × importance), which is why frontmatter carries the fields a scoring function would need.

---

## Prior art worth knowing about

Other implementations of the pattern, several more mature than this one. Listed because the honest thing to do is point at the alternatives:

- [mindbase](https://github.com/frankchu91/mindbase) — MCP server, tool-boundary enforced
- [okf-gem](https://github.com/serradura/okf-gem) — agent skill + CLI + server, Ruby
- [hippocampus](https://github.com/sturlese/hippocampus) — deliberately minimal, no dependencies
- [synto](https://github.com/kytmanov/synto) — local-first, concept relation graph
- [Eva-brain](https://github.com/jp-lorenc1o/Eva-brain) — desktop app with a git-backed review gate
- [llmwiki](https://github.com/suwonleee/llmwiki) — the one with the quiz

---

## What this repo adds

For completeness, and so the delta is auditable rather than implied: the spaced-retrieval layer for the human reader (`review/`), the explicit split of the wiki into modes with *opposite* friction requirements, the audited evidence base with a merge log recording rejected claims, and the agent-behaviour contract in `BEHAVIORAL_AND_CULTURE.md`.

Everything else here is assembled from the work above.
