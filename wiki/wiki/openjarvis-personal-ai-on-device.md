---
title: "OpenJarvis: Personal AI, On Personal Devices"
type: reference
audience: both
created: 2026-08-06
verified: 2026-08-06
confidence: VERIFIED
sources: [arxiv:2605.17172]
supersedes: []
superseded_by: []
expires_when: "A local-only architecture matches frontier cloud accuracy on GAIA and DeepResearchBench without search-time cloud calls, or prompt/weight optimization alone closes the remaining 3.2pp local-cloud gap."
tags: [local-ai, inference-efficiency, agents, on-device, spec-optimization, local-cloud-collaboration, personal-ai]
---

# OpenJarvis: Personal AI, On Personal Devices

Jon Saad-Falcon*, Avanika Narayan*, Robby Manihani, Tanvir Bhathal, Herumb Shandilya, Hakki Orhun Akengin, Gabriel Bo, Andrew Park, Matthew Hart, Caia Costello, Chuan Li, Christopher Ré, Azalia Mirhoseini. Stanford University / Lambda Labs. arXiv:2605.17172. May 2026. (*equal contribution)

## Claim

Personal AI stacks cannot be made local by simply replacing the cloud model — the surrounding agent framework must be decomposed into independently optimizable primitives and re-targeted around the local model. A five-primitive spec abstraction plus LLM-guided spec search closes 56–77% of the accuracy drop from cloud-to-local substitution, landing within 3.2pp of the best cloud baseline at 800× lower marginal API cost and 4× lower latency. (§1, §4.2–4.3)

## Method / Core Mechanism

**Two core components (§3):**

**1. The spec abstraction (§3.1)** — a typed configuration object composing five primitives:
- *Intelligence* — model weights, architecture, generation parameters
- *Engine* — inference runtime, quantization, KV-cache, batching
- *Agents* — reasoning loop, prompts, tool-use policy
- *Tools & Memory* — external interfaces, retrieval, persistent user state
- *Learning* — the optimizer that updates all other primitives from traces (LoRA, DSPy, LLM-guided spec search)

Each primitive is independently swappable. Prior stacks (OpenClaw, Hermes Agent, LangChain, CrewAI) fuse all five around one intended cloud model; substituting a local model breaks all assumptions at once. The spec exposes these as degrees of freedom in one optimizable object.

**2. LLM-guided spec search (§3.3, Algorithm 1)** — a local–cloud search loop at *search time only*:
1. A frontier cloud model reads failure traces from the current local spec
2. Groups failures into clusters by failure mode with natural-language characterization
3. Proposes coordinated edits across Intelligence, Engine, Agents, and Tools & Memory
4. An acceptance gate keeps only edits that improve the targeted failure cluster without regressing others by more than ε=1%
5. Resulting spec runs entirely on-device at inference time — zero cloud calls

*Learning* is the only primitive not directly edited by search; it IS the optimizer.

**Evaluation (§4.1):** 8 benchmarks (PinchBench, GAIA, LiveCodeBench, LiveResearchBench, τ-Bench V2, τ²-Bench Telecom, DeepResearchBench, ToolCall-15), 11 local models from 4 families, 3 cloud baselines, 7 hardware platforms, 508 tasks, 5 independent runs each.

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| Spec closes cloud-local drop | 56–77% of accuracy gap recovered | OpenClaw + Hermes Agent, Qwen3.5-9B substituted for Claude Opus 4.6 | §4.2, Table 1 |
| Best local vs. best cloud | 80.3% vs. 83.5% (3.2pp gap) | Qwen3.5-122B vs. Claude Opus 4.6, avg over 8 benchmarks | §4.3, Table 5 |
| Local matches/exceeds cloud | 4 of 8 benchmarks | ToolCall-15, PinchBench, LiveCodeBench, τ-Bench V2 | §4.3 |
| Cost advantage | ~800× lower marginal API cost | Local spec vs. cloud; hardware/electricity accounted separately | §4.3, Fig. 5 |
| Latency advantage | ~4× lower end-to-end latency | Full agentic workloads; single-shot prompts favor cloud on TTFT | §4.3 |
| LLM-guided spec search gap closure | 13–32pp improvement over unoptimized local spec | Averaged over student models across 8 benchmarks | §4.4, Table 9 |
| Search cost advantage | 7.1–10.9× cheaper than single-primitive baselines | Vs. LoRA (strongest single-primitive baseline) | §4.4, Fig. 7 |
| Edit distribution | 16–44% Intelligence, remainder across Engine/Agent/Tool | Task-dependent: Intelligence dominates code, Agent dominates agentic tasks, Tool dominates research | §4.4, Table 10 |

## Failure Mode / Boundary Conditions

- **Cloud required at search time:** LLM-guided spec search sends user traces to a frontier model to propose edits. Privacy risk for sensitive data is not evaluated. Protocol for trace eligibility is in Appendix A.3. (§5)
- **Not pure on-device end-to-end:** only inference runs locally. Search-time cloud calls are amortized — at 100 queries/day, proposer cost falls below $0.001/query within six months. (§5, Appendix C.2)
- **GAIA and reasoning-heavy tasks remain hard:** the largest remaining gaps are on GAIA, τ²-Bench Telecom, and DeepResearchBench, where deep-reasoning demands exceed what local model capacity can deliver regardless of configuration. (§4.2)
- **Single-machine evaluation only:** no multi-device deployment (e.g., phone offloading to local server). Latency numbers are protocol-specific. (Appendix D)
- **Statistical precision:** 5 runs per configuration; GPT-5-mini as judge introduces potential judge bias. (§5, Appendix D)
- **Prompt-only optimization plateaus at +5pp:** state-of-the-art prompt optimizers (GEPA, DSPy/SIMBA) close only 4.1–5.2pp of the gap; the four-primitive spec is necessary to reach 13–32pp gains. (§4.4)

## Decision Knowledge

| Design choice | Cue that motivated it | When it stops applying | Newcomer trap |
|---|---|---|---|
| Cloud at search time, local at inference time | Frontier models excel at reading traces and reasoning about coordinated edits; local hardware excels at low-latency inference. Capability transfers through the spec and stays there. (§5) | When local models can read their own failure traces and propose cross-primitive edits reliably | Assuming "local AI" means no cloud ever; the division of labor is temporal, not architectural |
| Gate with ε=1% regression tolerance | Prevents capability regression on non-targeted tasks when an edit improves one failure cluster (§3.3) | When the task suite is fully covered by targeted clusters | Treating the gate as validation — it is a non-regression guard, not accuracy measurement |
| Four editable primitives (not all five) | Learning IS the optimizer slot; it makes no sense to optimize the optimizer with itself. The other four are the space of configurations to search. (§3.1) | N/A — structural constraint | Expecting Learning to be a search target; it is the search algorithm |
| Diagnose before propose | Without failure clustering, edit proposals are blind; with clustering, the teacher maps each failure to the primitive where intervention is most likely to help (§3.3, Fig. 11) | When failures are not separable by primitive (rare in practice per Table 10) | Assuming reflection without failure classification is equivalent — evolutionary spec search at same move space scores 10pp lower (§4.4, Fig. 8) |
| Non-regressing greedy accept (not population-based) | Gate cost grows with population size; greedy acceptance with a rollback is sufficient when edit proposals are already high-quality from the LLM proposer (§3.3, Algorithm 1 vs. 2) | When edit quality is low and population diversity matters for escaping local optima | Expecting evolutionary search to be needed; it is only 5.5–18pp worse than LLM-guided at the same four-primitive move space |

## Not Stated in Source

- No quantification of privacy risk from traces sent to cloud at search time. The protocol limits which traces are eligible (Appendix A.3) but does not measure whether sensitive personal data leaks through failure traces.
- What happens when the frontier proposer model is updated or deprecated? The optimized local spec was searched against one cloud model's proposals; re-searching against a new proposer may be required.
- Long-term adaptation: the spec optimizes on the user's historical traces, but user behavior and task distributions evolve. No evaluation of spec drift over months of use.
- Gate tolerance ε=1% is a fixed default with no ablation. Tighter gates may stall improvement; looser gates may cause capability regression.
- No non-English benchmark evaluation. Personal AI for multilingual or code-switching users is not studied.
- Energy measured via vendor APIs for local hardware — these estimates vary in accuracy by hardware generation.

## Relations

- Cluster: [[inference-efficiency]]
- Cluster: [[agents-and-memory]]
- Extends: [[minions-device-cloud-collaboration]] (Minions decomposes tasks across local and cloud at inference time but does not update any primitive; OpenJarvis extends this by making the full stack optimizable and moving cloud involvement to search time only — cited as [58] in §3.3)
- Complements: [[on-device-cloud-collaborative-reasoning]] (GAPG trains intrinsic routing via RL so the on-device model decides when to escalate; OpenJarvis optimizes the surrounding stack; both address local-cloud efficiency from different layers)
- Complements: [[universal-model-routing]] (UniRoute selects among models at query time; OpenJarvis selects and configures the local model at search time; different optimization horizons)
- Complements: [[prompt-engineering-a-prompt-engineer]] and [[causal-prompt-optimization]] (prompt optimization is one of four primitives in OpenJarvis's editable set; the spec generalizes beyond prompts alone)
