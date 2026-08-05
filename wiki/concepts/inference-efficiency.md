---
title: Inference Efficiency and Routing
type: reference
audience: both
created: 2026-08-05
verified: 2026-08-05
confidence: VERIFIED
tags: [inference-efficiency, LLM-routing, cascading, local-remote, cost-quality-tradeoff]
---

# Inference Efficiency and Routing

How do you use the right model for each query without paying for the strongest one every time? This cluster covers routing, cascading, local-cloud splits, and token-level efficiency.

## Papers in this cluster

| Paper | Contribution |
|---|---|
| [[universal-model-routing]] | UniRoute: routing across a dynamic LLM pool where new models appear at test time, without router retraining. |
| [[llm-routing-cascading-survey]] | Survey of 6 routing paradigms and the routing vs cascading distinction; 3-dimensional design space. |
| [[minions-device-cloud-collaboration]] | Protocol for decomposing long-context tasks across local (cheap) and cloud (capable) models. |
| [[on-device-cloud-collaborative-reasoning]] | GAPG: RL-trained routing policy for on-device/cloud split, with post-training on the device model. |
| [[cloud-device-collaborative-learning]] | CD-CCA: knowledge distillation from cloud MLLMs to edge devices with continual adaptation. |
| [[image-prompt-packaging]] | IPPg: routes text prompts through the vision tokenization channel to reduce text token cost. |

## Key tension

Routing optimizes which model handles a query; cascading optimizes whether to escalate after seeing the cheap model's output. The survey shows these are often conflated in practice. A deeper tension: methods that improve cost-quality tradeoff on benchmarks may not generalize to production distributions, where query difficulty is correlated with domain in ways that training sets don't capture.

## Related clusters

- [[retrieval-and-context]] — context size is the primary driver of inference cost
- [[agents-and-memory]] — multi-agent systems amplify per-query cost nonlinearly
