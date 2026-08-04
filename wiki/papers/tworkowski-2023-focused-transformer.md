---
title: Focused Transformer — Contrastive Training for Context Scaling
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2307.03170]
supersedes: []
superseded_by: []
expires_when: "A method achieves >90% passkey retrieval at 256K tokens without contrastive fine-tuning, or approximate kNN at scale is shown to not degrade FoT's gains"
tags: [context-length, transformers, contrastive-learning, long-context, retrieval, fine-tuning]
---

# Focused Transformer: Contrastive Training for Context Scaling

Szymon Tworkowski, Konrad Staniszewski, Mikołaj Pacek, Yuhuai Wu, Henryk Michalewski, Piotr Miłoś. IDEAS NCBR / University of Warsaw / Google DeepMind / xAI. NeurIPS 2023. arXiv:2307.03170.

## Claim

Standard transformer training causes a "distraction issue" - attention mass is evenly spread across relevant and irrelevant (key, value) pairs, with positive attention mass rd ≈ 1/d as context size d grows. The Focused Transformer (FoT) addresses this by exposing a subset of attention layers to both positive (same-document) and negative (other-document) context during training using a differentiable crossbatch procedure, shaping the key-value space to focus on relevant tokens. No architectural changes or extra loss functions required. (§1, §3.2, §3.3)

## Method

Two components (§3, Fig. 2):

**Memory attention layers** (§3.1) - a subset L of attention layers gets access to additional (key, value) pairs from external memory during inference via kNN lookup (FAISS exact search). Memory is populated incrementally. Positional encodings removed in memory keys (allows extrapolation beyond training context). At inference: query attends to local context keys + top-k memory keys by inner product.

**Crossbatch training** (§3.2) - for each document δ in a batch, construct a set of (k,v) pairs:
- 1 positive: previous local context Cprev of δ (same document)
- d-1 negatives: Cprev from d-1 other documents in the batch

Both positives and negatives pass through the memory attention layer in a fully differentiable way using the standard LM loss only (no extra contrastive loss term). The model is incentivized to attend to the positive and ignore the negatives. Only new hyperparameter: d (crossbatch dimension). Typical schedule: start d≤8, increase to d≥64. Increases training cost only in the memory layer subset.

**LongLLaMA** (§4) - FoT applied to OpenLLaMA 3B and 7B. Memory layers L={6,12,18} (3B), L={8,16,24} (7B). Fine-tuned on 10B/3B tokens at 8K context length (RedPajama mixture). Three LongLLaMA-specific adaptations: (1) retains rotary positional encoding in local context for LLaMA backward compatibility, (2) uses dense attention instead of kNN (marginal performance difference), (3) finer-grained control over positive/negative ratio.

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| Passkey retrieval at 100K tokens | 94.5% (LongLLaMA 3B) vs 0% (OpenLLaMA 3B) | Trained on 8K context; test at 100K | §4.2, Fig. 1 |
| Passkey retrieval at 256K tokens | 73% (LongLLaMA 3B) | Trained on 8K context; test at 256K | §4.2, Fig. 1 |
| TREC few-shot: 2K→8K context | 67.0%→73.3% (3B); 63.2%→75.9% (7B) | More in-context demonstrations at longer context | §4.4, Table 1 |
| WebQS few-shot: 2K→8K context | 21.2%→22.4% (3B); 25.5%→27.7% (7B) | Modest gains | §4.4, Table 1 |
| FoT vs standard 4K fine-tuning (TREC) | FoT extrapolates to 8K (62.5%); baseline bounded at 4K | FoT trained on 4K, baseline trained on 4K | §4.5, Table 2 |
| Perplexity: FoT vs Memorizing Transformer at 64K | FoT GitHub: 5.32 vs MT: 7.26; Isabelle: 4.44 vs 6.64 | Zero-shot, fine-tuned on 2K context | §5.2, Table 3 |
| Dictionary lookup: context extrapolation | >92% accuracy using 16M token memory | FoT trained on 512-token documents | §5.2 |
| Distraction issue mitigation | rd ≈ 1/d (baseline) → rd ≈ 1 (FoT d=64) | Multi-doc memory, positive attention mass measure | §3.3, Fig. 3 |
| Multi-doc perplexity scaling (PG-19) | Perplexity increase of only 0.18 when scaling to >500K tokens | FoT d=64, books in memory | §5.3 |
| Short-context performance | Preserved (drop-in replacement for LLaMA) | LM Evaluation Harness | §4.6 |

## Boundary conditions

- **Exact kNN not scalable**: experiments use exact FAISS kNN; storing >16M (k,v) pairs requires distributed multi-node systems; approximate kNN introduces accuracy/quality tradeoffs not yet characterized (§6).
- **Crossbatch dimension bounded by hardware**: d≤64-128 limited by single TPU memory; increasing d is beneficial but requires multi-node training (§6).
- **Passkey retrieval is synthetic**: 73% at 256K is on a retrieval synthetic task, not end-to-end downstream task performance. Real-world gains on 256K context tasks unknown.
- **WebQS gains modest**: unlike TREC (50 classes, many rare), WebQS shows diminishing returns from longer context. Task structure determines whether longer context helps (§4.4).
- **Positional encoding retained for LLaMA compatibility**: in pure FoT, memory keys have no positional encoding. LongLLaMA retains PE in local context for backward compatibility; this is a pragmatic compromise, not the clean method (§4.1).
- **Training cost increases** in memory layer subset due to crossbatch; scales with d (§3.2, §6).

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Expose negatives in attention layers (not output layer) | Standard contrastive learning at output layer (TRIME) doesn't shape the key space used for attention retrieval; the distraction issue lives in the key space, so the fix must be applied there (§2, §3.2) | Output-layer contrastive (TRIME): improves representations but doesn't help memory attention select relevant keys | Assuming adding a contrastive loss on top of LM loss would be simpler and equivalent |
| Use standard LM loss only (no extra loss term) | Extra loss introduces weighting hyperparameters and training instability; crossbatch shapes the key space implicitly through the LM objective (§3.2) | Extra contrastive loss: adds a hyperparameter that interacts badly with the LM loss | Expecting a separate contrastive term; the method works entirely through the standard next-token prediction loss |
| Start d small (≤8), then increase (≥64) | Large d from the start causes model to ignore the previous local context entirely; curriculum from easy (few distractors) to hard (many distractors) stabilizes training (§3.2) | Constant large d: model collapses to ignoring all context | The d schedule is the most empirically sensitive part of the recipe |
| Remove positional encodings from memory keys | Memory keys from distant context have large position IDs that corrupt the inner-product similarity; removing PE allows attention to position 0, enabling extrapolation beyond training length (§3.1, §2) | PE in memory: attention distorted by positional distance, hard limit at training context length | This is why FoT extrapolates; the PE removal is not a side effect but the mechanism |

## Not stated in source

- Optimal number and placement of memory layers L not studied; chosen following Memorizing Transformer convention (§5.5).
- The threshold k=128 (top keys retrieved by kNN) was tuned but ablation not shown.
- How crossbatch interacts with other fine-tuning objectives (e.g., instruction tuning) is unknown.
- No evaluation of FoT on realistic long-document tasks beyond Qasper (one SCROLLS dataset shown); BEIR-style systematic evaluation absent.
- Whether the distraction issue re-emerges as model scale increases is not studied.

## Relations

- Supports: [[park-2023-generative-agents]] (provides a technical path to extend context limits cited as a key constraint in that paper; Generative Agents could benefit from longer effective context to reduce retrieval approximations)
- Supports: [[shinn-2023-reflexion]] (Reflexion bounded episodic memory to Ω=1-3 due to context length; FoT is one approach to relax that constraint)
- Contradicts: -
- Superseded by: -

## Expiry

When passkey retrieval at 256K is matched by a method without contrastive fine-tuning (e.g., native long-context models), or when approximate kNN at >16M tokens is shown to preserve FoT's perplexity gains. Re-verify when: a paper in corpus reports on context scaling beyond 256K tokens.
