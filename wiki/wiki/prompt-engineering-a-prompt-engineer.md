---
title: Prompt Engineering a Prompt Engineer (PE2)
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2311.05661]
supersedes: []
superseded_by: []
expires_when: "A method without meta-prompt engineering consistently matches PE2 on counterfactual tasks, or LLMs become insensitive enough to prompt phrasing that automatic prompt optimization yields <1% gains on standard benchmarks"
tags: [prompt-optimization, automatic-prompt-engineering, meta-prompting, reasoning, LLM]
---

# Prompt Engineering a Prompt Engineer (PE2)

Qinyuan Ye, Maxamed Axmed, Reid Pryzant, Fereshte Khani. University of Southern California / Microsoft. arXiv:2311.05661v3 (2024).

## Claim

Prior automatic prompt engineering methods (Iterative APE, APO) use meta-prompts that give insufficient guidance for the complex reasoning required to inspect failures, hypothesize what is wrong, and propose targeted fixes. PE2 addresses this by infusing three components into the meta-prompt: a detailed two-step task description, context specification, and a step-by-step reasoning template. The resulting method consistently outperforms Iterative APE and APO across math reasoning, instruction induction, BIG-bench Hard, counterfactual tasks, and a production prompt with 5000+ tokens. (§1, §5.1)

## Method

PE2 operates as a meta-prompted LLM prompt optimizer (§3):

**Framework** (§2.2): At timestamp t, a prompt proposal model Mproposal is given the current prompt p(t) and a batch B of failure examples, then proposes p(t+1). A search procedure selects n=4 best-performing prompts from all prior candidates, generates m=4 proposals from each, and uses backtracking across all timestamps (not just the latest). Hard negative sampling: batch B is sampled from the task model's errors, not random training examples.

**Three meta-prompt components** (§3, Fig. 3):

1. **Two-step task description** - APO gives brief instructions on-the-fly; PE2 declares the two-step structure upfront ("Step 1: Examine the prompt and batch. Step 2: Propose a new prompt.") and clarifies expectations for each step. Targets the LLM's need for upfront orientation before executing a complex multi-step task.

2. **Context specification** - Shows the LLM exactly how the prompt appears in context with the input text (e.g., a template like `Question: <input>\nAnswer: <prompt>`). Prevents proposing prompts that are incoherent with the actual input format.

3. **Step-by-step reasoning template** - A structured list of questions per example: Is the output correct? Is it necessary to edit the prompt? If yes, what are actionable suggestions? Forces explicit per-failure analysis before proposing the new prompt.

**Default setup**: GPT-4 as Mproposal; text-davinci-003 as Mtask. T=3 optimization steps. Initialization: "Let's think step by step" for math/BIG-bench; induction initialization (generate from examples) for Instruction Induction. Also demonstrated with Mistral-7B-Instruct-v0.2 as Mtask.

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| MultiArith accuracy | 92.3% (+6.3% vs Zero-shot CoT) | TD003 task model, GPT-4 proposal model | §5.1, Table 2 |
| GSM8K accuracy | 64.0% (+3.1% vs Zero-shot CoT) | TD003 task model, GPT-4 proposal model | §5.1, Table 2 |
| Counterfactual Eval vs APO | +6.9% avg, wins 11/12 tasks | Induction initialization | §5.1, Fig. 2 |
| Production prompt (5000+ tokens) | +8.0% F1 | Expert-written initialization | §5.1, Fig. 2 |
| PE2 vs APO (MultiArith dev) | 92.0% vs 89.0% (PE2 default) | Table 5 | §5.2 |
| Ablation: remove two-step task desc | 89.0% dev (vs 92.0% default) | MultiArith dev | §5.2, Table 5 |
| Ablation: remove reasoning template | 86.0% dev | MultiArith dev | §5.2, Table 5 |
| Ablation: remove context spec | 87.0% dev | MultiArith dev | §5.2, Table 5 |
| Cross-model generalization | No consistent trend | TD003-optimized prompts on mpt-7b, yi-6b, mistral-7b | §A.3 |
| Multi-choice format tasks | Limited improvement | BIG-bench Hard date understanding | §A.2 |
| Recovery from bad initialization | Possible but final prompt worse | Misleading initialization | §A.1 |

## Boundary conditions

- **Optimized prompts are model-specific**: prompts optimized for text-davinci-003 do not consistently transfer to other models. PE2 is model-agnostic as a method, but its outputs are not (§A.3, §5.4).
- **Shortcut learning risk**: on counterfactual tasks (base-8 addition), when not informed of the true rule, PE2 discovers heuristics that are partially correct on test data but do not represent the intended task. A shortcut-learned prompt outperforms the "correct" one (37% vs 17-28%). Prompt optimization inherits the same failure mode as gradient-based optimization (§5.3).
- **Meta-prompt following failures**: PE2 sometimes refuses to edit prompts despite explicit instructions ("the label is absolutely correct"), and hallucinates when given hints (base-80 instead of base-8). Instruction following reliability is a hard ceiling on PE2's effectiveness (§5.3, Table 7).
- **Limited on multi-choice format**: performance gains diminish on multiple-choice tasks; most notable gains on generative format where prompt wording has more leverage (§A.2).
- **Search cost not quantified**: n=4, m=4, T=3 requires n*m*T=48 GPT-4 calls per optimization run, plus task model evaluations. Cost not reported.
- **No comparison to soft-prompt methods**: AutoCompressor, GIST, etc. require model access and are not compared. Baseline scope is black-box APE methods only.
- **Hard negative sampling helps slightly** but not dramatically; backtracking similarly (Table 5, ablations section).

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Two-step description upfront (not on-the-fly) | APO gives brief per-step instructions as the meta-prompt runs; LLMs perform better on complex multi-step tasks when the overall structure is explained before execution (§3a) | APO-style on-the-fly: model performs both steps without clear orientation, leading to lower-quality proposals | Assuming a brief reminder per step is equivalent to upfront structural clarity |
| Step-by-step reasoning template | CoT-inspired: guiding the model to reason through each failure before proposing a fix (§3c; mirrors Chain-of-Thought and Reflexion) | No template: model skips per-example analysis and proposes less targeted edits | Thinking the LLM "already knows" to analyze failures carefully without explicit scaffolding |
| Context specification | Prompts appear in different positions and formats relative to the input; without knowing the layout, the proposal model may write prompts that are syntactically incoherent with the template (§3b) | No context spec: proposed prompts may be contextually correct in isolation but wrong in context | Often overlooked in prompt engineering tooling; the "where does my prompt appear?" question is a practical blocker |
| Hard negative sampling (errors only) | Random batches contain mostly correct examples; error-only batches give the proposal model signal on exactly what the current prompt fails at (§2.2) | Random sampling: batch contains mostly examples the prompt already handles; less signal for targeted edits | Subtle but significant: the quality of failure examples in B determines the quality of the proposed fix |

## Not stated in source

- Total API cost per optimization run not reported.
- No evaluation on code generation (HumanEval/MBPP) - would directly compare to Reflexion which also targets coding.
- Whether PE2 is robust when GPT-4 is both Mproposal and Mtask (potential self-improvement loop) not tested.
- No ablation isolating which meta-prompt component matters most for counterfactual tasks specifically (the strongest result domain).
- The shortcut learning in base-8 addition achieves 37% - not analyzed to know if this represents a genuine generalization or just fitting to the visible test structure.

## Relations
- Cluster: [[prompt-optimization]]

- Supports: [[reflexion-verbal-reinforcement-learning]] (Reflexion uses verbal self-reflection to improve an agent's action policy; PE2 applies the same principle at the prompt level, using failure inspection and verbal feedback to improve the prompt itself - both are forms of verbal optimization)
- Contradicts: -
- Superseded by: -

## Expiry

When LLMs become insensitive enough to prompt phrasing that optimization yields <1% gains across benchmarks, or when a competing black-box method without meta-prompt engineering consistently matches PE2 on counterfactual tasks. Re-verify when: a paper in corpus benchmarks on MultiArith, GSM8K, BIG-bench Hard, or counterfactual arithmetic tasks.
