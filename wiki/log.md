# Activity Log

Chronological record of papers added, summaries written, and wiki updates.

---

## 2026-08-04 - ingest: choi-2026-ippg
- Source: raw/2604.02492v1.pdf
- Read: full (§1 Intro, §2 Related work incl. modality bias research, §3.1 cost formulation + tokenization math, §3.2 IPPg pipeline, §4.1-4.5 five datasets, §5.1-5.3 results + error analysis all datasets, §5.3 rendering ablation, §6 Conclusion + future directions)
- Priors that died: none - no prior. New: tokenization scheme is the decisive IPPg variable — OpenAI tile-based tokenization means adding whitespace often costs zero additional image tokens (full text savings), while Claude pixel-linear tokenization makes IPPg systematically more expensive; rendering parameters (font/color/size) shift accuracy by 10-30pp and should be treated as hyperparameters not defaults — dark green text is universally effective; CoSQL SELECTOR stage at 24K tokens/query for GPT-4.1 baseline is an artifact of model-specific context handling, not inherent to the task; vision-language models cannot reliably trace foreign key relationships from visual schemas regardless of model scale (27 universal failures in CoSQL); IPPg code is proprietary with no public release.
- Wrote: wiki/papers/choi-2026-ippg.md
- Index: row added
- Glossary: no new field-standard terms (IPPg is paper-specific; "image prompt packaging" not yet community vocabulary)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 19/19 ingested — corpus complete

## 2026-08-04 - ingest: vishnyakova-2026-ce-pyramid
- Source: raw/2603.09619v2.pdf
- Read: full (§1 Intro, §2-4 PE and agentic levels, §5 tasks PE wasn't designed for, §6-8 CE definition + architecture, §7 author's caveats, §9 five quality criteria + context rot taxonomy, §10-11 economics + governance gap, §12 Klarna case, §13 state engineering, §14 intent engineering, §15 specification engineering, §16 agent memory types, §17 four-level pyramid, §18 conclusion)
- Priors that died: none - no prior. New: "context rot" taxonomy (poisoning/distraction/confusion/clash) from Breunig 2025 — names four failure modes not in other CE papers; KPMG data shows agent deployment peaked at 42% Q3 2025 then pulled back to 26% Q4 as pilots shifted to production — adoption fatigue is documented; Deloitte: only 21% of enterprises have mature AI-agent governance despite 75% planning deployment; Manus 2025: 5-10× cost reduction from compression+caching+selective loading is an empirical production claim; the four-level pyramid is independently proposed by multiple authors in early 2026 — convergent signal; source conflict prioritization (policy vs CRM vs agent memory) has no elegant industry solution as of March 2026.
- Wrote: wiki/papers/vishnyakova-2026-ce-pyramid.md
- Index: row added
- Glossary: no new field-standard terms; "context rot" and "intent engineering" are emerging but not yet canonical
- Contradictions: none (three CE papers in corpus — Mei/Hua/Vishnyakova — are complementary angles: formal optimization, historical, and enterprise practitioner)
- Confidence: VERIFIED
- Inventory after: 18/19 ingested

## 2026-08-04 - ingest: moslem-2026-routing-survey
- Source: raw/2603.04445v2.pdf
- Read: full (§1 Intro + conceptual framework, §2-7 all six paradigms incl. representative methods, §8 Multimodal routing, §9 Evaluation + benchmarks + metrics, §10 Multidimensional synthesis + gap analysis, §11 Conclusion + open challenges; Table 1 design-space matrix; Table 2 consolidated method summary)
- Priors that died: none - no prior. New: production routing systems are inherently multidimensional and combine multiple paradigms — the survey's core argument over clean taxonomy; verbalization-based confidence is consistently unreliable (probe-based or cascade self-verification are alternatives); no current method pairs response-level signals with online adaptation (identified structural gap); GAPG-style intrinsic routing via post-training is entirely absent from this survey's taxonomy; GreenServ uses GPU energy consumption (not cost proxies) as the routing reward — 31% energy reduction + 22% accuracy gain vs random routing.
- Wrote: wiki/papers/moslem-2026-routing-survey.md
- Index: row added
- Glossary: +model cascading; updated LLM routing entry
- Contradictions: none (GAPG [[fang-2025-gapg]] and Minions [[narayan-2025-minions]] cover paradigms absent from this survey's scope — noted in Not Stated)
- Confidence: VERIFIED
- Inventory after: 17/19 ingested

## 2026-08-04 - ingest: chen-2026-cpo
- Source: raw/2602.01711v1.pdf
- Read: full (§1 Intro, §3.1-3.2 Problem Formulation, §3.3-3.4 Architecture: Stage 1 causal reward learning + Stage 2 causal-guided optimization, §4.5 Results all tables, §4.6 Ablation, §5 Boundary conditions/discussion)
- Priors that died: none - no prior. New: confounding of prompt quality with query difficulty is a structural failure of correlational APO reward models trained on observational data — hard queries induce elaborate prompts spuriously; Stage 2 optimization cost is O(B·R·embedding calls) not O(B·R·LLM calls) because the causal model replaces task LLM calls; Kendall's tau-b max ~0.15 implies the causal reward model is a weak ranker in absolute terms (Stage 2 search still needs multiple rounds); DML Neyman orthogonality makes causal estimates robust to nuisance model misspecification.
- Wrote: wiki/papers/chen-2026-cpo.md
- Index: row added
- Glossary: +Double Machine Learning (DML)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 16/19 ingested

## 2026-08-04 - ingest: hua-2025-context-engineering-2
- Source: raw/2510.26493v1.pdf
- Read: full (§1 Intro, §2 Theoretical Framework, §3 Historical Evolution, §4-6 Design Considerations: collection, management, usage, §7 Applications, §8 Challenges/Future)
- Priors that died: none - no prior. New: "self-baking" (integrating past interactions into future context) introduced as a distinct operation separate from retrieval and compression; the entropy-reduction framing predicts that as machine intelligence grows, context engineering effort decreases — a falsifiable direction; Era 1.0 context engineering (1990s ubiquitous computing) had sensor fusion + rule triggers as core mechanisms, not prompting.
- Wrote: wiki/papers/hua-2025-context-engineering-2.md
- Index: row added
- Glossary: no new terms (four-era model and entropy-reduction framing are conceptual; "self-baking" is paper-specific vocabulary not yet field-standard)
- Contradictions: none (complements [[mei-2025-context-engineering-survey]]; different angles on same topic)
- Confidence: VERIFIED
- Inventory after: 15/19 ingested

## 2026-08-04 - ingest: fang-2025-gapg
- Source: raw/2509.24050v4.pdf
- Read: full (§1 Intro + contributions, §2 Problem Background + limitations, §3 RL formulation + hierarchical rewards + GAPG algorithm all subsections, §4 Experiments main results, §5 Conclusion, §Limitations)
- Priors that died: none - no prior. New: external router cannot judge reasoning difficulty from prompt features because structurally similar prompts differ in difficulty — this is a fundamental failure mode, not a calibration issue; adaptive prompt filtering inherits the cloud budget ratio ρ directly from the optimization constraint (this coupling is non-obvious and theoretically motivated); αa > αc ordering is critical to prevent model from defaulting to always calling cloud; early-stage convergence is slower precisely because joint optimization is harder, not a failure mode.
- Wrote: wiki/papers/fang-2025-gapg.md
- Index: row added
- Glossary: no new terms (GAPG is paper-specific; "group-level policy gradient" is a variant of GRPO, not a standalone field term)
- Contradictions: none (complements [[narayan-2025-minions]] via different approach to same problem; Minions uses external protocol, GAPG trains intrinsic routing — both can be valid depending on deployment constraints)
- Confidence: VERIFIED
- Inventory after: 14/19 ingested

## 2026-08-04 - ingest: mei-2025-context-engineering-survey
- Source: raw/2507.13334v2.pdf
- Read: full (§1 Intro, §3 Why Context Engineering + formal definition, §4 Foundational Components all subsections, §5 System Implementations all subsections, §7 Future Directions all subsections, §8 Conclusion; sampled §6 Evaluation for scope)
- Priors that died: none - no prior. New: comprehension-generation gap named as the field's central challenge (not just a known limitation); information-theoretic retrieval criterion frames RAG as mutual information maximization not semantic similarity; the "context engineering" term is survey-proposed framing, not yet canonical community vocabulary; GAIA benchmark humans 92% vs frontier models 15% is the sharpest quantification of the gap; O(n²) attention scaling is presented as a "prohibitive" barrier, not just a challenge.
- Wrote: wiki/papers/mei-2025-context-engineering-survey.md
- Index: row added
- Glossary: +context engineering
- Contradictions: none (survey subsumes prior papers' topics without contradicting them)
- Confidence: VERIFIED
- Inventory after: 13/19 ingested

## 2026-08-04 - ingest: novikov-2025-alphaevolve
- Source: raw/2506.13131v1.pdf
- Read: full (§1 Intro, §2 Architecture all subsections, §3 Results: matrix multiplication + open math problems + Google infrastructure all 4 subsections, §4 Ablations, §5 Related work, §6 Discussion)
- Priors that died: none - no prior. New: AlphaEvolve is the successor to FunSearch but evolves entire codebases not single functions; meta-prompt co-evolution is an additional database alongside program database; multi-objective optimization improves single-metric performance through program diversity; the 4×4 Strassen improvement only holds over complex-valued fields and the Fawzi rank-47 result (2022) was limited to GF(2) and non-recursive; Borg heuristic was chosen over deep RL specifically for interpretability/debuggability requirements.
- Wrote: wiki/papers/novikov-2025-alphaevolve.md
- Index: row added
- Glossary: no new terms (AlphaEvolve concepts are extensions of existing terms; "LLM-guided evolution" is not yet standardized field-wide vocabulary)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 12/19 ingested

## 2026-08-04 - ingest: gottweis-2025-coscientist
- Source: raw/2502.18864v2.pdf
- Read: full (§Introduction, §System analysis: test-time compute scaling + expert evaluation, §Real-world validations: AML drug repurposing + liver fibrosis + AMR recapitulation, §Discussion, §Conclusion, §Methods: all agent descriptions + ablation analysis)
- Priors that died: none - no prior. New: Meta-review feedback propagates via prompt appending to all agents (no fine-tuning), enabling learning-without-backprop; Evolution agent creates new hypotheses, never modifies existing ones (design choice to protect quality); search tool is essential for novelty assessment (without it: 6.14/10 for known non-novel ideas vs 2.38/10 with search); KIRA6 achieved 18-fold IC50 separation between KG-1a AML line (10 nM) and normal TK6 (180 nM); AMR mechanism recapitulated in 2 days matching concurrent unpublished research.
- Wrote: wiki/papers/gottweis-2025-coscientist.md
- Index: row added
- Glossary: +generate-debate-evolve paradigm
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 11/19 ingested

## 2026-08-04 - ingest: ramnath-2025-apo-survey
- Source: raw/2502.16923v2.pdf
- Read: full (§1 Intro, §2 APO formulation, §3-7 taxonomy all 5 parts, §8 theoretical perspectives, §9 challenges/future directions, §10 conclusion)
- Priors that died: none - no prior. New: PE2 is categorized as "metaprompt design" (§5.3) in this survey's taxonomy, not "feedback-based"; "evil twins" (uninterpretable prompts matching gold-standard performance) are an empirically observed phenomenon that APO must account for.
- Wrote: wiki/papers/ramnath-2025-apo-survey.md
- Index: row added
- Glossary: no new terms (taxonomy terms are survey-specific vocabulary, not field-wide definitions)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 10/19 ingested

## 2026-08-04 - ingest: narayan-2025-minions
- Source: raw/2502.15964v1.pdf
- Read: full (§1 Intro, §2 Related work, §3 Preliminaries, §4 Minion protocol, §5 MinionS protocol, §6 Results all subsections incl. RAG comparison, §7 Discussion)
- Priors that died: none - no prior. New: code generation to decouple job count from remote output tokens is the core cost insight; MinionS only became feasible in July 2024 (gpt4-turbo + Llama-3.1 release); local abstaining is critical to filtering noise before aggregation; scratchpad > simple retry for multi-round.
- Wrote: wiki/papers/narayan-2025-minions.md
- Index: row added
- Glossary: no new terms (MinionS terms are self-explanatory within the paper context)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 9/19 ingested

## 2026-08-04 - ingest: jitkrittum-2025-uniroute
- Source: raw/2502.08773v2.pdf
- Read: full (§1 Intro, §2 Background, §3 Dynamic routing formalization, §4 UniRoute approach, §5 Cluster-based instantiations + excess risk bound, §6 Related work, §7 Experiments)
- Priors that died: none - no prior. New: K-NN routing (Hu et al.) is formally a special case of UniRoute; bilinear LLM×prompt representation enables zero-retraining generalization; routing quality at small validation sample sizes favors UniRoute over K-NN.
- Wrote: wiki/papers/jitkrittum-2025-uniroute.md
- Index: row added
- Glossary: +LLM routing
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 8/19 ingested

## 2026-08-04 - ingest: liu-2023-cdcca
- Source: raw/2312.16279v1.pdf
- Read: full (§1 Intro, §2 Related work, §3 Approach all subsections incl. UTS/AKD/DWC, §4 Experiments, §5 Conclusion)
- Priors that died: none - no prior. New: previous test-time adaptation methods (TENT, CoTTA) actually degrade MLLM performance vs source-only; CD-CCA achieves 99.98% downlink compression while maintaining accuracy gains; optimal UTS mask ratio is 50% (not self-evident).
- Wrote: wiki/papers/liu-2023-cdcca.md
- Index: row added
- Glossary: no new terms added (this paper introduces MLLM-specific systems terms not central to the corpus theme)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 7/19 ingested

## 2026-08-04 - ingest: ye-2023-pe2
- Source: raw/2311.05661v3.pdf
- Read: full (§1 Intro, §2 Background, §3 Method/meta-prompt components, §4 Experiment setting, §5 Results+ablation+case study, §6 Related work, §7 Conclusion; also §A additional analysis)
- Priors that died: none - no prior. New: shortcut learning in prompt optimization is a real failure mode (base-8 heuristic outperforms correct base-8 prompt); hard negative sampling matters; optimized prompts do not generalize cross-model.
- Wrote: wiki/papers/ye-2023-pe2.md
- Index: row added
- Glossary: +automatic prompt engineering (APE)
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 6/19 ingested

## 2026-08-04 - ingest: jiang-2023-longllmlingua
- Source: raw/2310.06839v2.pdf
- Read: full (§1 Intro, §2 Problem formulation, §3 LLMLingua background, §4 LongLLMLingua all subsections, §5 Experiments incl. ablation, §6 Related work, §7 Conclusion/Limitations)
- Priors that died: none - no prior. New: contrastive perplexity (= conditional PMI) as the core fine-grained token importance signal; document reordering is free and helps all baselines; question-aware re-compression overhead is ~2x LLMLingua cost but still net faster end-to-end.
- Wrote: wiki/papers/jiang-2023-longllmlingua.md
- Index: row added
- Glossary: +contrastive perplexity, +lost in the middle, +prompt compression
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 5/19 ingested

## 2026-08-04 - ingest: tworkowski-2023-focused-transformer
- Source: raw/2307.03170v2.pdf
- Read: full (§1 Intro, §2 Related work, §3 Method all subsections, §4 LongLLaMA all subsections, §5 Toy experiments, §6 Limitations)
- Priors that died: none - priors on FoT/LongLLaMA were broadly correct. New: distraction issue formalized as rd ≈ 1/d; crossbatch is differentiable through standard LM loss only (no extra loss); d schedule (start small, grow) is the empirically most sensitive hyperparameter; PE removal from memory keys is the mechanism for context extrapolation, not a side effect.
- Wrote: wiki/papers/tworkowski-2023-focused-transformer.md
- Index: row added
- Glossary: +crossbatch training, +distraction issue, +memory attention layers
- Contradictions: none
- Confidence: VERIFIED
- Inventory after: 4/19 ingested

## 2026-08-04 - ingest: park-2023-generative-agents
- Source: raw/2304.03442v2.pdf
- Read: full (§1-3 Intro/Related/Behavior, §4 Architecture all subsections, §5 Implementation, §6 Controlled evaluation, §7 End-to-end evaluation, §8 Discussion/Ethics)
- Priors that died: none - prior (Park et al., memory stream, reflection, planning) was correct. New: retrieval formula (recency+importance+relevance, all α=1), importance threshold 150 triggers reflection, recursive top-down planning, cost = "thousands of dollars" for 25 agents/2 days.
- Wrote: wiki/papers/park-2023-generative-agents.md
- Index: row added
- Glossary: +memory stream
- Contradictions: none (Reflexion and Generative Agents are complementary; linked as Supports)
- Confidence: VERIFIED
- Inventory after: 3/19 ingested

## 2026-08-04 - ingest: shinn-2023-reflexion
- Source: raw/2303.11366v4.pdf
- Read: full (§1 Intro, §2 Related work, §3 Method, §4 Experiments all subsections, §5 Limitations, §6 Broader impact, Appendix A-B)
- Priors that died: none - prior (Reflexion, verbal RL, episodic memory) was correct. New: three-model architecture detail, Ω is a context budget not quality parameter, WebShop failure, emergent at scale (starchat-beta shows zero gain).
- Wrote: wiki/papers/shinn-2023-reflexion.md
- Index: row added
- Glossary: +episodic memory buffer, +HumanEval, +verbal reinforcement learning
- Contradictions: none (potential future conflict with self-correction critique papers not yet ingested)
- Confidence: VERIFIED
- Inventory after: 2/19 ingested

## 2026-08-04 - ingest: gao-2022-hyde
- Source: raw/2212.10496v1.pdf
- Read: full (§1 Intro, §3 Methodology, §4 Experiments, §5 Analysis, §6 Conclusion, Appendix A.1)
- Priors that died: Pre-read guess was "Self-Consistency Improves Chain of Thought" by Wang et al. Entirely wrong - this is a retrieval paper (HyDE) by Gao et al. from CMU/Waterloo, unrelated to reasoning.
- Wrote: wiki/papers/gao-2022-hyde.md
- Index: row added
- Glossary: +BEIR, +Contriever, +dense retrieval, +Hypothetical Document Embeddings (HyDE), +MIPS, +Mr.Tydi, +zero-shot dense retrieval
- Contradictions: none (corpus empty)
- Confidence: VERIFIED
- Inventory after: 1/19 ingested

## 2026-07-17
- Initialized wiki structure
- 3 PDFs present in `raw/`: `2212.10496v1.pdf`, `2303.11366v4.pdf`, `2304.03442v2.pdf`
