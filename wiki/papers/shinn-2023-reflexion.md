---
title: Reflexion — Language Agents with Verbal Reinforcement Learning
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2303.11366]
supersedes: []
superseded_by: []
expires_when: "Weight-updating methods match Reflexion's pass@1 gains at comparable inference cost, or a method shows verbal self-reflection reliably fails on tasks where Reflexion claims success"
tags: [agents, memory, self-improvement, reinforcement-learning, code-generation, reasoning]
---

# Reflexion: Language Agents with Verbal Reinforcement Learning

Noah Shinn, Federico Cassano, Edward Berman, Ashwin Gopinath, Karthik Narasimhan, Shunyu Yao. Northeastern University / MIT / Princeton. arXiv:2303.11366. March 2023 (v4 October 2023).

## Claim

Language agents can improve through trial and error without weight updates by converting task feedback into verbal self-reflections stored in an episodic memory buffer, which are prepended as context in subsequent trials. (Abstract, §1)

## Method

Three-component architecture (§3, Algorithm 1):

- **Actor (Ma)** - LLM that generates actions or text conditioned on observations + memory. Implementations: ReAct (decision-making, reasoning) or Chain-of-Thought (reasoning only).
- **Evaluator (Me)** - scores Actor output and produces a reward signal. Variants: binary environment reward, hand-written heuristic, LLM-as-judge, or self-generated unit tests (code tasks).
- **Self-Reflection model (Msr)** - LLM that receives {trajectory, reward} and produces a verbal summary of what went wrong and what to do differently. Stored in long-term memory mem.

Memory structure: short-term = current trajectory; long-term = sliding window of Ω self-reflections (Ω typically 1-3, bounded by context length). (§3)

Loop: generate trajectory → evaluate → reflect → append reflection to mem → reset environment → next trial. Continues until Evaluator passes or max trials reached. (§3, Algorithm 1)

Task-specific implementations:
- **AlfWorld** (decision-making): ReAct actor; heuristic evaluator (stuck-loop or >30 actions triggers reflection); GPT-3. (§4.1)
- **HotPotQA** (reasoning): CoT or ReAct actor; exact-match grading; memory size 3; GPT-3.5/GPT-4. (§4.2)
- **HumanEval/MBPP** (programming): self-generated unit tests (via CoT, max 6, syntax-validated via AST) as evaluator; memory size 1; GPT-4. (§4.3)

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| AlfWorld: Reflexion vs. ReAct-only | 130/134 tasks solved (vs. ~113) | Heuristic evaluator, GPT-3, 12 trials | §4.1, Fig. 3 |
| AlfWorld improvement over baseline | +22% absolute | Over 12 iterative learning steps | §4.1 |
| HotPotQA: Reflexion vs. all baselines | +20% absolute | CoT + Reflexion, 100 questions | §4.2 |
| Self-reflection vs. episodic memory alone (HotPotQA) | +8% absolute boost from reflection step | CoT (GT) setup | §4.2, Fig. 4c |
| HumanEval Python: pass@1 | 91.0% vs. 80.1% (GPT-4 SOTA) | GPT-4 + Reflexion, self-generated unit tests | Table 1 |
| HumanEval Rust: pass@1 | 68.0% vs. 60.0% (GPT-4) | 50 hardest problems translated via MultiPL-E | Table 1 |
| MBPP Python: pass@1 | 77.1% vs. 80.1% (GPT-4) | Underperforms GPT-4 baseline | Table 1 |
| LeetcodeHard Python: pass@1 | 15.0% vs. 7.5% (GPT-4) | 40 post-Oct-2022 problems, GPT-4 | Table 1 |
| Ablation: test generation only, no self-reflection | 52% vs. 60% baseline | HumanEval Rust hardest 50 | Table 3 |
| Ablation: self-reflection only, no test generation | 60% = baseline | HumanEval Rust hardest 50 | Table 3 |
| Reflexion on weak model (starchat-beta) | 0.26 → 0.26 (no gain) | HumanEval Python, avg over 8 trials | Appendix A, Table 4 |

## Boundary conditions

- **Requires strong base LLM**: self-correction is an emergent property of larger models. starchat-beta (7B) showed zero gain from Reflexion. Performance gain increases with model capability (Appendix A, Tables 4-5).
- **Local minima**: verbal RL can converge to non-optimal policies with no escape mechanism; no formal guarantee of success (§5).
- **Memory context bound**: sliding window of 1-3 reflections; long trajectories hit context limits. More advanced memory (vector DB, SQL) not explored (§5).
- **Tasks requiring exploration diversity fail**: WebShop (e-commerce) showed no improvement after 4 trials; agent could not generate useful reflections for tasks requiring creative, diverse search strategies (Appendix B.1).
- **Code-specific limits**: test-driven evaluation fails for non-deterministic functions, impure functions calling APIs, hardware-dependent outputs, and concurrent code (§5).
- **False positives corrupt the loop**: a flawed test suite that passes on wrong code causes premature success reporting. MBPP Python underperformance attributed to 16.3% false-positive test rate vs. 1.4% for HumanEval (§4.3, Table 2).
- **Self-evaluation dependency**: Evaluator quality gates everything. Binary environment rewards (AlfWorld) are reliable; LLM-as-evaluator quality is bounded by the LLM's ability to assess its own outputs (§1, §3).

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Verbal feedback instead of scalar reward | Scalar reward is too sparse for credit assignment in language tasks; verbal feedback specifies which action was wrong and what to substitute (§1, §3) | Falls back to random retry with no learning signal | Thinking the self-reflection must be correct - it only needs to be directionally useful |
| Episodic memory buffer (not raw trajectory replay) | Distills long failed trajectories into compact lessons; raw trajectories exceed context limits (§3, §4.1) | Context fills with raw history; agent cannot fit prior experience | Memory is bounded to Ω=1-3 not for quality reasons but for context length reasons |
| Self-generated unit tests as evaluator (code) | Code execution is a ground-truth oracle that does not require human labels; enables pass@1 eligibility (§4.3) | Must rely on ground truth test cases, invalidating pass@1 | The test suite itself can fail: false positives corrupt the loop (§4.3, Table 2) |
| Heuristic evaluator (AlfWorld: loop detection, step limit) | Binary environment reward alone is too sparse; LLM-as-evaluator adds latency and cost; heuristics capture known failure modes cheaply (§4.1) | Agent loops indefinitely or completes without knowing failure | [not stated in source]: why exactly 30-step limit chosen |
| Max Ω=1 for programming, Ω=3 for others | Programming tasks have longer trajectories + unit test outputs consuming context; decision-making and reasoning reflections are shorter (§4.1, §4.3) | [not stated in source] | Assuming Ω is a quality parameter - it is a context budget parameter |

## Not stated in source

- No ablation of Ω (memory size) beyond comparing to episodic memory without reflection. Optimal Ω per task type unknown.
- Temperature settings used for reflection generation not specified.
- Cost analysis absent: each Reflexion trial requires multiple LLM calls (Actor + Evaluator + Self-Reflection). Pass@1 gains should be compared against cost of N independent samples.
- Self-Reflection model is the same model as Actor in all experiments. Whether a separate, specialized reflection model helps is not studied.
- WebShop failure is documented but not fully explained - it is unclear whether the failure is from inadequate exploration, poor reflection quality, or both.
- No analysis of reflection quality degradation across trials - do later reflections become less useful?

## Relations

- Supports: - (no contradicting papers yet in corpus; see [[glossary]] for verbal reinforcement learning)
- Contradicts: - (potential conflict with self-correction critique papers not yet in corpus)
- Superseded by: -

## Expiry

When a paper shows verbal self-reflection fails on the same tasks (AlfWorld, HumanEval) at equivalent model scale, or when weight-updating agents match 91% HumanEval pass@1 at lower inference cost. Re-verify when: any paper in the corpus reports on self-correction reliability.
