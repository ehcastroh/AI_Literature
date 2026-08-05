---
title: Precise Zero-Shot Dense Retrieval without Relevance Labels (HyDE)
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2212.10496]
supersedes: []
superseded_by: []
expires_when: "A zero-shot retrieval method achieves comparable nDCG@10 on BEIR/TREC without an instruction-following LLM (e.g., via improved unsupervised encoders alone)"
tags: [retrieval, dense-retrieval, zero-shot, LLM, RAG, information-retrieval]
---

# Precise Zero-Shot Dense Retrieval without Relevance Labels (HyDE)

Luyu Gao, Xueguang Ma, Jimmy Lin, Jamie Callan. CMU / University of Waterloo. arXiv:2212.10496. December 2022.

## Claim

Zero-shot dense retrieval without relevance labels is achievable by pivoting through a **Hypothetical Document Embedding (HyDE)**: instruct an LLM to generate a hypothetical document that captures relevance patterns (factual accuracy not required), encode it with an unsupervised contrastive encoder, and retrieve real documents by vector similarity. No model is trained or fine-tuned. (§1, §3.2)

## Method

Two-step pipeline, both backbones frozen (§3.2):

1. **Generation** - Feed query + task-specific instruction to an instruction-following LLM (InstructGPT, `text-davinci-003`). Sample N hypothetical documents. The documents may hallucinate facts; they only need to resemble relevant documents in form.
2. **Encoding + Retrieval** - Encode each hypothetical document with an unsupervised contrastive encoder (Contriever / mContriever). Average the N embedding vectors (Eq. 7). Optionally include the raw query embedding in the average (Eq. 8). Run MIPS against corpus embeddings. Return most similar real documents.

Key insight: relevance modeling is offloaded from the encoder (which must be learned from relevance labels) to the LLM (which generalizes from instruction training). The encoder's dense bottleneck acts as a lossy compressor that filters hallucinated details from the hypothetical embedding. (§3.2)

Implementation: InstructGPT temperature 0.7; English retrieval uses Contriever, multilingual uses mContriever; Pyserini toolkit. Task-specific instructions listed in Appendix A.1.

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| HyDE vs. Contriever, web search precision | +37.3 nDCG@10 (41.8 - 24.0) | TREC DL19, no relevance labels | Table 1 |
| HyDE vs. BM25, web search precision | +17.5 nDCG@10 (61.3 - 44.5) | TREC DL19 | Table 1 |
| HyDE vs. ContrieverFT (in-domain supervised) | -0.4 nDCG@10 (61.3 vs 62.1) | TREC DL19 | Table 1 |
| HyDE vs. Contriever, low-resource BEIR (6 datasets) | Positive across all 6 | nDCG@10 and Recall@100 | Table 2 |
| HyDE vs. BM25, low-resource BEIR | 1 loss out of 6 (TREC-Covid: 59.3 vs 59.5, margin 0.2) | nDCG@10 | Table 2 |
| HyDE vs. DPR and ANCE (MS-MARCO fine-tuned) | Generally better despite no fine-tuning | BEIR low-resource | Table 2 |
| HyDE multilingual vs. mContriever | +3.4 to +11.2 MRR@100 | Mr.Tydi: sw, ko, ja, bn | Table 3 |
| HyDE multilingual vs. mContrieverFT | -9.5 to -11.7 MRR@100 | Mr.Tydi; gap largest for Korean/Japanese | Table 3 |
| LLM scaling effect | Flan-T5(11B)=48.9, Cohere(52B)=53.8, GPT(175B)=61.3 nDCG@10 | TREC DL19 with Contriever encoder | Table 4 |

## Boundary conditions

- **Ambiguous queries**: method assumes uni-modal query distribution; multi-modal (ambiguous) queries left to future work (§3.2). Averaging hypothetical embeddings will blend interpretations.
- **Low-resource languages in LLM**: multilingual gap vs. fine-tuned models attributed to under-training of non-English in both pre-training and instruction-following stages of the backbone LLM (§4.4).
- **Domain-specific tasks**: FiQA (financial) and DBPedia (entity) underperform vs. ContrieverFT; attributed to under-specified instructions rather than method failure (§4.3). More elaborative domain instructions may close the gap.
- **LLM quality**: weaker instruction LMs (Flan-T5 11B) can degrade performance when combined with a fine-tuned encoder; larger LLMs consistently better (§5.1, §5.2, Table 4).
- **Intended use case**: cold-start / zero-label period only. As search logs accumulate, HyDE should be replaced or supplemented by a supervised retriever (§6).
- **No relevance feedback loop**: HyDE does not improve over time from retrieved results; it is purely generative at query time.

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Generate hypothetical doc instead of encoding query directly | Query-document similarity is hard to learn unsupervised; NLG models generalize from instruction training without task-specific labels (§1, §3.2) | Falls back to Contriever (query vector = query embedding), which underperforms BM25 | Thinking the hypothetical doc must be factually correct - it doesn't; it only needs to match relevance patterns |
| Use unsupervised contrastive encoder (Contriever) | Only requires document-document similarity, learnable without relevance labels (§3.2) | Would require labeled data to train encoder | Assuming query and doc encoders must share training signal |
| Average N hypothetical doc embeddings | Approximates expectation E[f(g(q, INST))] under uni-modal assumption; reduces variance (§3.2, Eq. 5-7) | Single sample, higher variance | [not stated in source]: N not ablated in paper; OpenAI default sampling used |
| Task-specific instructions (Appendix A.1) | Different retrieval tasks have different document forms (sci paper vs news vs counter-argument) | Generic instructions underperform for specialized domains | Instructions are not elaborate; they mainly specify document type and task frame |

## Not stated in source

- Number of hypothetical documents N sampled per query is not specified or ablated in the main paper.
- Temperature (0.7) is cited as OpenAI playground default with no ablation.
- No dedicated limitations section; limitations are distributed across §4.3, §4.4, and §6.
- The paper does not study instruction sensitivity systematically - which instruction phrasings matter and by how much.
- No analysis of query-level variance: which query types benefit most or fail worst.
- HyDE is evaluated only with Contriever as the encoder. Performance with other unsupervised encoders (SimCSE, etc.) is unknown.
- As of 2022 the retrieval of multiple hypothetical docs was via InstructGPT (closed API). Open-source replication requires a comparable instruction-following model.

## Relations
- Cluster: [[retrieval-and-context]]

- Supports: - (no papers yet in corpus)
- Contradicts: - (no papers yet in corpus)
- Superseded by: -

## Expiry

When a zero-shot retrieval method achieves HyDE-level nDCG@10 on TREC DL19 without an instruction-following LLM, this paper's primary contribution is retired. Re-verify when: a new unsupervised encoder benchmark appears on BEIR.
