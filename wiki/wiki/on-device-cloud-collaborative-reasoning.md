---
title: "Bridging On-Device and Cloud LLMs for Collaborative Reasoning: A Unified Methodology for Local Routing and Post-Training"
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2509.24050]
supersedes: []
superseded_by: []
expires_when: "Results are on 1-3B parameter models with DeepSeek-R1 as cloud model. Re-evaluate when: significantly stronger on-device models make cloud routing less necessary, or when the MinionS-style external protocol approach is shown to match RL-trained intrinsic routing."
tags: [local-remote, inference-efficiency, reinforcement-learning, routing, on-device, post-training]
---

# Bridging On-Device and Cloud LLMs for Collaborative Reasoning

Wenzhi Fang, Dong-Jun Han, Liangqi Yuan, Evan Chen, Christopher G. Brinton (Purdue University, Yonsei University). ICML 2026 (arXiv:2509.24050v4, 2026).

## Claim

Existing device-cloud collaboration systems rely on external binary classifiers as routers, trained on surface-level prompt features after on-device fine-tuning. These routers (1) cannot judge reasoning difficulty from prompt features alone, (2) are trained in a decoupled, two-stage pipeline ignoring joint optimization potential. This paper trains the on-device LLM itself to intrinsically decide when to invoke cloud assistance via RL-based post-training, eliminating the external router. The proposed GAPG (Group-Adaptive Policy Gradient) algorithm jointly optimizes local reasoning and cloud coordination under a usage budget constraint. (§1, §2.2)

## Method

**Setting**: On-device model πθ (1-3B parameters) + cloud model πc (DeepSeek-R1). The on-device model either solves a prompt locally or, at inference time, outputs a special token (`<unknown> I need external assistance </unknown>`) to invoke the cloud. The cloud then appends its response. The on-device model is updated; the cloud model is fixed and deterministic.

**Optimization problem** (§3.1):
```
max_θ E_x[R(θ,x)] := E_x E_yθ~πθ(x) [r(x,y)]
subject to E[1{y~(πθ,πc)}] ≤ ρ · E[1{y~πθ}]
```
The constraint bounds the cloud-invocation-to-local ratio; ρ=30% in experiments.

**Hierarchical reward** (§3.2): two mutually exclusive rewards per response:
- Accuracy reward αa: correct answer produced locally by πθ alone.
- Coordination reward αc: on-device calls for help AND cloud produces correct answer.
- Always αa > αc to prioritize local problem solving over cloud delegation.

**GAPG algorithm** (§3.3):

1. *Group-level policy gradient*: Sample G responses per prompt. Baseline is group mean reward r̄. Gradient estimator:
   ```
   ∇θR(θ,x) = (1/(G-1)) Σ_i ∇θ log πθ(yiθ|x) * (ri - r̄)
   ```
   Provably unbiased (Proposition 3.1) with variance O(1/G) — lower variance than single-sample REINFORCE.

2. *Adaptive prompt filtering*: Prevents policy collapse (exclusive-local or exclusive-cloud) by selecting two complementary prompt subsets per batch:
   - Db1: prompts where ≥1 of G on-device responses is correct (trains local solving).
   - Db2: prompts where all on-device responses fail but cloud succeeds (trains call-for-help). |Db2| ≤ ρ|Db1|, inheriting the budget constraint.
   - Update is over Db1 ∪ Db2, so the model always receives balanced signals.

## Experimental Setup

- **On-device models**: Qwen2.5-3B-Instruct (Countdown task), Llama-3.2-1B, Qwen2.5-1.5B, Llama-3.2-3B (MATH benchmarks).
- **Cloud model**: DeepSeek-R1 (fixed).
- **Datasets**: Countdown (symbolic reasoning), MATH-lighteval; generalization to MATH-500, AMC23, MinervaMath, AGI-Eval-Math.
- **Cloud budget**: 30% call-for-cloud ratio.

## Results

**Countdown (Qwen2.5-3B)**:
- GAPG approaches cloud LLM accuracy with only 30% cloud calls; improves ~30% accuracy over Task-Tuning Only.
- Converges to higher reward than all baselines; consistently outperforms even Collaboration-Aware Tuning (hierarchical rewards applied to Dr.GRPO, without adaptive filtering).

**MATH benchmarks (Table 1, Overall Accuracy)**:

| Method | Avg (Qwen2.5-1.5B) | Avg (Llama-3.2-3B) |
|---|---|---|
| Task-Tuning Only (no cloud) | 56.1% | 51.2% |
| Task-Tuning & Naive Offloading | 67.2% | 65.1% |
| Collaboration-Aware Tuning | 61.5% | 66.8% |
| Task-Tuning & Router (DeBERTa) | 70.9% | 69.4% |
| **GAPG (Ours)** | **80.4%** | **79.5%** |
| Cloud LLM (upper bound) | 93.8% | 93.8% |

- GAPG consistently outperforms all baselines across all five benchmarks and both model sizes.
- Early-stage convergence is slower (explicit balance between local and cloud optimization), but long-term accuracy surpasses baselines that converge faster.

## Boundary Conditions

- **Verifiable reward tasks only**: Method requires a rule-based correctness signal (exact match or formal check). Open-ended generation tasks without verifiable answers require LLM-as-judge rewards — not addressed. (§Limitations)
- **On-device model scale**: Evaluated on 1-3B models. Whether intrinsic routing ability generalizes to larger on-device models (7B+) is not tested.
- **Cloud model is fixed and deterministic**: Training assumes πc is fixed. Switching cloud models at inference is studied in Appendix A.7 (robustness analysis) but not the focus.
- **Single call-for-help per prompt**: The on-device LLM can invoke the cloud at most once per prompt (end of local generation). Mid-generation or iterative cloud consultation is not supported.

## Decision Knowledge

- The key insight over prior work: external routers fail on reasoning tasks because surface-level prompt features don't reveal difficulty — two structurally similar prompts can differ dramatically in hardness. Training the model itself to discover its own limitations via RL avoids this structural failure.
- Adaptive prompt filtering (Db1 ∪ Db2) is the mechanism preventing the two failure modes. Without it, the model collapses to one extreme (exclusively local or exclusively cloud-calling). The ratio |Db2| ≤ ρ|Db1| directly inherits the budget constraint from the optimization problem, making the filtering theoretically grounded.
- αa > αc ordering in rewards is critical: without it, the model learns to always call for cloud help (coordination reward is easier to achieve than local correctness).

## Not Stated in Source

- Token cost of training (number of cloud LLM calls during training) is deferred to Appendix A.2; main paper doesn't quantify total training cost.
- The `<unknown> I need external assistance </unknown>` generation format is a design choice — no ablation on alternative signaling formats (e.g., confidence scores, dedicated tokens).
- The cloud model (DeepSeek-R1) has significantly more parameters than the on-device models; the performance gap is partly a function of this size difference, not just local vs cloud deployment.

## Relations
- Cluster: [[inference-efficiency]]

- Contrasts: [[minions-device-cloud-collaboration]] (both address local-remote collaboration for inference efficiency; MinionS uses an external protocol with task decomposition and code generation — on-device model weights unchanged; GAPG trains intrinsic routing via RL — on-device weights change; the two are complementary approaches to the same problem)
- Contrasts: [[universal-model-routing]] (UniRoute trains an external router to select from a pool of LLMs; GAPG eliminates the external router by training the on-device LLM itself to recognize its limitations)
- Contradicts: -
- Superseded by: -
