---
title: AlphaEvolve: A Coding Agent for Scientific and Algorithmic Discovery
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2506.13131]
supersedes: []
superseded_by: []
expires_when: "Benchmark results (matrix multiplication records) may be surpassed by future methods. Infrastructure deployment claims are point-in-time. Re-evaluate when a successor from Google DeepMind supersedes AlphaEvolve explicitly."
tags: [evolutionary-coding, LLM-agents, algorithm-discovery, optimization, test-time-compute, scientific-discovery]
---

# AlphaEvolve: A Coding Agent for Scientific and Algorithmic Discovery

Alexander Novikov*, Ngan Vu*, Marvin Eisenberger*, Emilien Dupont*, Po-Sen Huang*, Adam Zsolt Wagner*, et al. (equal contributions). Google DeepMind. arXiv:2506.13131v1 (2025).

## Claim

AlphaEvolve is an evolutionary coding agent that combines SOTA LLMs (Gemini 2.0 Flash + Pro ensemble) with automated evaluation metrics to iteratively discover and improve algorithms. It substantially extends FunSearch (Romera-Paredes et al. 2023), which evolved single Python functions using small code LLMs, to evolve entire codebases in any language with rich natural language context. Key result: first improvement to Strassen's algorithm for 4×4 complex matrix multiplication in 56 years (48 vs 49 scalar multiplications). Deployed in Google production infrastructure with measurable compute efficiency gains. (§1 Introduction, §6 Discussion)

## Architecture

**Five components** (§2 AlphaEvolve):

1. **Task specification**: User marks blocks with `# EVOLVE-BLOCK-START` / `# EVOLVE-BLOCK-END` in an existing codebase. User provides an `evaluate()` Python function returning a dict of scalar metrics (maximized by convention). The initial marked code is the starting solution; surrounding skeleton code remains fixed. Supports multi-objective optimization.

2. **Prompt sampler**: Builds rich prompts from the program database. Prompt contains: sampled parent programs + inspiration programs with their scores, system instructions for proposing changes, explicit problem context (equations, PDFs, code snippets), stochastic formatting (randomized template variants for diversity), rendered evaluation results, and optionally a meta-prompt co-evolved in a separate database.

3. **LLMs ensemble**: Gemini 2.0 Flash (high throughput, diverse proposals) + Gemini 2.0 Pro (high quality, occasional breakthroughs). Model-agnostic by design; ablations confirm larger LLMs improve results monotonically. LLM outputs SEARCH/REPLACE diff blocks targeting specific segments of the current best program (full-file rewrite also supported for short code).

4. **Evaluators pool**: Each proposed program is automatically scored. Supports: evaluation cascade (progressive difficulty; prune non-promising programs early), LLM-generated feedback (for hard-to-quantify properties like simplicity), and parallelized evaluation (embarrassingly parallel runs from multiple random initializations; up to ~100 compute-hours per evaluation).

5. **Program database + Distributed controller**: Database implements MAP elites + island-based population models for exploration/exploitation balance. Controller is an asynchronous Python pipeline (asyncio); optimized for throughput to maximize ideas evaluated per compute budget.

**Controller loop** (pseudocode from §2.6):
```
parent_program, inspirations = database.sample()
prompt = prompt_sampler.build(parent_program, inspirations)
diff = llm.generate(prompt)
child_program = apply_diff(parent_program, diff)
results = evaluator.execute(child_program)
database.add(child_program, results)
```

## Results

### Matrix multiplication (§3.1)

- AlphaEvolve improved SOTA for 14 out of 16 tested matrix multiplication targets (Table 2).
- **Landmark**: For 4×4 complex-valued matrices, discovered rank-48 algorithm — first improvement over Strassen's rank-49 (1969) in 56 years over any field with characteristic 0. (Note: Fawzi et al. 2022 achieved rank-47 but only over the field with 2 elements, non-recursive.)
- For all m,n,p ≤ 5 targets, AlphaEvolve matched or surpassed best known solutions.

### Open mathematical problems (§3.2)

- Applied to 50+ problems across analysis, combinatorics, number theory, geometry.
- 75% of cases: rediscovered best known constructions.
- 20% of cases: surpassed SOTA with provably better new constructions (including Minimum Overlap Problem set by Erdős, improved Kissing Numbers in 11 dimensions).

### Google computing infrastructure (§3.3)

| Application | Method | Result | Status |
|---|---|---|---|
| Data center scheduling (Borg) | Evolved vector bin-packing heuristic; simulator + historical workloads | 0.7% fleet-wide compute recovery (stranded resources); chosen over deep RL for interpretability/debuggability | Deployed to entire fleet |
| Gemini training kernel tiling | Evolved tiling heuristic for TPU matrix multiplication kernel | 23% kernel speedup; 1% Gemini training time reduction; optimization time from months to days | Deployed in production |
| TPU arithmetic circuit (RTL) | Evolved Verilog for matrix multiplication unit arithmetic circuit | Found unnecessary bits removal; validated by TPU designers; to be integrated in upcoming TPU | Not yet released (hardware) |
| FlashAttention XLA IR | Evolved compiler-generated IR for FlashAttention on GPU | 32% speedup in FlashAttention kernel; 15% speedup in pre/postprocessing | Demonstrated |

### Ablations (§4)

Each component contributes significantly to results on two benchmarks (matrix multiplication, kissing numbers):
- **No evolution** (repeated same initial program, no database): worst performance.
- **No context in prompt**: significant degradation.
- **No full-file evolution** (single-function only, like FunSearch): significant degradation.
- **No meta-prompt evolution**: moderate degradation.
- **Small base LLM only**: meaningful degradation vs ensemble.

## FunSearch vs AlphaEvolve (Table 1)

| Dimension | FunSearch | AlphaEvolve |
|---|---|---|
| Scope | Single Python function (10-20 lines) | Entire codebase (hundreds of lines), any language |
| LLM | Small code-trained LLMs; no benefit from larger | Benefits from SOTA LLMs (Gemini 2.0) |
| Objectives | Single metric | Multiple simultaneous metrics |
| Context | Minimal (previous solutions) | Rich (problem description, prior art, scores, meta-prompt) |
| Evaluation time | Fast (≤20 min, 1 CPU) | Hours, parallel accelerators |
| LLM samples needed | Millions | Thousands |

## Boundary conditions

- **Automated evaluator required**: AlphaEvolve is restricted to problems where solution quality can be measured automatically. Natural science domains requiring physical experiments, wet-lab validation, or manual assessment are out of scope. (§6 Discussion, §1)
- **Formal verification gap**: Correctness of evolved code is verified against test cases and randomized inputs, not formal proofs (except for mathematical constructions where the verifier is the mathematical property itself). Human expert validation was required for TPU circuit and FlashAttention.
- **Google infrastructure results are deployment-specific**: Scheduling and kernel improvements measured against Google's proprietary workloads; generalization to other codebases is not directly established.
- **White paper, not peer-reviewed paper**: No single benchmarked comparison against all prior LLM+evolution methods under identical conditions.

## Decision knowledge

- The key design insight distinguishing AlphaEvolve from natural-language hypothesis agents (e.g., Co-Scientist): using code + automated evaluators "substantially sidesteps LLM hallucinations" by grounding every candidate in machine-checked execution results. This allows scaling to thousands of iterations without hallucination accumulation. (§5 Related work, §6)
- Multi-objective optimization often improves single-target performance even when only one metric is ultimately desired — because optimizing diverse metrics produces structurally diverse programs that enrich the prompt context pool. (§2.4)
- Evolved programs can tackle the same problem at different levels of abstraction: raw solution, constructor function, or search algorithm. The choice of abstraction affects which solutions are discoverable (symmetric solutions favor constructor functions). (§2.1)
- Meta-prompt evolution (co-evolving the prompt template itself alongside programs) provides additional gains over static prompting. (§2.2, ablations)

## Not stated in source

- Compute budget per application is not disclosed (number of LLM calls, wall-clock time, or dollar cost).
- The 0.7% fleet-wide compute recovery from Borg scheduling is measured against the prior production heuristic, not theoretical optimal bin-packing — so the absolute improvement ceiling is unknown.
- The 48-multiplication 4×4 complex algorithm has been described but whether it yields practical wall-clock speedups in real hardware (vs Strassen) is not addressed.

## Relations

- Supports: [[gottweis-2025-coscientist]] (concurrent work explicitly cited; AlphaEvolve authors note the approaches are complementary - programmatic evaluation vs natural-language evaluation; suggest combining both)
- Extends: FunSearch (Romera-Paredes et al. 2023) — not in corpus; AlphaEvolve is the direct generalization
- Contradicts: -
- Superseded by: -
