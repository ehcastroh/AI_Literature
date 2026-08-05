---
title: A Survey of Context Engineering for Large Language Models
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2507.13334]
supersedes: []
superseded_by: []
expires_when: "Taxonomy will become outdated as new context engineering techniques emerge. The comprehension-generation asymmetry claim should be reassessed as new frontier models (post-July 2025) are evaluated. Re-verify when a later comprehensive survey supersedes this one."
tags: [survey, context-engineering, RAG, memory, prompt-engineering, multi-agent, tool-use, long-context]
---

# A Survey of Context Engineering for Large Language Models

Lingrui Mei*, Jiayu Yao*, Yuyao Ge*, Baolong Bi*, et al. (14 authors). ICT/CAS, UC Merced, U Queensland, Peking U, Tsinghua U, UCAS. arXiv:2507.13334v2, July 2025. (*equal core contributors)

## Claim

This survey introduces "Context Engineering" as a formal discipline superseding prompt engineering: the systematic optimization of information payloads (context) for LLMs, treating the context C as a dynamically assembled structured composition of components rather than a static string. Primary finding: a fundamental **comprehension-generation gap** exists — augmented models demonstrate remarkable proficiency in understanding complex contexts but pronounced limitations in generating equally sophisticated long-form outputs. The survey covers 1400+ papers and provides a two-level taxonomy. (§Abstract, §8 Conclusion)

## Formal Definition (§3.1)

**Standard model**: LLM parameterized by θ generates output Y given context C: Pθ(Y|C) = ∏ Pθ(yt|y<t, C)

**Context Engineering re-formulation**: Context C is a dynamically structured assembly:
```
C = A(c1, c2, ..., cn)
```
where the six component types are:
- **cinstr**: system instructions and rules
- **cknow**: external knowledge (RAG, knowledge graphs)
- **ctools**: available tool definitions and signatures
- **cmem**: persistent information from prior interactions (memory)
- **cstate**: dynamic state of user, world, or multi-agent system
- **cquery**: immediate user request

**Optimization problem**: find the ideal set of context-generating functions F = {A, Retrieve, Select, ...}:
```
F* = argmax_F E_τ~T [Reward(Pθ(Y|CF(τ)), Yτ*)]
subject to |C| ≤ Lmax
```

**Information-theoretic retrieval criterion**: Retrieve* = argmax I(Y*; cknow | cquery) — maximize mutual information with target answer, not just semantic similarity.

## Prompt Engineering vs. Context Engineering (§3.1, Table 1)

| Dimension | Prompt Engineering | Context Engineering |
|---|---|---|
| Context model | C = static string | C = A(c1,...,cn) dynamic assembly |
| Optimization target | argmax_prompt Pθ(Y\|prompt) | F* = argmax_F E[Reward(...)] |
| State | Primarily stateless | Inherently stateful (cmem, cstate) |
| Information | Fixed content in prompt | Maximized under |C| ≤ Lmax |
| Error analysis | Manual iterative refinement | Systematic component-level debugging |
| Complexity | Manual or automated string search | System-level F = {A, Retrieve, Select,...} optimization |

## Taxonomy

### Foundational Components (§4)

1. **Context Retrieval and Generation** (§4.1): How to source appropriate context.
   - Prompt engineering and context generation (chain-of-thought, few-shot, instruction following)
   - External knowledge retrieval (dense retrieval, knowledge graphs)
   - Dynamic context assembly

2. **Context Processing** (§4.2): How to transform and optimize acquired context.
   - Long context processing (extended attention, position encoding, sliding windows)
   - Contextual self-refinement and adaptation (iterative improvement, self-critique)
   - Multimodal context (text, images, audio, video integration)
   - Relational and structured context (graphs, tables, structured data)

3. **Context Management** (§4.3): How to organize and manage context efficiently.
   - Fundamental constraints (O(n²) attention cost, KV cache limits)
   - Memory hierarchies and storage architectures (working memory, episodic, semantic, procedural)
   - Context compression (token pruning, summarization, density maximization)

### System Implementations (§5)

1. **Retrieval-Augmented Generation** (§5.1): Modular RAG, agentic RAG (planning + reflection), graph-enhanced RAG (GraphRAG, LightRAG).

2. **Memory Systems** (§5.2): Architectures for persistent state across interactions; memory-enhanced agents; evaluation and challenges (LLM statelessness is fundamental barrier).

3. **Tool-Integrated Reasoning** (§5.3): Function calling mechanisms; tool-integrated reasoning chains; agent-environment interaction. GAIA benchmark: humans 92%, advanced models 15%.

4. **Multi-Agent Systems** (§5.4): Communication protocols (MCP, A2A, ACP, ANP), orchestration mechanisms, coordination strategies.

## Central Finding: Comprehension-Generation Gap (§7.1.2)

The survey identifies this asymmetry as the "most critical challenge" in the field: augmented LLMs demonstrate "remarkable proficiency in understanding complex contexts" but exhibit "pronounced limitations in generating equally sophisticated, long-form outputs." This manifests in: long-form output coherence, factual consistency across thousands of tokens, planning sophistication. The authors identify this as a distinct research priority, separate from scaling or retrieval challenges. (§Abstract, §7.1.2, §8)

## Open Challenges (§7)

| Challenge | Locator |
|---|---|
| No unified theoretical foundations for context engineering | §7.1.1 |
| Comprehension-generation gap | §7.1.2 |
| O(n²) attention scaling prohibitive for ultra-long contexts | §7.1.2, §7.4.1 |
| Multi-modal alignment and consistency across modalities | §7.1.3 |
| Automated context assembly (intelligent F optimization) | §7.2.4 |
| Large-scale multi-agent coordination (hundreds/thousands of agents) | §7.3.2 |
| Agent communication protocol fragmentation (MCP, A2A, ACP, ANP) | §7.3.2 |
| Safety/security in deployed context systems | §7.4.2 |

## Boundary Conditions

- **Survey only; no new method**: no empirical benchmarking or novel technique introduced.
- **Coverage through July 2025**: 1400+ papers; rapidly evolving field means some recent work may be missed.
- **Taxonomy is author-imposed**: the "context engineering" framing is proposed by this survey; the community has not uniformly adopted it. Prompt engineering, RAG, memory systems are prior community terms.
- **Comprehension-generation gap claim is observational**: diagnosed from reviewing the literature, not from systematic controlled experiment across models. Applies to models as of July 2025.

## Decision Knowledge

- The key conceptual shift: treating context as a system of composable, optimizable functions (C = A(c1,...,cn)) rather than a string to be hand-crafted enables modular debugging, principled optimization, and component-level evaluation. This reframing alone changes how to approach system design.
- The information-theoretic retrieval criterion (maximize I(Y*; cknow | cquery)) distinguishes good retrieval from mere semantic similarity — a retrieval system that returns semantically similar but information-redundant context is suboptimal under this criterion.
- Multi-objective optimization (multiple scores) finding from AlphaEvolve connects here: [[alphaevolve-coding-agent]] independently found that diverse optimization criteria create structurally diverse programs; the same principle applies to diverse context components.

## Not Stated in Source

- No quantitative evidence that the "comprehension-generation gap" is causal rather than correlational — it may reflect evaluation methodology biases (understanding is easier to measure than generation quality).
- The taxonomy boundary between "Context Processing" and "Context Management" is not crisp; compression techniques appear in both.
- Agent communication protocol names (MCP, A2A, ACP, ANP) are mentioned but not compared on a common capability axis.

## Relations
- Cluster: [[retrieval-and-context]]

- Supersedes (in scope): [[automatic-prompt-optimization-survey]] (prompt optimization is subsumed as one component: Context Retrieval/Generation §4.1; Context Engineering is the broader discipline)
- Contextualizes: [[longllmlingua-prompt-compression]] (prompt compression = Context Management §4.3.3)
- Contextualizes: [[zero-shot-dense-retrieval]] (RAG = System Implementation §5.1)
- Contextualizes: [[generative-agents-human-simulacra]] and [[reflexion-verbal-reinforcement-learning]] (memory systems = §5.2; self-refinement = §4.2.2)
- Contextualizes: [[minions-device-cloud-collaboration]] (local-remote multi-agent = Multi-Agent Systems §5.4)
- Contradicts: -
- Superseded by: -
