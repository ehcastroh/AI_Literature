---
title: "Token-Efficient Multimodal Reasoning via Image Prompt Packaging"
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2604.02492]
supersedes: []
superseded_by: []
expires_when: "Results benchmark against GPT-4.1, GPT-4o, and Claude 3.5 Sonnet (pricing as of Jan 2026). Re-evaluate when: (a) provider tokenization schemes change (tile-based vs pixel-linear is the key cost driver), (b) open-source MLLM results are available (currently evaluated on closed models only), or (c) native text-in-image compression architectures (DeepSeek-OCR style) become mainstream."
tags: [multimodal, prompt-compression, inference-efficiency, VQA, token-efficiency, cost-optimization, enterprise]
---

# Token-Efficient Multimodal Reasoning via Image Prompt Packaging

Joong Ho Choi, Jiayang Zhao, Avani Appalla, Himansh Mukesh, Dhwanil Vasani, Boyi Qian. BNY (Bank of New York Mellon), Pittsburgh. arXiv:2604.02492v1 (April 2026).

## Claim

Image Prompt Packaging (IPPg) reduces multimodal LLM inference cost by embedding the text prompt directly into an image (as whitespace above the original image) and routing it through the vision tokenization channel, eliminating the text token cost for the injected content. No model modification required. IPPg achieves 35.8-91.0% inference cost reductions across five datasets and three models, but outcomes are highly model- and task-dependent: GPT-4.1 achieves simultaneous accuracy and cost gains on CoSQL, while Claude 3.5 Sonnet incurs cost increases on several benchmarks due to its pixel-linear image tokenization scheme. Rendering choices (font, color, size) are first-class variables that shift accuracy by 10-30 percentage points. (Abstract, §6)

## Core Mechanism (§3.1-3.2)

**Tokenization pricing insight**: across all tested providers, image tokens are priced identically to input text tokens: `p_img = p_i`. Output tokens are 4× (GPT) or 5× (Claude) more expensive than input.

**Cost condition for IPPg to save money** (derived in §3.1):

IPPg is cheaper than text prompting if and only if `Δn_img < n_i`, where:
- `Δn_img = n_img^IPPg - n_img^baseline` = additional image tokens from embedding text
- `n_i` = text tokens eliminated

Per-query savings when condition holds: `Savings = p_i * (n_i - Δn_img)`

**Tokenization scheme asymmetry** — the reason Claude underperforms OpenAI on cost savings:
- **OpenAI (tile-based)**: `n_img = T_base + T_tile * ⌈W/512⌉ * ⌈H/512⌉`, where T_base=85, T_tile=170. Embedding text as a whitespace banner often leaves tile count unchanged (Δn_img ≈ 0), so the full text token cost is saved.
- **Claude (pixel-linear)**: `n_img = W*H/750`. Adding any whitespace strictly increases image area and thus image token count — partially or fully offsetting text token savings.

**Pipeline**: (1) Take original image. (2) Add minimal whitespace above image. (3) Inject text prompt into whitespace using PIL at 72 DPI. (4) Send image+system-prompt to model; text channel carries only the system prompt (output format). Text prompt tokens are eliminated.

## Experimental Setup (§4)

Five datasets across two task families:

| Dataset | Task | Why suited for IPPg |
|---|---|---|
| FAMMA | Financial multimodal QA | Verbose text prompts, visual inputs already central |
| PathVQA | Medical image VQA | Tests whether text embedding interferes with visual reasoning |
| SROIE | Receipt information extraction | Document understanding; moderate text overlap |
| HumanEval | Python code generation (text-only) | Baseline: no native visual input; tests text-as-image |
| CoSQL (MAC-SQL) | Conversational text-to-SQL | Schema descriptions extremely token-intensive (SELECTOR stage) |

Models: GPT-4.1, GPT-4o, Claude 3.5 Sonnet. No open-source models evaluated.

## Results (§5, Table 3)

**Summary across datasets** (selected results; positive ΔAcc = accuracy gain under IPPg):

| Dataset | Model | ΔAcc | Cost change |
|---|---|---|---|
| FAMMA (English+MCQ) | GPT-4.1 | -0.72pp | -14.6% |
| FAMMA overall | GPT-4.1 | -9.0pp | -24.1% |
| FAMMA overall | Claude 3.5 | -1.7pp | **+27.6%** (cost increase) |
| PathVQA | GPT-4.1 | -0.3pp | -56.0% |
| PathVQA | Claude 3.5 | -4.9pp | **+35.7%** (cost increase) |
| SROIE | Claude 3.5 | +3.4pp | -1.5% |
| HumanEval | GPT-4.1 | -10.3pp | -11.5% |
| HumanEval | Claude 3.5 | **-41.0pp** | -29.4% |
| CoSQL | GPT-4.1 | **+1.38pp** | **-91.0%** (simultaneous win) |
| CoSQL | GPT-4o | -4.0pp | -37.4% |

**CoSQL is the strongest case**: SELECTOR agent token count (per query): GPT-4.1 24,096 → 836 tokens (-96.5%), GPT-4o 2,679 → 789 (-70.6%), Claude 3,149 → 936 (-70.3%). The image token counts after IPPg are comparable across models (~800-950) despite vastly different baseline text token counts — the difference in savings rates is driven by baseline text volume, not visual processing efficiency.

**FAMMA non-English**: largest accuracy penalties (-21.1% for GPT-4.1, -23.3% accuracy drop for GPT-4o non-English). Non-Latin scripts are already more expensive to tokenize as text; IPPg does not help but the failure modes are worse.

## Failure Mode Taxonomy (§5, error analysis)

Consistent bottlenecks identified across model families and datasets:

1. **Spatial reasoning** — "where" questions suffer most. Text embedding may interfere with spatial attention allocation; tight text-image integration is required for spatially grounded queries.
2. **Non-English inputs** — larger accuracy penalties; especially for morphologically complex or non-Latin scripts.
3. **Character-sensitive operations** — string manipulation and character-exact tasks (e.g., HumanEval string questions: 92.6% pass rate vs 98.7% for list/array).
4. **Order-sensitive arithmetic** — boundary condition edge cases where character-level noise corrupts reasoning.
5. **Multi-table relational reasoning** — 27 CoSQL queries failed universally across all architectures; all required multi-table join reasoning from visual schemas. "Current vision-language models cannot reliably trace foreign key relationships from images." (§5) Dominant error type: wrong table schema selected (GPT-4.1: 62.5%, GPT-4o: 47.1%, Claude: 50.0%).

**Best suited for**: schema-structured tasks (SQL), structured document extraction (receipts with high-density fixed-layout text), fixed-answer VQA (yes/no).

## Rendering Ablation (§5.3)

125 configurations: 5 fonts × 5 colors × 5 sizes, evaluated on 20 representative samples per dataset × 3 models.

Key findings:
- Rendering choices shift accuracy by **10-30 percentage points** — not cosmetic.
- **Dark green text** universally effective: highest accuracy on PathVQA for all three models; competitive on FAMMA and SROIE.
- **Monospace fonts** (Courier) excel for structured tasks — likely due to code-like text familiarity from pretraining.
- **Larger font sizes** (24-32pt) consistently outperform 16pt; 28pt optimal for several configurations.
- **Model- and task-specific** optimal configurations exist: GPT-4.1 favors dark blue + Courier on FAMMA but dark red + Times on SROIE.
- **Pareto frontiers are tunable**: GPT-4o on FAMMA can trade +25% accuracy gain for 23% higher cost, or hold baseline accuracy for 9.2% savings — these are discrete operating points the practitioner chooses.

The default black/Arial configuration is suboptimal for most model-dataset combinations.

## Boundary Conditions

- **Closed models only**: GPT-4.1, GPT-4o, Claude 3.5 Sonnet. No open-source model evaluation; whether benefits generalize is explicitly listed as future work.
- **Proprietary implementation**: IPPg is BNY-internal software, no public code release.
- **Tile-based tokenization required for large savings**: Claude's pixel-linear tokenization systematically negates OpenAI-style cost gains. Any provider switching to pixel-linear pricing changes the cost analysis.
- **No adversarial evaluation**: paper explicitly notes IPPg can be used adversarially (typographic attacks) — this is left as future work with an ethics acknowledgment.
- **Rendering evaluation limited to 20 samples per dataset**: ablation covers 1,125 API calls per sample — computationally constrained. Conclusions are directionally valid but not exhaustively sampled.
- **No evaluation on inputs requiring joint visual+textual spatial reasoning**: IPPg adds text over image but the model must attend to both simultaneously; mixed spatial tasks are underexplored.

## Decision Knowledge

- IPPg's viability is decided by the tokenization arithmetic: if the provider uses tile-based image tokenization (OpenAI), embedding text in whitespace above the image often costs zero additional image tokens — making IPPg nearly free on cost while only accuracy is the variable. If the provider uses pixel-linear tokenization (Claude), IPPg is systematically expensive.
- Schema-heavy multi-agent pipelines (MAC-SQL SELECTOR stage: 24K→836 tokens) are the highest-value target for IPPg. Any system with verbose, repetitive structured text in prompts (schemas, policy documents, templates) is a strong candidate.
- Rendering parameters should be treated as hyperparameters, not defaults. Dark-colored high-contrast text (especially dark green) and monospace fonts at 24-28pt are robust starting points. Tune per model and task.

## Not Stated in Source

- The 91% cost reduction on CoSQL for GPT-4.1 is driven partly by GPT-4.1's unusually high baseline token count for the SELECTOR agent (24,096 tokens vs GPT-4o's 2,679) — likely due to different model context handling rather than better visual processing efficiency. The absolute image token counts are similar across models (~800-900), so the saving rate difference is an artifact of baseline token volume.
- FAMMA accuracy differences between models (GPT-4.1: 39%, GPT-4o: 34%, Claude: 18%) suggest this benchmark is harder for Claude even before IPPg, making the comparison of IPPg accuracy drops harder to interpret.
- HumanEval tests a purely text task (no native visual input); the severe Claude degradation (-41pp) may reflect Claude's stronger alignment with code reasoning in text form, not a general IPPg failure.

## Relations

- Complements: [[jiang-2023-longllmlingua]] (both address prompt token reduction; LongLLMLingua compresses text via perplexity-based pruning; IPPg reroutes text to the image channel; techniques are orthogonal and could be combined)
- Relates to: [[liu-2023-cdcca]] (both address MLLM efficiency; CD-CCA uses knowledge distillation for edge-cloud adaptation; IPPg uses prompt-time visual routing — different deployment layer)
- Contradicts: -
- Superseded by: -
