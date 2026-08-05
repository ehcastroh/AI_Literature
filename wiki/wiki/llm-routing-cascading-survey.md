---
title: "Dynamic Model Routing and Cascading for Efficient LLM Inference: A Survey"
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2603.04445]
supersedes: []
superseded_by: []
expires_when: "Survey covers methods through early 2026. Re-evaluate when: (a) unified multi-objective routing formulations or (b) response-level + online adaptation combinations appear and establish new state-of-the-art, as these are identified as explicit gaps in §10."
tags: [survey, LLM-routing, cascading, inference-efficiency, taxonomy, multi-LLM]
---

# Dynamic Model Routing and Cascading for Efficient LLM Inference: A Survey

Yasmin Moslem, John D. Kelleher. ADAPT Centre / Trinity College Dublin. arXiv:2603.04445v2 (April 2026).

## Claim

Multi-LLM routing and cascading can outperform even the strongest single model by exploiting model complementarity — strategically assigning queries to specialized models rather than routing everything to the most capable (and costly) one. This survey organizes the literature into six paradigms and introduces a three-dimensional conceptual framework (when/what/how) that reveals production systems as inherently multidimensional. The key empirical finding synthesized across the corpus: well-designed routing systems establish Pareto frontiers that dominate any individual model on the quality-cost trade-off. (§1.1, §11)

## Scope and Exclusions

Covers routing between independently trained LLMs at inference time. Explicitly excludes:
- Mixture-of-experts (MoE) routing, which routes within a single model's architecture
- Single-LLM adaptive computation (adaptive thinking depth, chain-of-thought toggling)
- Static model selection (offline evaluation, not per-query)

Includes: machine translation cascades as a domain case study (§7). (§1.2)

## Six Paradigms (§§2-7)

### 1. Difficulty-aware Routing (§2)
Routes based on estimated query complexity. Small/cheap models handle easy queries; large models handle complex ones.

Representative methods:
- **BEST-Route** (Ding et al. 2025): DeBERTa-v3-small multi-head router + best-of-n sampling for small models; threshold controls cost-quality trade-off.
- **vLLM Semantic Router** (Wang et al. 2025): ModernBERT classifier distinguishes reasoning-required vs standard queries.
- **EmbedLLM** (Zhuang et al. 2024): matrix factorization learns compact LLM embeddings capturing domain specialization; requires retraining on new models.
- **ICL-Router** (Wang et al. 2026): capability profile vectors derived from query-performance pairs; new models integrated without retraining.
- **GraphRouter** (Feng et al. 2024): heterogeneous GNN over task-query-LLM nodes; inductive, generalizes to new LLMs.
- **IRT-Router** (Song et al. 2025): Item Response Theory — models LLM ability + query difficulty jointly; interpretable routing scores.

### 2. Human Preference-aligned Routing (§3)
Trains routers on human or synthetic preference data, optimizing for win-rate rather than correctness labels.

- **RouteLLM** (Ong et al. 2025): win prediction model using Chatbot Arena labels + LLM-judge augmentation. Matrix factorization router most cost-efficient.
- **Arch-Router** (Tran et al. 2025): routing policies in input context to 1.5B model; update policies without retraining.
- **P2L** (Frick et al. 2025): generates prompt-specific Bradley-Terry coefficients for per-query model ranking.
- **Eagle** (Zhao et al. 2024): Elo-based, training-free. Eagle-Global (overall) + Eagle-Local (cluster-specific).
- **Zooter** (Lu et al. 2024): knowledge distillation from reward model; fixed LLM pool.

### 3. Clustering-based Routing (§4)
Unsupervised grouping of queries; assign each cluster to its best-matching LLM.

- **UniRoute** (Jitkrittum et al. 2026, [[universal-model-routing]]): K-means on training set → K cluster centroids; each LLM represented as K-dim error vector; routing = nearest-centroid + cost-adjusted selection. New LLMs added without retraining.
- **Avengers-Pro** (Zhang et al. 2025): similar cluster-allocation strategy; demonstrates Pareto frontier surpassing GPT-5-medium.

### 4. Reinforcement Learning Routing (§5)

**Policy optimization:**
- **Router-R1** (Zhang et al. 2025): sequential routing as MDP; alternates think-route actions; up to 4 routing steps per query; trained with PPO on Qwen2.5-3B/LLaMA-3.2-3B.
- **R2-Reasoner** (Shao et al. 2025): task decomposition + subtask allocation; SFT+GRPO staged training; 84.46% API cost savings vs LLM-only.
- **SCOPE** (Cao et al. 2026): GRPO-trained performance estimator using behavioral fingerprints; rule-based final selection; generalizes to unseen models.

**Bandit-based (online adaptation):**
- **MetaLLM**: multi-armed bandit; no reward model required.
- **MixLLM**: contextual bandit + policy gradient; domain-aware tags; 97.25% GPT-4 quality at 24.18% cost.
- **PILOT**: LinUCB + offline preference priors + cost as multi-choice knapsack.
- **GreenServ**: LinUCB with energy consumption as reward; 22% accuracy gain + 31% energy reduction vs random routing.
- **TI-UCB**: accounts for non-stationary LLM improvement during fine-tuning; logarithmic regret bounds.

### 5. Uncertainty-based Routing (§6)
Routes based on model confidence, typically post-generation; escalates low-confidence responses.

- **CP-Router** (Su et al. 2025): conformal prediction on logit distributions; routes standard vs Large Reasoning Models (e.g., DeepSeek-R1).
- **Probe-based UQ** (Chuang et al. 2025): hidden-state probes + perplexity outperform verbalization; SLMs match LLMs on top-20% confidence queries.

Key finding: verbalization-based self-reported confidence consistently misaligns with actual correctness. Probe-based methods require weight access but are more reliable. (§6.2)

### 6. Cascading (§7)
Sequential escalation: small model first; escalate to larger if quality insufficient. Distinguishes from routing by being multi-model and post-generation.

- **FrugalGPT** (Chen et al. 2024): LLM router + DistilBERT quality estimator + cost-aware stop judge.
- **Cascade Routing** (Dekoninck et al. 2025): unified routing+cascading; iteratively selects best model at each step, can skip/reorder.
- **AutoMix** (Aggarwal et al. 2024): few-shot self-verification without fine-tuning; POMDP router for escalation.
- **Self-REF** (Chuang et al. 2025): lightweight fine-tuning; special confidence tokens (<CN>/<UN>); probability ratio gives continuous confidence score.
- **LM-Blender** (Jiang et al. 2023): ensemble approach; Pair Ranker + Gen Fuser combine responses from multiple models.

## Conceptual Framework: Three Dimensions (§1.4, §10)

Any routing system can be characterized along:

| Dimension | Options |
|---|---|
| **When** | Pre-generation (query-only) / Post-generation (response-level) / Multi-stage (sequential escalation) |
| **What** | Query features / Model metadata / Response-level signals / User feedback |
| **How** | Heuristic threshold / Supervised classifier / Bandit (online) / RL policy |

These dimensions are not independent of paradigms: difficulty-aware and clustering methods are typically pre-generation + query signals; uncertainty-based and cascades use post-generation + response signals; bandits add online adaptation. Production systems combine mechanisms across all three dimensions — real-world deployments "rarely conform to a single paradigm." (§10)

**Proposed 3-stage production pipeline** (§10):
1. Pre-router: low-cost, query + model metadata, cost-constrained
2. Post-generation verifier: quality or uncertainty estimation
3. Escalation policy: accept / refine / reject / defer to stronger model

## Evaluation Landscape (§9)

**Benchmarks**: RouterBench (405K outputs, 11 LLMs, 7 tasks), RouterEval (200M records, 8500+ LLMs, 12 tasks), MixInstruct (110K preference examples), LLMRouterBench (400K instances, 21 datasets, 33 models).

**Metrics**: routing accuracy (% routed to optimal model); task performance (accuracy, pass@k, COMET for MT); win rate and AUC for preference-aligned; Pareto frontier visualization; latency (TTFT, TPOT), throughput (TPS/QPS); energy consumption + carbon footprint.

## Gaps Identified (§10)

Three structural gaps from the design-space matrix:
1. **Response-level signals + online adaptation**: no current method combines both. Uncertainty/cascade methods exploit response signals but are static; bandit methods adapt online but use only query-level signals. — Opportunity: bandit-style escalation policies refined from deployment feedback.
2. **RL in cascading**: reinforcement learning is underused in multi-stage architectures. Learned escalation policies not yet explored.
3. **Unified multi-objective optimization**: few systems formalize quality + cost + latency as jointly tunable objectives; most use fixed trade-off parameters.

## Boundary Conditions

- **Routing assumes a fixed model pool** at decision time. Pool evolution (model updates, new models) is handled differently across methods — some require retraining, some generalize via inductive structure.
- **Black-box assumption**: most methods assume black-box LLMs; probe-based uncertainty methods require weight access.
- **Evaluation settings vary widely**: different surveys use different benchmark sets and pool compositions, limiting direct comparison across papers.
- **No coverage of collaborative/compositional multi-LLM systems** (e.g., Minions protocol, GAPG): this survey focuses on selection routing, not decomposition-and-collaboration.

## Decision Knowledge

- The three-dimension framework (when/what/how) is the most useful tool from this survey for practitioners designing routing systems. Specifying routing in these terms makes compositionality visible and exposes gaps.
- Routing can outperform the strongest single model — this is not a theoretical claim but an empirical finding across multiple methods. Model complementarity is the mechanism.
- The most practically reliable uncertainty signal is hidden-state probes (requires weights); verbalization is unreliable. For black-box settings, cascading with few-shot self-verification (AutoMix-style) is the next best option.

## Not Stated in Source

- GAPG ([[on-device-cloud-collaborative-reasoning]]) is not cited or covered: it trains intrinsic routing into the on-device model itself rather than using an external router — this "routing as post-training" paradigm is absent from the survey's taxonomy.
- Minions ([[minions-device-cloud-collaboration]]) is also absent: it uses protocol-based decomposition rather than selection routing, which falls outside this survey's scope.
- No analysis of how routing system latency overhead compares to savings from smaller model use — the survey notes this trade-off exists but does not synthesize numbers across methods.

## Relations
- Cluster: [[inference-efficiency]]

- Classifies under taxonomy: [[universal-model-routing]] (§4, clustering-based; described accurately)
- Complements: [[automatic-prompt-optimization-survey]] (sister survey for prompt optimization; analogous scope boundary issues)
- Gap relative to: [[on-device-cloud-collaborative-reasoning]] (intrinsic routing via post-training not covered), [[minions-device-cloud-collaboration]] (decomposition-collaboration not covered)
- Contradicts: -
- Superseded by: -
