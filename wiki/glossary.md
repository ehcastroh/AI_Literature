# Glossary

Definitions for terms, acronyms, and concepts appearing across the literature.
Entries are alphabetical. Link to the paper where a term is first introduced.

---

## B

**BEIR** — Benchmarking IR: a heterogeneous benchmark for zero-shot evaluation of information retrieval models across 18 diverse datasets (web search, QA, fact verification, etc.). Standard testbed for measuring retrieval generalization. Introduced by Thakur et al. 2021; used as evaluation suite in [[gao-2022-hyde]].

## C

**Contriever** — An unsupervised dense retrieval model trained with contrastive learning on document pairs (Izacard et al. 2021). Learns document-document similarity without relevance labels. Used as the encoder backbone in HyDE. Multilingual variant: mContriever.

## D

**Dense retrieval** — Retrieval method that maps queries and documents to dense embedding vectors and measures relevance by inner-product (vector) similarity, as opposed to sparse/lexical methods like BM25. Requires learning two encoder functions into a shared embedding space.

## H

**Hypothetical Document Embeddings (HyDE)** — Zero-shot dense retrieval method (Gao et al. 2022, [[gao-2022-hyde]]). Given a query, an instruction-following LLM generates a hypothetical document (may be factually wrong) which is encoded into a dense vector by a contrastive encoder; real documents are retrieved by similarity to that vector. No model training required.

## M

**MIPS (Maximum Inner Product Search)** — Efficient algorithm for finding the document embedding with highest inner product similarity to a query vector in a large corpus. The search primitive underlying all dense retrieval systems.

**Mr.Tydi** — Multi-lingual dense retrieval benchmark (Zhang et al. 2021) covering Swahili, Korean, Japanese, Bengali, and other languages. Used to evaluate multilingual retrieval in [[gao-2022-hyde]].

## Z

**Zero-shot dense retrieval** — Dense retrieval without any task-specific relevance labels. A model trained on no query-document relevance pairs for the target task must still retrieve relevant documents. Contrast with transfer learning (fine-tune on MS-MARCO, evaluate elsewhere) and fully supervised retrieval.
