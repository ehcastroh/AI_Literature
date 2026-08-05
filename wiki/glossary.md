# Glossary

Definitions for terms, acronyms, and concepts appearing across the literature.
Entries are alphabetical. Link to the paper where a term is first introduced.

---

## B

**BEIR** — Benchmarking IR: a heterogeneous benchmark for zero-shot evaluation of information retrieval models across 18 diverse datasets (web search, QA, fact verification, etc.). Standard testbed for measuring retrieval generalization. Introduced by Thakur et al. 2021; used as evaluation suite in [[zero-shot-dense-retrieval]].

## C

**Contrastive perplexity** — Token importance metric proposed in [[longllmlingua-prompt-compression]] for question-aware fine-grained prompt compression: si = perplexity(xi | x<i) - perplexity(xi | xque, x<i). Measures the distribution shift caused by conditioning on the question. Mathematically equivalent to conditional pointwise mutual information. Tokens with high si cluster near ground-truth relevant documents; raw perplexity alone does not discriminate them. Contrast with standard perplexity-based pruning (LLMLingua) which is question-agnostic.

**Contriever** — An unsupervised dense retrieval model trained with contrastive learning on document pairs (Izacard et al. 2021). Learns document-document similarity without relevance labels. Used as the encoder backbone in HyDE. Multilingual variant: mContriever.

**Crossbatch training** — The training procedure in the Focused Transformer ([[focused-transformer-context-scaling]]) that exposes memory attention layers to both a positive (key, value) pair from the same document and d-1 negative pairs from other documents in the batch. Shapes the key-value space to distinguish relevant from irrelevant context using only the standard LM loss - no extra contrastive loss term. Controlled by crossbatch dimension d; trained with a curriculum starting at d≤8 and increasing to d≥64.

## C (continued)

**Context engineering** — Formal discipline introduced in [[context-engineering-survey]] that treats LLM context not as a static string but as a dynamically assembled composition C = A(c1,...,cn), where components include instructions (cinstr), external knowledge (cknow), tool signatures (ctools), persistent memory (cmem), world/agent state (cstate), and the user query (cquery). The optimization objective is F* = argmax_F E_τ[Reward(Pθ(Y|CF(τ)), Yτ*)]. Subsumes prompt engineering, RAG, memory systems, tool use, and multi-agent orchestration as specialized instances. The comprehension-generation gap — models understand complex contexts far better than they generate equivalently sophisticated outputs — is the field's central open challenge as of July 2025.

## D

**Double Machine Learning (DML)** — Causal inference procedure for estimating treatment effects from observational data when a confounding variable is present. Introduced by Chernozhukov et al. 2018; applied to prompt optimization in [[causal-prompt-optimization]]. Two nuisance models are fitted: m(x) = E[Y|x] (outcome residual) and e(x) = E[Z|x] (treatment residual). Orthogonalized residuals Ÿ = Y - m̂(x) and Ẑ = Z - ê(x) are then regressed to yield a causal effect estimate β that is robust to misspecification of either nuisance model (Neyman orthogonality). In CPO, Y is LLM task accuracy, Z is the prompt embedding (treatment), and x is the query embedding (confounder). Removing E[Z|x] from Z isolates the part of the prompt that independently causes performance changes, separate from the query difficulty that drove prompt selection.

**Dense retrieval** — Retrieval method that maps queries and documents to dense embedding vectors and measures relevance by inner-product (vector) similarity, as opposed to sparse/lexical methods like BM25. Requires learning two encoder functions into a shared embedding space.

**Distraction issue** — The failure mode in standard transformer training where attention mass is evenly spread across all (key, value) pairs in memory, so the positive attention mass from relevant tokens rd ≈ 1/d shrinks as context size d grows. Identified in [[focused-transformer-context-scaling]]. Addressed by crossbatch training, which shapes the key space so relevant tokens receive rd ≈ 1 regardless of d.

## E

**Episodic memory buffer** — In Reflexion ([[reflexion-verbal-reinforcement-learning]]), the long-term memory component storing verbal self-reflections from past trials. Bounded to Ω=1-3 entries due to LLM context length constraints. Distinct from short-term memory (current trajectory). The constraint is a context budget, not a quality design choice.

## G

**Generate-debate-evolve paradigm** — The core iterative loop in Co-Scientist ([[ai-co-scientist-discovery]]): the Generation agent proposes hypotheses, the Ranking agent conducts multi-turn scientific debates for pairwise Elo-based ranking, and the Evolution agent refines top-ranked hypotheses into new candidates. The cycle repeats with increasing compute, enabling continuous quality improvement without gradient-based learning.

## H

**HumanEval** — Code generation benchmark (Chen et al. 2021) consisting of 164 Python programming problems with hand-written unit tests. Primary evaluation for pass@1 accuracy in code generation. Used in [[reflexion-verbal-reinforcement-learning]].

**Hypothetical Document Embeddings (HyDE)** — Zero-shot dense retrieval method (Gao et al. 2022, [[zero-shot-dense-retrieval]]). Given a query, an instruction-following LLM generates a hypothetical document (may be factually wrong) which is encoded into a dense vector by a contrastive encoder; real documents are retrieved by similarity to that vector. No model training required.

## L

**Lost in the middle** — Empirical phenomenon (Liu et al. 2024) where LLMs have lower accuracy when key information appears in the middle of a long prompt compared to the beginning or end. Motivates document reordering in [[longllmlingua-prompt-compression]] and is one of the three core problems LongLLMLingua addresses.

**LLM routing** — Inference efficiency technique where a pool of candidate LLMs (of various sizes/costs) is maintained, and a trained router selects the most appropriate LLM per query. Trades off response quality against cost/latency. "Static routing": pool is fixed during training. "Dynamic routing": new LLMs appear at test time without router retraining - addressed by [[universal-model-routing]]. Distinct from model cascading (see below). [[llm-routing-cascading-survey]] surveys the full landscape across six paradigms.

**Model cascading** — Multi-stage inference strategy where a smaller, cheaper LLM is queried first; if its response quality falls below a threshold, the query is escalated to a larger, more capable model. Contrast with routing, which makes a single upfront selection. In cascading, multiple models can be involved per query; the escalation decision uses post-generation signals (confidence, quality estimate, self-verification score). Practically attractive because it combines the cost of cheap models on easy queries with the capability of strong models on hard ones. Surveyed in [[llm-routing-cascading-survey]] §7.

## M

**Memory attention layers** — In the Focused Transformer ([[focused-transformer-context-scaling]]), the subset L of attention layers that receive external (key, value) pairs via kNN lookup during inference. Positional encodings are removed from memory keys so the model can extrapolate beyond its training context length. The only layers modified by crossbatch training.

**Memory stream** — The core memory structure in Generative Agents ([[generative-agents-human-simulacra]]). An append-only log of all agent experiences as natural language entries (observations, reflections, plans), each tagged with creation and last-access timestamps. Retrieval is scored by recency + importance + relevance rather than recency or similarity alone.

**MIPS (Maximum Inner Product Search)** — Efficient algorithm for finding the document embedding with highest inner product similarity to a query vector in a large corpus. The search primitive underlying all dense retrieval systems.

**Mr.Tydi** — Multi-lingual dense retrieval benchmark (Zhang et al. 2021) covering Swahili, Korean, Japanese, Bengali, and other languages. Used to evaluate multilingual retrieval in [[zero-shot-dense-retrieval]].

## P

**Automatic prompt engineering (APE)** — Family of methods that use an LLM to propose and iteratively refine prompts without human intervention. Baseline methods (Iterative APE, APO) use brief meta-prompts; PE2 ([[prompt-engineering-a-prompt-engineer]]) improves these with a detailed two-step task description, context specification, and per-example reasoning template. Distinct from soft-prompt tuning (which requires model access) and manual prompt engineering.

**Prompt compression** — Technique for reducing the number of tokens in a prompt while preserving the information needed for downstream LLM response quality. Two main families: (1) information-entropy-based (LLMLingua, Selective-Context) — remove tokens with low perplexity under a small LM; (2) question-aware (LongLLMLingua, [[longllmlingua-prompt-compression]]) — compress based on relevance to the specific query. Compression-based methods trade off cost/latency vs context integrity.

## V

**Verbal reinforcement learning** — Reinforcement of language agents through natural language feedback rather than weight updates or scalar rewards. Coined in [[reflexion-verbal-reinforcement-learning]]. The policy is parameterized as {LLM weights, episodic memory}; only memory is updated between trials. Contrast with RLHF (weight updates) and prompting (no trial-and-error loop).

## Z

**Zero-shot dense retrieval** — Dense retrieval without any task-specific relevance labels. A model trained on no query-document relevance pairs for the target task must still retrieve relevant documents. Contrast with transfer learning (fine-tune on MS-MARCO, evaluate elsewhere) and fully supervised retrieval.
