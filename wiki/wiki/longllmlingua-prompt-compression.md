---
title: LongLLMLingua — Accelerating and Enhancing LLMs in Long Context Scenarios via Prompt Compression
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2310.06839]
supersedes: []
superseded_by: []
expires_when: "A compression method achieves comparable gains without question-specific re-compression (enabling caching), or long-context models (128K+) make token-budget compression obsolete for the prompt lengths studied here"
tags: [prompt-compression, long-context, RAG, retrieval, position-bias, efficiency]
---

# LongLLMLingua: Accelerating and Enhancing LLMs in Long Context Scenarios via Prompt Compression

Huiqiang Jiang, Qianhui Wu, Xufang Luo, Dongsheng Li, Chin-Yew Lin, Yuqing Yang, Lili Qiu. Microsoft Corporation. arXiv:2310.06839v2 (2024).

## Claim

LLMs in long context scenarios face three compounding problems: (1) higher computational cost, (2) performance degradation from noise in the prompt, and (3) position bias ("lost in the middle" - relevant information in the middle of the prompt is harder to use than at the edges). LongLLMLingua addresses all three through question-aware prompt compression using a small LM. Compressed prompts at 4x reduction outperform original uncompressed prompts by up to 21.4% on NaturalQuestions while costing ~4x less. (§1, §7)

## Method

Four components added on top of LLMLingua (Jiang et al. 2023a), which uses a small LM to remove low-perplexity tokens (§3, §4):

**Question-aware coarse-grained compression** (§4.1) - Score each document xdoc_k by the perplexity of the question xque conditioned on that document:

rk = -1/Nc * sum_i log p(xi^{que,restrict} | xdoc_k)

where xrestrict = "We can get the answer to this question in the given documents" (a regularization to reduce hallucination). Documents with lower rk (lower question perplexity when conditioned on them, meaning higher relevance) are retained. This metric outperforms BM25, SBERT, OpenAI embeddings, and rerankers on NaturalQuestions recall.

**Document reordering** (§4.2) - After coarse-grained filtering, reorder remaining documents by importance score rk so that the most relevant documents appear first (positions 1, 2, ...) rather than randomly placed. Mitigates the "lost in the middle" position bias. Applied as a standalone improvement even to other baselines.

**Dynamic compression ratios** (§4.3) - In fine-grained (token-level) compression, allocate tighter budgets to less-relevant documents and looser budgets to more-relevant ones. Budget for document k is linearly scheduled based on its rank index I(rk). More relevant documents are compressed less.

**Contrastive perplexity for fine-grained compression** (§4.1) - Rather than compressing tokens by raw perplexity, use:

si = perplexity(xi | x<i) - perplexity(xi | xque, x<i)

This measures the distribution shift caused by conditioning on the question. Mathematically equivalent to conditional pointwise mutual information (§Appendix A). Tokens with high si cluster near the ground-truth document even when that document is in the middle of the context; raw perplexity distribution appears random.

**Subsequence recovery** (§4.4) - Post-processing step: after LLM generates a response, find tokens in the response that appear in the compressed prompt, locate their longest original subsequence in the original prompt, and replace the compressed form with the full original text. Recovers entity names and proper nouns corrupted by token-level compression.

Small model used throughout: LLaMA-2-7B-Chat. Target LLMs tested: GPT-3.5-Turbo-0613, LongChat-13B-16k.

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| NaturalQuestions at 4x compression | +21.4% over original prompt | GPT-3.5-Turbo, key doc at 10th position of 20 | §5, Table 1 |
| LooGLE cost reduction | 94.0% cost reduction | GPT-3.5-Turbo | §1 |
| End-to-end latency at 2x-6x compression | 1.4x-2.6x speedup | 10k token prompts on V100-32G | §5 |
| LongBench avg at 3x compression | 48.8 (LongLLMLingua) vs 37.4 (LLMLingua) vs 44.0 (original) | GPT-3.5-Turbo, 3000 tokens | §5, Table 2 |
| LongBench avg at 6x compression | 48.3 (LongLLMLingua) vs original 44.0 | GPT-3.5-Turbo, 2000 tokens | §5, Table 2 |
| Recall@5 on NaturalQuestions (coarse stage only) | LongLLMLingua rk > BM25, SBERT, OpenAI, BGE-Ranker-large | All numbers of retained documents | §4.1, Fig. 3a |
| Position bias elimination with reordering | 77.2% avg across all 20 positions vs 70.8% without | 2x constraint, GPT-3.5-Turbo | §5, Table 1 |
| Compression-based baselines on NQ at 4x | Selective-Context 27.0, LLMLingua 30.5 vs LongLLMLingua 75.5 | GPT-3.5-Turbo | §5, Table 1 |
| Ablation: w/o question-awareness | 40.3 avg vs 72.9 avg (full) | 2x constraint, NaturalQuestions | §5, Table 3 |
| Ablation: GPT2-small as compressor | 70.1 at 10th position vs 70.8 for LLaMA-2-7B | 2x constraint, NaturalQuestions | §5, Table 3 |

## Boundary conditions

- **Question-aware, not query-agnostic**: re-compression is required for each new question even with the same corpus. No caching of the compressed context. LLMLingua (query-agnostic) avoids this overhead but is much weaker (§7 Limitations).
- **Computation overhead**: LongLLMLingua is 2x more expensive than LLMLingua due to computing contrastive perplexity (both conditional and unconditional passes). Raw overhead at 2x compression = 2.9 seconds; original prompt inference = 4.1 seconds, so net is still faster end-to-end (§5, Table 1).
- **Multi-hop QA is harder**: on MuSicQue, performance degrades more than on single-hop QA when context-question relationship is complex and subtle. The coarse-level document filter may discard relevant intermediate documents (§7 Limitations).
- **Prompt lengths tested**: NaturalQuestions ~13k tokens compressed to ~1.5k-3k; LongBench up to ~10k. Not evaluated at 100K+ token ranges studied in FoT/LongLLaMA.
- **Target LLM scope**: GPT-3.5-Turbo and LongChat-13B-16k. No evaluation on models with native long-context (Claude, GPT-4-128k, Gemini 1M), where the tradeoff may differ.
- **Subsequence recovery helps but is not strong**: removing it drops 0.5-1.5 points; it is a robustness fix, not a core performance driver (§5, Table 3).

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Score documents by p(xque\|xdoc) not p(xdoc\|xque) | p(xdoc\|xque) depends on document entropy from many sources unrelated to the question; p(xque\|xdoc) isolates how much the document explains the question (§4.1) | p(xdoc\|xque): noisy, doesn't discriminate relevant docs | Assuming either conditional direction is equivalent for document relevance scoring |
| Contrastive perplexity (difference) not conditional perplexity | Conditioning on xque lowers perplexity of relevant tokens but also many irrelevant ones (the signal gets drowned out); the *difference* from unconditional perplexity isolates question-specific relevance (§4.1, Fig. 3b) | Conditional perplexity: tokens near the answer are indistinguishable from background | The contrastive formulation is the core insight; the paper's other components are engineering around this |
| Append xrestrict after xque | Without it, the small model hallucinates associations; xrestrict acts as a regularizer reducing false positives in rk (§4.1 footnote 2) | w/o restrict: 1-2 point drop across positions (Table 3) | Often overlooked as a minor detail; ablation shows it matters |
| Document reordering (put high-rk docs first) | LLMs show empirically higher accuracy when relevant info is at prompt start/end vs middle (Liu et al. 2024); reordering is free after coarse-grained scoring (§4.2) | No reorder: performance varies sharply by ground-truth document position | Reordering is free — always include it even when using other baselines (Table 1 shows +3-10 pts for all methods) |

## Not stated in source

- Optimal small model size for compression not studied beyond GPT2-small vs LLaMA-2-7B; the gap (70.1 vs 70.8 at position 10) suggests small models are largely sufficient.
- How rk interacts with documents that are collectively relevant (multi-hop where no single doc is sufficient) is not studied; the coarse filter may discard one of the needed hops.
- No evaluation on RAG pipelines (where the LLM context is already the output of a retriever - double compression may hurt recall).
- The contrastive perplexity formulation (Eq. 3) was not ablated against other mutual information variants; its equivalence to CPMI is proved but alternatives not compared.
- Latency measured on V100-32G; not characterized on CPU or edge hardware where LLaMA-2-7B is expensive.

## Relations
- Cluster: [[retrieval-and-context]]

- Supports: [[zero-shot-dense-retrieval]] (HyDE and LongLLMLingua address orthogonal parts of retrieval pipelines - HyDE improves what documents are retrieved; LongLLMLingua improves how those documents are presented to the LLM after retrieval)
- Supports: [[generative-agents-human-simulacra]] (Generative Agents operate in long multi-agent contexts; prompt compression could reduce the cost of feeding the memory stream and retrieved observations into the LLM at each step)
- Contradicts: -
- Superseded by: -

## Expiry

When long-context models (e.g., 128K+ native context with no degradation) make token-budget compression obsolete for the ≤10K prompt lengths studied here, or when a query-agnostic compression method matches LongLLMLingua's question-aware gains (eliminating the re-compression bottleneck). Re-verify when: a paper in corpus benchmarks on LooGLE or NaturalQuestions multi-doc QA.
