---
title: "Context Engineering 2.0: The Context of Context Engineering"
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2510.26493]
supersedes: []
superseded_by: []
expires_when: "Primarily a conceptual/position paper; core historical framing does not decay. The 4-era model becomes outdated when Era 3.0 (human-level intelligence) is reached."
tags: [context-engineering, survey, position-paper, history, HCI, agents, conceptual]
---

# Context Engineering 2.0: The Context of Context Engineering

Qishuo Hua, Lyumanshan Ye, Dayuan Fu, Yang Xiao, Xiaojie Cai, Yunze Wu, Jifan Lin, Junfei Wang, Pengfei Liu. SII / GAIR / SJTU. arXiv:2510.26493v1, October 2025.

## Claim

This is a position paper. No novel method or empirical result. Contribution: argues that context engineering traces its roots to 1990s HCI and ubiquitous computing — not just the LLM era — and frames the field as an ongoing human-machine cognitive gap reduction process driven by machine intelligence level. Proposes a four-era evolutionary model and an entropy-reduction lens for understanding context engineering. Directly complements [[context-engineering-survey]] (cited) by providing historical depth rather than technical taxonomy. (§1, §2)

## Formal Definition (§2.1)

**Context** (based on Dey 2001): union of characterization information across all relevant entities for a given user-application interaction:
```
C = ∪_{e ∈ E_rel} Char(e)
```
Entities include user, application, environment, external tools, memory modules, model service.

**Context Engineering**: CE: (C, T) → f_context, where:
```
f_context(C) = F(ϕ1, ϕ2, ..., ϕn)(C)
```
Operations ϕi include: collecting context, storing/managing, representing in interoperable format, handling multimodal inputs, integrating past context ("self-baking"), selecting relevant elements, sharing across agents, adapting dynamically. This is explicitly broader than the Mei et al. optimization framing — no hard constraint on |C| ≤ Lmax.

## Four-Era Model (§2.2)

| Era | Period | Machine Intelligence | Context Role | Human-AI Relation |
|---|---|---|---|---|
| 1.0 | 1990s-2020 | Primitive computation; structured inputs only | Context as translation (must be pre-processed into rigid formats) | Human is active encoder; machine is passive executor |
| 2.0 | 2020-present | LLMs; natural language; ambiguity tolerance | Context as instruction; agents reason over gaps | Human-agent collaboration; moderate naturalness |
| 3.0 | Future | Human-level intelligence | Context as scenario; social cues, emotional states | Natural collaboration; AI as peer |
| 4.0 | Speculative | Superhuman intelligence | Context as world; machines construct contexts proactively | Roles inverted; machines reveal latent human needs |

**We are currently in Era 2.0, transitioning toward Era 3.0.** (Fig. 1)

## Entropy Reduction Lens (§1)

Core thesis: Context engineering is "a process of entropy reduction." Machines cannot fill gaps during communication the way humans do (using shared knowledge, emotional cues, situational awareness). Context engineering is the work of "preprocessing" high-entropy human intentions into low-entropy machine-processable representations. As machine intelligence increases, this preprocessing effort decreases — hence Era 4.0 machines could handle maximal entropy directly.

## Historical Argument (§3)

- **Era 1.0 examples**: Context Toolkit (1999), Cooltown, ContextPhone. Core mechanisms: sensor fusion, rule-based triggers. Context modalities: location, identity, activity, device state.
- **Era 2.0 examples**: ChatGPT, LangChain, AutoGPT, Letta. Core mechanisms: prompting, RAG, chain-of-thought, memory agents. Context modalities: token sequences, retrieved documents, tool APIs, user history.
- The key shift: Era 1.0 required explicit context translation (all context must be machine-readable); Era 2.0 allows ambiguity and implicit inference.

## Design Considerations (§4-6)

Three dimensions covered:
1. **Context Collection and Storage** (§4): Era 1.0 used sensor fusion; Era 2.0 uses RAG/tool APIs; future "human-level context ecosystem" would match human associative memory.
2. **Context Management** (§5): Textual processing, multimodal processing, layered memory architecture (working → episodic → semantic → procedural), context isolation (namespace separation between agents), context abstraction (summarization for long horizons).
3. **Context Usage** (§6): Intra/cross-system context sharing, context selection for understanding, proactive user need inference (going beyond explicit requests), lifelong context preservation and update.

## Boundary Conditions

- **No empirical evaluation**: this is a position/conceptual paper. All claims are argumentative, not experimentally validated.
- **Era 3.0 and 4.0 are speculative**: no specific timeline for human-level intelligence, and the superhuman "god's eye view" is explicitly labeled speculative.
- **The 4-era model is the authors' framework**: not a community consensus taxonomy. Other community framings exist (e.g., Mei et al.'s foundational-components + system-implementations taxonomy).

## Decision Knowledge

- The entropy-reduction framing has a concrete implication: the "effort" in context engineering is inversely proportional to machine intelligence. Systems with better reasoning require less carefully-engineered context. This predicts that as frontier models improve, good context engineering will shift from structured formatting to higher-level goal specification.
- "Self-baking" (integrating past context into future context) is introduced as a distinct operation — distinct from retrieval (finding external context) and compression (reducing existing context). It describes how agents build up a personal knowledge base from interaction history.

## Not Stated in Source

- The paper does not compare the entropy-reduction definition to information-theoretic formulations from Mei et al. (mutual information maximization). These are complementary framings but the relationship is not analyzed.
- No quantitative study of how "human-AI interaction cost" (y-axis in Fig. 1) is actually measured or decreasing across eras.

## Relations
- Cluster: [[retrieval-and-context]]

- Extends: [[context-engineering-survey]] (same topic; this paper adds historical framing and philosophical lens; Mei et al. adds technical taxonomy and comprehension-generation gap finding; the two are complementary, not contradictory)
- Contradicts: -
- Superseded by: -
