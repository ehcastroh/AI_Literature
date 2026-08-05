---
title: Retrieval and Context Management
type: reference
audience: both
created: 2026-08-05
verified: 2026-08-05
confidence: VERIFIED
tags: [retrieval, context-engineering, prompt-compression, long-context, RAG]
---

# Retrieval and Context Management

How do you get the right information into the context window at the right time, in the right form? This cluster covers the full pipeline from retrieval to compression to context assembly.

## Papers in this cluster

| Paper | Contribution |
|---|---|
| [[zero-shot-dense-retrieval]] | Zero-shot dense retrieval via hypothetical document embeddings (HyDE). No relevance labels required. |
| [[focused-transformer-context-scaling]] | Crossbatch training to keep attention focused on relevant tokens as context length grows. |
| [[longllmlingua-prompt-compression]] | Question-aware prompt compression using contrastive perplexity; addresses lost-in-the-middle degradation. |
| [[context-engineering-survey]] | Survey defining context engineering as a formal discipline: C = A(c1,...,cn). Maps RAG, memory, tools, and multi-agent as instances. |
| [[context-of-context-engineering]] | Position paper on the history and scope of context engineering; entropy-reduction framing. |
| [[prompts-to-multi-agent-architecture]] | Enterprise practitioner framing: four-level pyramid (PE → CE → IE → SE); five context quality criteria. |

## Key tension

Retrieval papers optimize for what to retrieve; context engineering papers ask what to do with it once retrieved. The comprehension-generation gap — models understand complex contexts better than they generate equivalent outputs — is the open problem connecting both sides. See [[context-engineering-survey]].

## Related clusters

- [[prompt-optimization]] — prompts are one component of a context pipeline
- [[inference-efficiency]] — context size directly drives inference cost
- [[agents-and-memory]] — agents manage context across multi-turn interactions
