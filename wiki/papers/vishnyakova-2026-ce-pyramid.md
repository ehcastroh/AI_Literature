---
title: "Context Engineering: From Prompts to Corporate Multi-Agent Architecture"
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2603.09619]
supersedes: []
superseded_by: []
expires_when: "Position/practitioner paper; the four-level pyramid model is the author's proposal, not an empirical finding, so it does not decay by benchmark. The enterprise survey data (Deloitte 2026, KPMG 2026) age quickly — re-evaluate governance gap claims when 2027+ enterprise adoption data become available."
tags: [context-engineering, position-paper, enterprise, multi-agent, governance, practitioner]
---

# Context Engineering: From Prompts to Corporate Multi-Agent Architecture

Vera V. Vishnyakova. HSE University, Moscow. arXiv:2603.09619v2, March 2026.

## Claim

This is a practitioner position paper. No novel empirical result or formal method. Contribution: proposes a four-level cumulative pyramid maturity model of agent engineering — Prompt Engineering → Context Engineering → Intent Engineering → Specification Engineering — arguing that each level is a necessary but insufficient foundation for the one above, and that context quality is the missing governance layer in enterprise agentic deployment. (§17)

The paper introduces five production-grade context quality criteria, a four-mode context degradation taxonomy (context rot), and uses the Klarna agent case as a dual-deficit diagnostic — context deficit plus intent deficit — to ground the argument. (§9, §12)

## Three Levels of Agentic Deployment (§4)

Useful framing before the framework:

| Level | Description | Context owner |
|---|---|---|
| L1: LLM as Service | GPT/Claude/Gemini accessed via API/chat. Query→response mode. No tools or orchestration. | User |
| L2: Vendor Agentic Products | Deep Research, Computer Use, Manus. Vendor builds orchestrator + tools + policies. Hidden from user. | Vendor |
| L3: Enterprise Agents | Company builds entire agentic stack. Full ownership. Context engineering becomes a critical discipline. | Operator/company |

Key distinction: "The LLM did not become an agent; it became a component of one." The LLM is the intellectual engine; the agent is the software construct (orchestrator + tools + memory + policies) that calls it. (§3)

## The Four-Level Pyramid (§17)

Each level subsumes the previous as load-bearing infrastructure. Removing any lower tier collapses the ones above it.

| Level | Discipline | Question answered | Unit of design |
|---|---|---|---|
| 1 | Prompt Engineering (PE) | How to ask? | Individual query |
| 2 | Context Engineering (CE) | What does the agent know, see, and remember at the moment of action? | Context pipeline |
| 3 | Intent Engineering (IE) | What should the agent pursue? What may it sacrifice? | Trade-off hierarchy |
| 4 | Specification Engineering (SE) | What does the corporation demand at scale? | Machine-readable policies |

"Whoever controls the agent's context controls its behavior; whoever controls its intent controls its strategy; whoever controls its specifications controls its scale." (§17)

Independent convergence: Feroz (2026) and Reddy KS (2026) independently proposed the same four disciplines in early 2026, treated as evidence the taxonomy reflects actual field structure. (§17)

## Five Context Quality Criteria (§9)

The author's proposed production-grade standard; described as "working, not canonical":

1. **Relevance** — only what is necessary for the current step. Excessive context causes lost-in-the-middle degradation, distraction, and cost.
2. **Sufficiency** — everything needed to decide without guesswork. Insufficient context causes hallucination at the architectural level.
3. **Isolation** — in MAS, each sub-agent sees only its own context slice. Leakage between roles is a controllability and security problem. Tomasev et al. (2026) formalize this as privilege attenuation with Delegation Capability Tokens.
4. **Economy** — minimum tokens and context reassemblies. Manus (2025): cached vs uncached token cost ~10×. Compression + caching + selective loading → 5-10× cost reduction. Context architecture is unit economics.
5. **Provenance** — every context element traceable to source (system, time, trust level). Required for audit, debugging, and regulatory compliance.

## Context Rot Taxonomy (§9, Breunig 2025)

Four degradation modes (from forthcoming O'Reilly book by Breunig):

- **Context poisoning** — a hallucination or error enters context and propagates; agent accepts the false fact and builds strategy on it.
- **Context distraction** — at long contexts, model relies on accumulated history instead of trained knowledge; reproduces past actions rather than synthesizing new plans. Observed by Gemini 2.5 team past 100,000-token threshold.
- **Context confusion** — irrelevant information in window degrades response quality; model uses everything given even when it hinders.
- **Context clash** — contradictory data accumulate incrementally; study (Microsoft/Salesforce, cited in Breunig 2025) showed 39% quality drop when a single prompt was split into sequential turns.

## Context as Operating System (§6)

Core framing: context is the agent's OS, not a passive input buffer. It manages memory (retain/evict), allocates resources (which data accessible to which sub-agent), isolates processes, and provides a unified interface to external systems.

**JIT knowledge logistics** — "What to include, when to supply it, in what form, for how long, and for which sub-agent." Lean manufacturing analogy: just-in-time, not bulk delivery.

**LangChain's four operations**: write (record new knowledge), select (retrieve relevant info), compress (condense history without losing meaning), isolate (restrict data visibility between sub-agents). (§8)

## Intent Engineering (§14)

Context engineering answers what the agent knows. Intent engineering answers what the agent should pursue. Addresses the classical principal-agent problem: agents optimize measurable metrics, not true goals.

If corporate intent is not formalized, a proxy is optimized instead: call cost, response speed, or task completion rate, rather than customer loyalty, brand perception, or long-term revenue.

"Context without intent is noise." (Huryn 2026)

## Specification Engineering (§15)

Extends IE to the multi-agent-system level. Creates a machine-readable corpus of corporate policies, quality standards, and operational procedures — what previously lived in PDF regulations and verbal agreements.

**Specifications as constitution**: each agent applies the relevant article at the right time within bounds set before its launch. Like ERP for business processes: ERP runs on codified procedures; MAS requires the same formalization.

**TELUS case**: 70,000 employees independently configured 21,000 customized AI copilots, processing 2 trillion tokens in 2025. What prevents behavioral divergence at this scale? Specification engineering is the open question the case leaves unanswered.

## Enterprise Data (§10-11)

- **Deloitte 2026** (N=3,235, director–C-suite, 24 countries): 75% plan agentic AI deployment within 2 years; only 21% have mature AI-agent governance model; 84% have not redesigned roles around AI.
- **KPMG 2026** (N=130, US C-suite, revenue $1B+): agent deployment 11% (Q1 2025) → 42% (Q3 2025) → 26% (Q4 2025, pilots → professionalizing); average AI budget $124M/year; 67% would maintain spending in a recession.
- **Gartner 2025**: 40% of enterprise applications will integrate AI agents by end of 2026 (from <5% in 2025); agentic AI to drive ~30% of enterprise application software revenue by 2035.

## Klarna Case: Dual Deficit Diagnostic (§12)

Klarna AI agent (Q3 2025): handled 2/3 of customer inquiries (equivalent to 853 FTEs, ~$60M savings). CEO acknowledged in May 2025 that service quality had suffered; Forrester called it an "AI overpivot." Company began returning to human hiring.

**Dual deficit analysis**:
1. **Context deficit**: agent lacked access to customer history, brand tone of voice, loyalty policies. Responses technically correct but formulaic — next-generation IVR.
2. **Intent deficit**: even with perfect context, corporate intent (cost-savings vs loyalty balance, target NPS, trade-off hierarchy) was never formalized and encoded. Agent optimized cost per token, not customer relationship value.

"Context without intent is noise." Context engineering resolves one dimension of the contradiction; intent engineering resolves the other.

## Four Memory Types (§16)

| Type | Storage | Cost | Persistence |
|---|---|---|---|
| Working memory | Context window | Highest per token | Ephemeral (session) |
| Episodic memory | External storage (logs/summaries) | Lower | Cross-session |
| Semantic memory | Vector stores (RAG) | Variable | Long-term |
| Procedural memory | Model weights | Fixed | Changes only via fine-tuning |

Key operational issue: operators "add context" without understanding which type is in play, conflating $0.003/1K token working memory with $70/month cloud vector storage. Memory architecture decisions are increasingly made by cloud providers before operators arrive — AWS/Azure/GCP embed assumptions about memory, orchestration, and access control into the agentic stack.

## Open Caveats (§7 — author's own)

The author explicitly acknowledges:
- The novelty question: "Is context engineering not simply a rebranding of RAG + memory + orchestration?" No formal proof that the whole exceeds the sum of parts.
- **No convincing prioritization mechanism** for source conflicts (policy vs CRM vs agent memory). Ad hoc rules like "policy always overrides CRM" scale poorly.
- **Measurability**: context quality metrics are "experimental territory." KV-cache hit rate and cost are measurable; relevance requires A/B tests with domain experts. This limits disciplinary maturity.

## Boundary Conditions

- **No empirical results**: entirely practitioner/position. All claims are argumentative or drawn from enterprise surveys and vendor documentation, not controlled experiments.
- **Scope is text-based LLM interactions**: multimodal applies in principle, not analyzed.
- **Framework is the author's proposal**: the four-level pyramid and five criteria are not field consensus. Three authors independently proposed similar frameworks in early 2026 — convergence indicates emerging consensus but not established standard.
- **Enterprise survey data are vendor-commissioned or broad-scope**: Deloitte and KPMG data are directionally informative but not controlled research.

## Decision Knowledge

- The "context as OS" framing has a concrete design implication: if context is infrastructure, then the question of who controls context is a governance and ownership question, not just a technical one. Platform lock-in (choosing AWS/Azure/GCP) predetermines large parts of the context architecture before any engineering work begins.
- The dual-deficit framework (context + intent) is a useful diagnostic: "Is the agent failing because it doesn't have the right information, or because it doesn't know what to optimize?" These require different fixes — CE vs IE respectively.
- Economy criterion (context as unit economics): inference cost without compression grows super-linearly with agent steps. Context architecture is not optional optimization; it is the condition of production viability.

## Not Stated in Source

- The paper does not compare its five criteria to [[mei-2025-context-engineering-survey]]'s formal optimization framing or [[hua-2025-context-engineering-2]]'s entropy-reduction lens; the three frameworks are complementary but not cross-referenced.
- The author's own multi-agent compliance system is mentioned (NER detector false-positives problem, strict filtering between sub-agents) but not described in depth; claimed it is currently being tested with no published results.

## Relations

- Extends: [[mei-2025-context-engineering-survey]] (same core topic; this paper adds enterprise/governance layer and the four-level pyramid; Mei et al. adds formal optimization definition and comprehension-generation gap)
- Extends: [[hua-2025-context-engineering-2]] (both frame context engineering as more than prompting; Hua uses historical/philosophical lens; Vishnyakova uses enterprise practitioner lens)
- Complements: [[park-2023-generative-agents]] (both treat memory as multi-tiered infrastructure, independently; Park's four-type taxonomy and Vishnyakova's four-type taxonomy are structurally similar)
- Contradicts: -
- Superseded by: -
