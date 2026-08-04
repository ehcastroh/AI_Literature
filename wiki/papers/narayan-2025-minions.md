---
title: Minions — Cost-efficient Collaboration Between On-device and Cloud Language Models
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2502.15964]
supersedes: []
superseded_by: []
expires_when: "Local 3B models can match frontier model performance on data-intensive reasoning without cloud assistance, or cloud inference costs drop to the point where routing/collaboration overhead exceeds its savings"
tags: [local-remote, inference-efficiency, multi-agent, long-context, decomposition, cost-quality-tradeoff]
---

# Minions: Cost-efficient Collaboration Between On-device and Cloud Language Models

Avanika Narayan, Dan Biderman, Sabri Eyuboglu, Avner May, Scott Linderman, James Zou, Christopher Ré. Stanford University / Together AI. arXiv:2502.15964v1 (February 2025).

## Claim

Small on-device LMs (1-8B parameters) can collaborate with frontier cloud LMs to reduce cloud inference costs by 5-30x while preserving 87-97.9% of frontier-only performance on data-intensive reasoning tasks (financial, medical, scientific document QA). The key insight: route the expensive "reading" of long contexts to the local model and route synthesis/orchestration to the cloud model. A naive chat protocol (Minion) achieves high cost savings but leaves a 9.4% performance gap. MinionS closes this gap by having the remote model decompose tasks via code executed locally in parallel. (§1, §5, §6)

## Method

**Cost model** (§3): LocalLM calls are assumed free (ignoring hardware amortization); RemoteLM costs ∝ prefill tokens + α × decode tokens (α ≈ 1-5). Cost savings come from limiting what the remote model reads, not what it generates.

**Minion** (§4): Naive protocol - free-form chat between local and remote models. LocalLM has full context in system prompt; RemoteLM does not. They chat until RemoteLM produces a final answer. Achieves 30.4x cost reduction; recovers 87.0% performance (8B local model). Gap traced to two LocalLM limitations:
- Multi-step instruction following: splitting complex instructions into separate sub-tasks improves accuracy by 56 points.
- Long-context reasoning: performance drops 13% as context grows from <1K to >65K tokens.

**MinionS** (§5): Divide-and-conquer extension. Three-step loop:
1. **Decompose (remote)**: RemoteLM writes a Python function f(context, prev_jobs) that generates a list of job specifications (instruction + context chunk pairs) without reading the full context. Code generation decouples job count from remote model output tokens.
2. **Execute (local, parallel)**: Jobs are batched and executed in parallel by LocalLM. Each job outputs a JSON with explanation, citation, and answer, or abstains. Abstentions are filtered out before sending to remote.
3. **Aggregate (remote)**: RemoteLM synthesizes filtered outputs and either produces a final answer or loops back to step 1.

Context management across rounds: simple retries (carry only RemoteLM's advice) or scratchpads (RemoteLM records what it learned). Scratchpads are slightly more cost-efficient per accuracy point gained.

**Key hyperparameters** (§5.2, §6.3): (1) tasks per round (number of unique instructions), (2) samples per task (parallel generations per {instruction, chunk}), (3) chunk size (pages vs. paragraphs). All three can improve quality at the expense of increased remote cost.

Evaluation: FinanceBench (financial document QA), LongHealth (clinical records QA), QASPER (scientific paper QA). Local models: Llama-3.2-1B/3B/8B, Qwen2.5-3B. Remote model: GPT-4o.

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| Minion cost reduction (avg) | 30.4x over remote-only | 8B local (Llama-3.2) + GPT-4o remote | §1, §4 |
| Minion performance recovery | 87.0% of remote-only baseline | 8B local model, avg across 3 datasets | §4 |
| MinionS performance recovery (8B) | 97.9% of remote-only baseline | Llama-8B + GPT-4o | §6, Table 1 |
| MinionS cost vs remote-only | 18.0% of remote-only cost (~5.5x savings) | Llama-8B + GPT-4o | §6, Fig. 2 |
| MinionS performance recovery (3B) | 93.4% of remote-only baseline | Llama-3B + GPT-4o | §6, Table 1 |
| MinionS cost (3B) | 16.6% of remote-only cost | Llama-3B + GPT-4o | §6 |
| Historical feasibility threshold | July 2024 (gpt4-turbo + Llama-3.1) | Retrospective analysis | §6.2, Table 3 in Appendix |
| Scaling tasks (1→16) | +14 accuracy points | More sub-tasks per round | §6.3 |
| Scaling samples (1→32) | +7.4 accuracy points, >16 hurts | Repeated sampling per task | §6.3 |
| Scaling chunks (100→5 pages/chunk) | +11.7 accuracy points, +2.41x cost | Finer chunking | §6.3 |
| Multi-step instruction split | +56 accuracy points | Llama-3.2-3B, simple extraction | §4, Fig. 3 |
| Long-context degradation | -13% as context grows <1K→>65K | Llama-3.2-3B | §4, Fig. 3 |
| MinionS vs RAG on FinanceBench | Similar cost-quality; RAG misses cross-section signals | BM25 + embedding RAG | §6.5.1 |
| MinionS vs RAG on summarization | MinionS >> RAG; GPT-4o parity | BooookScore, Claude-3.5 evaluation | §6.5.2 |
| Token efficiency (7-8B vs 1B) | 1.53x more compressed representations | Remote prefill token count | §6.2 |

## Boundary conditions

- **Local model cost assumed zero**: energy consumption, hardware amortization, and thermal constraints on edge devices are not modeled. In practice these are non-zero, especially for sustained 8B inference on mobile hardware (§3).
- **Privacy not addressed**: LocalLM sends filtered job outputs to RemoteLM. Sensitive local data (medical, financial) still reaches the cloud, filtered by LocalLM's abstain decision. Privacy techniques (Siyan et al. 2024) can be combined with MinionS but are not studied here (§2 Related work note).
- **Latency analysis is theoretical only**: empirical latency experiments deferred to future work. Analytical bound: at most 5x latency increase vs. remote-only in best cases (Appendix C). Real-world latency depends on local hardware throughput and network conditions.
- **Models trained independently**: LocalLM and RemoteLM are not trained to collaborate. Communication overhead is higher than co-trained systems; information is exchanged in natural language, not compressed representations. Future direction acknowledged (§7).
- **Feasibility threshold is recent (mid-2024)**: MinionS requires LocalLMs capable of instruction following and basic extraction on short chunks. Systems before July 2024 (gpt4-turbo + Llama-3.1) would have produced unacceptable quality (§6.2).
- **Diminishing returns at >16 samples**: repeated local sampling beyond 16 samples per task introduces noise that the RemoteLM cannot effectively distill, degrading performance (§6.3).
- **Task type matters**: RAG outperforms MinionS on structured retrieval tasks (FinanceBench specific-fact lookup) but MinionS outperforms RAG on tasks requiring reasoning over dispersed information (summarization, longitudinal records) (§6.5).

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Remote model writes code to generate jobs (not the jobs directly) | Generating jobs directly would cost O(num_jobs × job_spec_tokens) remote output tokens; code generation costs O(1) and decouples job count from remote cost (§5.1) | Direct job enumeration: prohibitively expensive for large contexts (e.g., 100-page documents → 100 jobs × ~50 tokens each = 5K remote tokens per round) | Assuming the bottleneck is remote inference speed, not remote token cost; the code abstraction is specifically about token budget |
| LocalLM abstains on irrelevant {instruction, chunk} pairs | Many job-chunk combinations will be irrelevant; forcing LocalLM to produce an output for every pair floods RemoteLM with noise, degrading aggregation quality (§5) | No abstention: remote model sees N_jobs responses regardless of relevance; aggregation quality degrades | Treating all jobs as equally likely to contain relevant information |
| Chunk context at job execution time (on-device), not at job generation time | RemoteLM never reads the full context; chunking must be done locally using the code function f(c, T). Chunking strategy (page vs. paragraph) is a hyperparameter controlled by the generated code (§5.1) | Remote-side chunking: requires sending the full context to the cloud, defeating the purpose of local-remote collaboration | Assuming the remote model must see at least a document map or index to generate jobs - it doesn't; it writes generic chunking logic |
| Scratchpad > simple retry for multi-round context | Simple retry carries only the last RemoteLM instruction, losing accumulated evidence; scratchpad allows RemoteLM to record what it already learned, enabling targeted follow-up queries (§5, §6.4) | Simple retry across all rounds: RemoteLM repeats similar queries without learning from prior rounds | Treating sequential rounds as independent calls; the value of multi-round communication is in accumulating evidence, not repetition |

## Not stated in source

- Energy and thermal cost of sustained 8B local inference not measured (acknowledged as limitation in §3).
- MinionS not evaluated on coding/reasoning tasks (only document QA); generalization to code repository analysis or mathematical reasoning unknown.
- How context compression quality (information bottleneck) varies by task domain not characterized.
- The abstain threshold for LocalLM is not tuned; using a fixed pworker system prompt. Effect of abstain sensitivity on downstream quality not ablated.
- No study of failure modes: when does MinionS confidently produce a wrong answer (hallucination in the local→remote path)?

## Relations

- Supports: [[park-2023-generative-agents]] (both study multi-agent computation with orchestration; MinionS provides a practical asymmetric collaboration protocol that agent systems like Generative Agents could adopt for cost-efficient long-document processing)
- Supports: [[jiang-2023-longllmlingua]] (complementary: LongLLMLingua compresses what's sent to the remote LLM; MinionS routes long-context reading entirely to local to reduce remote token consumption - both reduce remote cost, different mechanisms)
- Supports: [[jitkrittum-2025-uniroute]] (both address inference efficiency; MinionS adds a collaboration layer on top of routing - one selects which model handles the whole task, the other splits the task between models)
- Contradicts: -
- Superseded by: -

## Expiry

When local 3B models can reliably handle full-document reasoning without remote assistance (no performance gap), or when frontier model API costs drop below the point where MinionS overhead savings are meaningful. Re-verify when: on-device LM capabilities benchmarks (financial/medical QA at 3B scale) are updated.
