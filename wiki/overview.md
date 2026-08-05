# Overview

**Start here.** This is the field map at low resolution - 19 papers, 2022-2026, covering the core infrastructure questions of large language model systems.

For the full paper catalog go to [[index]]. For term definitions go to [[glossary]].

---

## Directory guide

| Folder | Contains | Use it when |
|---|---|---|
| `wiki/` | One note per paper. Dense, flat, scannable. | Looking up what a specific paper says. |
| `raw/` | Source PDFs. Gitignored. | Reading the original document in Obsidian. |
| `concepts/` | Cross-paper entities and methods. One page per concept. | A term appears in multiple papers and deserves a single canonical page. |
| `topics/` | Explanation and tutorial. Friction preserved for learning. | You want to understand a topic, not just look something up. |
| `open/` | Contradictions and unresolved tensions. Never resolved in-place. | Two papers conflict, or an assumption goes untested across the corpus. |
| `decisions/` | Your own conclusions and reasoning. | You've decided something that exists nowhere in the source papers. |

Root files: [[index]] (catalog), [[glossary]] (terms), [[log]] (ingest history), [[CLAUDE]] (how this wiki works).

---

## What this corpus is about

These papers cluster around a single underlying question: **how do you build reliable, efficient, capable systems on top of LLMs?** The individual topics - retrieval, memory, routing, prompting, context, agents - are all engineering answers to different facets of that question.

---

## Five clusters

**1. Retrieval and context management**
How do you get the right information into the context window at the right time? Covers dense retrieval ([[zero-shot-dense-retrieval]]), prompt compression ([[longllmlingua-prompt-compression]]), long-context transformers ([[focused-transformer-context-scaling]]), and the emerging discipline of context engineering ([[context-engineering-survey]], [[context-of-context-engineering]], [[prompts-to-multi-agent-architecture]]).

**2. Prompt optimization**
How do you find good prompts without hand-tuning? Covers automatic prompt engineering ([[prompt-engineering-a-prompt-engineer]], [[automatic-prompt-optimization-survey]]) and causal approaches to prompt selection ([[causal-prompt-optimization]]).

**3. Inference efficiency and routing**
How do you use the right model for each query without paying for the strongest one every time? Covers LLM routing ([[universal-model-routing]], [[llm-routing-cascading-survey]]), local-cloud collaboration ([[minions-device-cloud-collaboration]], [[on-device-cloud-collaborative-reasoning]]), edge deployment ([[cloud-device-collaborative-learning]]), and multimodal token efficiency ([[image-prompt-packaging]]).

**4. Agents and memory**
How do agents accumulate knowledge, plan, and self-improve across turns? Covers verbal reinforcement learning ([[reflexion-verbal-reinforcement-learning]]), generative agents with multi-tier memory ([[generative-agents-human-simulacra]]), and multi-agent scientific discovery ([[ai-co-scientist-discovery]], [[alphaevolve-coding-agent]]).

**5. Evaluation and limits**
Each cluster has open questions about what evaluation actually measures. Agent results are scaffold-sensitive; routing benchmarks assume static model pools; prompt optimization results are dataset-specific. The [[glossary]] captures the key terms; open questions belong in `open/`.

---

## Timeline sketch

| Period | Dominant concern |
|---|---|
| 2022-2023 | Foundations: dense retrieval, agent memory, long-context, basic prompting |
| 2024-2025 | Scale and efficiency: routing, local-cloud split, prompt compression, multi-agent |
| 2025-2026 | Synthesis: context engineering as a discipline, cost-quality tradeoffs, enterprise deployment |

---

## What is not here

This corpus does not cover: training and fine-tuning methods, safety and alignment, vision-language model architectures, or hardware-level inference optimization. The 19 papers are all systems-level work assuming capable base models exist.
