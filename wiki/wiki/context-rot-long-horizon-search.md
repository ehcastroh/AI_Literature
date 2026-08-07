---
title: "Diagnosing and Mitigating Context Rot in Long-horizon Search"
type: reference
audience: both
created: 2026-08-06
verified: 2026-08-06
confidence: VERIFIED
sources: [arxiv:2606.29718]
supersedes: []
superseded_by: []
expires_when: "A method eliminates premature termination in long-horizon agentic search without increasing tool-call cost, or a study shows premature termination is caused by query difficulty rather than context length."
tags: [context-engineering, agents, long-context, inference-efficiency, agentic-search, context-management]
---

# Diagnosing and Mitigating Context Rot in Long-horizon Search

Shijie Xia, Yikun Wang, Zhen Huang, Pengfei Liu. Shanghai Jiao Tong University / Fudan University / SII / GAIR. arXiv:2606.29718. June 2026 (v2 August 2026).

## Claim

In long-horizon agentic search, context rot does not cause models to fail by exceeding the context window — it causes **premature termination**: models give up or provide uncertain incorrect answers while a large portion of the context window remains available. Premature termination rate is positively correlated with context length even after controlling for query difficulty. Context management methods work as test-time scaling strategies that reduce premature termination to enable more exploration, at the cost of additional tool calls. Behavior-aware filtering of parallel sampling trajectories improves accuracy by 2.6–4.9pp. (Abstract, §3, §4)

## Method / Core Mechanism

**Diagnostic framework (§3):**

Four-category terminal state taxonomy applied to agent trajectories:
- *Confident Correct (CC)* — clear answer, reasoning shows all criteria met
- *Uncertain Correct (UC)* — correct answer but reasoning shows unresolved doubt
- *Confident Incorrect (CI)* — wrong answer, model believes it is right
- *Uncertain Incorrect (UI)* — wrong answer with explicit uncertainty in reasoning
- *Give Up (GU)* — agent states it cannot solve the problem, no clear answer
- *No Answer (NA)* — context limit or turn budget reached

**Premature termination** = GU + UI rate. Measured by GPT-OSS-120B as judge with 5-fold majority vote; 98.7% agreement with human annotations on 300 trajectories. (§3.2, Appendix B.1)

**Experimental setup (§3.3):** Four open-source flagship models (GLM-4.7 ~200K ctx, GLM-5.0 ~200K ctx, Qwen3.5-397B-A17B 256K ctx, MiniMax-M2.5 ~200K ctx) across three benchmarks: BrowseComp, BrowseComp-Plus, xbench-DeepSearch. 100-sample split for BrowseComp. Max 100 interaction turns. 5 runs each.

**Context management methods evaluated (§4.1) — three categories, seven variants:**
1. *Context compaction* — three trigger variants: length threshold (32K/96K), turn count (every 10), semantic struggle score ≥ 0.5 over a 10-turn sliding window
2. *Context trimming* — discard-all (drop all tool responses except last), keep-latest (retain 3 most recent turns), keep-latest with summarization
3. *Context isolation* — FoldAgent (sub-agents execute tasks, return only summarized outcomes to main agent)

**Behavior-aware filtering (§4.2):** Sample 8 parallel trajectories per query without context management. Before aggregation, filter out GU and UI terminations — retaining only confident answers. Fall back to unfiltered set if no confident answer remains. Evaluate across three aggregation methods: fewest turns (FT), minimum length (FL), majority voting (MV).

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| Premature termination dominates late trajectories | GU + UI become dominant terminal states as trajectory length grows | All 4 models, all 3 benchmarks | §3.3, Fig. 2 |
| Length-difficulty control confirms PT causal link | PT rate increases monotonically from shortest to longest trajectory group | Same queries across groups, difficulty held fixed | §3.3, Fig. 4 |
| Context management best: FoldAgent (strong models) | Qwen3.5-397B: 54.0% accuracy on BrowseComp vs. 35.0% ReAct baseline | 57.4 avg tool calls vs. 21.7 | §4.1, Table 3 |
| Context management best: Keep-latest+sum (weak models) | GLM-4.7: keep-latest (w/ sum.) best balance on BrowseComp | FoldAgent is among the worst for GLM-4.7 | §4.1, Table 3 |
| Behavior-aware filtering gain | +2.6% to +4.9% across three aggregation methods | Qwen3.5 + Filter; 3 benchmarks averaged | §4.2, Table 5 |
| ReAct + parallel sampling vs. context management | Matches or beats context management on xbench-DeepSearch; loses on BrowseComp/BrowseComp-Plus | Tool call budget equalized (4 samples ctx mgmt, 8 samples ReAct) | §4.2, Fig. 5 |
| Compaction threshold sensitivity | Tighter threshold → lower PT, more tool calls, generally higher accuracy | Summary(Length) 32K vs. 48K vs. 64K thresholds on BrowseComp | §4.1, Table 4 |

## Failure Mode / Boundary Conditions

- **Open-source models only:** Closed-source models (GPT-5.4, Claude Opus 4.7) excluded because encrypted reasoning content makes terminal state classification infeasible. Findings may not generalize to closed models. (§5 Limitations)
- **Deep search tasks only:** Findings may not generalize to other long-horizon agentic domains (software development, multi-step planning). (§5 Limitations)
- **Method selection is model-dependent:** FoldAgent outperforms all other methods for strong-agentic models but underperforms passive methods for weaker models. No single context management method dominates across model families. (§4.1, Table 3)
- **Context management trades cost for accuracy:** All context management methods increase tool call count substantially (21.7→40.5–57.7 for BrowseComp). The test-time scaling framing makes this cost explicit. (§4.1, Table 3)
- **Compaction threshold is dataset-dependent:** Threshold set at 96K for BrowseComp-Plus, 32K for BrowseComp and xbench-DeepSearch — suggests optimal threshold must be tuned per deployment context. (§4.1)
- **Behavior-aware filtering: no-confident-answer fallback degrades gains:** When all 8 trajectories end in GU or UI, the fallback to unfiltered set partially cancels the benefit of filtering. (§4.2)

## Decision Knowledge

| Design choice | Cue that motivated it | When it stops applying | Newcomer trap |
|---|---|---|---|
| Struggle score as semantic trigger for compaction | Length and turn-count triggers are insensitive to whether the model is actually stuck; struggle score (% steps with repeated failed attempts) captures trajectory semantics (§4.1) | When the struggle judge itself is unreliable or too slow to compute per step | Assuming length is a reliable proxy for model difficulty — it is a proxy for context volume, not struggle |
| Sub-agent isolation for strong-agentic models | Strong models can direct sub-agents reliably; isolation reduces peak context without degrading planning (§4.1 finding 2) | When the backbone model cannot reliably issue sub-agent tool calls — FoldAgent collapses for GLM-4.7 | Applying FoldAgent universally; it requires the model to have strong multi-agent orchestration capability |
| Filter GU+UI before parallel aggregation, not after | GU and UI are both highly correlated with incorrect answers regardless of aggregation method; filtering first prevents wrong answers from polluting majority voting (§4.2, Appendix F) | When the premature termination rate is so low that most trajectories reach confident answers (PT already low on xbench-DeepSearch) | Treating all terminal states as equally weighted candidates for aggregation |
| Control for query difficulty in correlation analysis | PT rate rises as trajectories get longer — but longer trajectories may simply be harder queries; the ranking-within-query design holds query set fixed while varying length (§3.3, Fig. 4) | N/A — methodological design, always valid | Concluding that harder queries explain PT without isolating length as a variable |

## Not Stated in Source

- No evaluation of whether premature termination patterns differ by domain (medical, legal, technical search vs. general web). The three benchmarks are all general web/research tasks.
- The struggle score judge (LLM-as-judge per step) adds latency and cost per interaction turn; no measurement of this overhead relative to the compaction savings.
- No analysis of whether premature termination is a training artifact (e.g., models trained on short-context RLHF data default to uncertainty hedging) vs. a fundamental long-context phenomenon. This matters for whether fine-tuning could reduce PT rates without inference-time interventions.
- FoldAgent's sub-agent context isolation: the sub-agents themselves may encounter context rot on their assigned subtasks. Whether sub-agent PT is measured is not stated.
- Behavior-aware filtering uses exact match for answer equivalence in majority voting — may underperform on open-ended or long-form answers where surface form varies.

## Relations

- Cluster: [[retrieval-and-context]]
- Cluster: [[agents-and-memory]]
- Operationalizes: [[prompts-to-multi-agent-architecture]] (Vishnyakova 2026 named context rot and listed four failure modes including "confusion" and "distraction"; this paper empirically studies premature termination, a specific manifestation of context rot in agentic search, and provides quantitative characterization Vishnyakova did not)
- Complements: [[context-engineering-survey]] (Mei 2025 defines context engineering formally and identifies comprehension-generation gap; this paper provides empirical evidence for one mechanism causing the gap in deep search — premature termination under extensive context)
- Complements: [[longllmlingua-prompt-compression]] (LongLLMLingua compresses context at the token level to reduce length; this paper reveals that reducing peak context length reduces premature termination — the two approaches are compatible and attack the same root cause from different layers)
- Complements: [[focused-transformer-context-scaling]] (FoT addresses distraction in memory attention; this paper addresses premature termination in agentic search — both concern model behavior under long context but at different architectural levels)
- Authored by: Pengfei Liu (last author), who also authored [[prompts-to-multi-agent-architecture]] as Qishuo Hua et al.'s institution (SII/GAIR) — same research group
