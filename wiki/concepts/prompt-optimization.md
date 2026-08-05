---
title: Prompt Optimization
type: reference
audience: both
created: 2026-08-05
verified: 2026-08-05
confidence: VERIFIED
tags: [prompt-optimization, automatic-prompt-engineering, meta-prompting, causal-inference]
---

# Prompt Optimization

How do you find good prompts systematically, without hand-tuning? This cluster covers automatic and causal approaches to prompt search and selection.

## Papers in this cluster

| Paper | Contribution |
|---|---|
| [[prompt-engineering-a-prompt-engineer]] | PE2: two-step meta-prompt (task description + per-example reasoning template) that outperforms iterative APE. |
| [[automatic-prompt-optimization-survey]] | Taxonomy of automatic prompt optimization across 50+ methods: discrete vs continuous, black-box vs white-box, static vs dynamic. |
| [[causal-prompt-optimization]] | CPO: uses Double Machine Learning to estimate the causal effect of each prompt on performance, isolating prompt contribution from query difficulty. |

## Key tension

Most APE methods optimize for average performance across a fixed eval set — they find prompts that work well on average but may be wrong for specific query types. CPO addresses this via query-adaptive selection; the survey maps how widespread this limitation is. Whether causal methods generalize beyond the benchmarks tested remains open.

## Related clusters

- [[retrieval-and-context]] — prompts are assembled from context components
- [[inference-efficiency]] — prompt length directly affects cost
