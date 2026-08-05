---
title: Agents and Memory
type: reference
audience: both
created: 2026-08-05
verified: 2026-08-05
confidence: VERIFIED
tags: [agents, memory, multi-agent, self-improvement, planning, scientific-discovery]
---

# Agents and Memory

How do agents accumulate knowledge, plan over long horizons, and self-improve across turns — without gradient updates? This cluster covers verbal reinforcement, multi-tier memory, and multi-agent orchestration.

## Papers in this cluster

| Paper | Contribution |
|---|---|
| [[reflexion-verbal-reinforcement-learning]] | Verbal RL: agents improve via natural-language self-reflection stored in an episodic memory buffer, without weight updates. |
| [[generative-agents-human-simulacra]] | Multi-tier memory stream (observations + reflections + plans) with recency/importance/relevance retrieval scoring. |
| [[ai-co-scientist-discovery]] | Multi-agent generate-debate-evolve loop for scientific hypothesis generation; Elo-based ranking replaces fixed reward. |
| [[alphaevolve-coding-agent]] | Evolutionary coding agent using LLMs for mutation/crossover over program populations; test-time compute scaling via evolution. |

## Key tension

Reflexion and Generative Agents show that in-context memory and verbal reflection can substitute for weight updates on bounded tasks. Co-Scientist and AlphaEvolve show that at scale, the bottleneck shifts to evaluation (how do you score a hypothesis?) rather than generation. Whether verbal self-improvement degrades on harder tasks — a known critique not yet tested in this corpus — remains open.

## Related clusters

- [[retrieval-and-context]] — agents are the primary consumers of long-context and memory systems
- [[inference-efficiency]] — multi-agent systems amplify per-query cost; orchestration choices determine total spend
