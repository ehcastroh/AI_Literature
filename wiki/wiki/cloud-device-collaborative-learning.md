---
title: Cloud-Device Collaborative Learning for Multimodal Large Language Models (CD-CCA)
type: reference
audience: both
created: 2026-08-04
verified: 2026-08-04
confidence: VERIFIED
sources: [arxiv:2312.16279]
supersedes: []
superseded_by: []
expires_when: "On-device MLLMs reach sufficient capacity to adapt to distribution shifts without cloud assistance, or cloud-device communication becomes the standard deployment path for MLLMs rendering this framework unremarkable"
tags: [MLLMs, edge-deployment, knowledge-distillation, continual-adaptation, multimodal, efficiency]
---

# Cloud-Device Collaborative Learning for Multimodal Large Language Models (CD-CCA)

Jiaming Liu, Chenxuan Li, Junpeng Ma, Yuan Zhang, Xinyu Wei, Kevin Zhang, Maurice Chong, Guanqun Wang, Ray Zhang, Yijiang Liu, Shanghang Zhang. Peking University / Shanghai AI Lab / Nanjing University. arXiv:2312.16279v1 (2023).

## Claim

Compressed MLLMs deployed on edge devices suffer performance degradation under distribution shift because: (1) limited device compute prevents timely model updates; (2) compressed models lack the capacity to generalize to new distributions. CD-CCA (Cloud-Device Collaborative Continual Adaptation) addresses this by routing uncertain out-of-distribution tokens from the device to the cloud, distilling knowledge from a large cloud MLLM into the compressed device model via adapter-based KD, then returning compressed updated weights to the device. Results: +3.93% on domain-shifted VQA, +2.20% on captioning, while reducing uplink data to <5% and downlink parameters to 0.002% of naive transfer. (§1, §5)

## Method

Three-component framework (§3, Fig. 1, 2):

**UTS - Uncertainty-guided Token Sampling** (uplink, §3.2): Coarse-to-fine filtering before transmitting device data to the cloud.
- Stage 1 (sample-level): Filter out samples with low uncertainty (already handled well by device model), keeping only out-of-distribution samples needing cloud assistance.
- Stage 2 (token-level): Within selected samples, filter tokens by uncertainty to retain only OOD tokens. Reduces uplink data to 65.54 KB vs 31.10 MB for full dataset (0.21% of original volume, 0.001s vs 0.498s latency).

**AKD - Adapter-based Knowledge Distillation** (cloud side, §3.3): Transfers "dark knowledge" from large teacher MLLM to compressed student MLLM. MLLM has three components (vision encoder, LLM, cross-modal transformer):
- KD applied to query adapters in the cross-modal transformer - improves vision-to-text alignment in the student.
- KD applied to language adapters plugged into the LLM - improves language reasoning in the student.
- Pseudo-label generation on cloud teacher, used to supervise student. AKD alone improves VQA by +2.53% (MC) / +3.34% (DA) vs pure pseudo-labeling.

**DWC - Dynamic Weight update Compression** (downlink, §3.4): Adaptively selects and quantizes updated weight parameters before transmission. Reduces: weight parameter count by 99.98%, data quantity by 99.99%, transmission latency from 65.490s to 0.013s (99.98% reduction). Enables practical real-time device updates.

Base model: LLaMA-Adapter (7B & 13B). Experiments on VQA-v2→A-OKVQA (domain shift via knowledge requirements) and COCO Captions 2017→nocaps (object distribution shift).

## Results

| Finding | Magnitude | Conditions | Locator |
|---|---|---|---|
| VQA accuracy vs best baseline | +3.64% MC, +3.19% DA (average) | VQAv2→AOKVQA, all rounds | §4.2, Table 1 |
| Captioning vs best baseline | +1.53% BLeU, +2.20% CIDEr | COCO→nocaps, all domain splits | §4.2, Table 2 |
| Out-domain captioning | +1.84% BLeU, +3.98% CIDEr | Out-of-domain nocaps split | §4.2, Table 2 |
| UTS uplink reduction | 31.10MB → 65.54KB (0.21%); 0.498s → 0.001s (0.20%) | VQA task, 5-frame input | §4.3, Table 5 |
| DWC downlink reduction | 14.48GB → 0.791MB (0.005%); 65.490s → 0.013s (0.02%) | Downlink parameters | §4.3, Table 5 |
| Ablation: AKD alone vs pseudo-label | +2.53% MC, +3.34% DA | VQAv2→AOKVQA | §4.3, Table 3 |
| Ablation: optimal UTS mask ratio | 50% mask ratio gives best MC (+3.06%) | Token-level UTS | §4.3, Table 4 |
| Previous KD methods on MLLM | CoTTA: -0.08% BLeU; TENT: -0.22% BLeU vs source-only | Captioning task | §4.2, Table 2 |
| Real-world validation | Demonstrated on RealSense D435i camera, Gigabit Ethernet | Robot system | §4.4, Table 5 |

Key negative: methods not designed for MLLM scale (CoTTA, TENT) actually degrade performance vs source-only, while CD-CCA consistently improves.

## Boundary conditions

- **Cloud dependency**: Requires persistent cloud connectivity for adaptation. Device cannot adapt autonomously if cloud is unavailable. Not evaluated under bandwidth constraints below Gigabit Ethernet.
- **Tested on one model family**: LLaMA-Adapter 7B/13B. Generalization to other MLLM architectures (Flamingo, BLIP-2, LLaVA) not demonstrated.
- **Two domain shifts only**: VQAv2→AOKVQA (knowledge domain shift) and COCO→nocaps (object distribution shift). No evaluation on natural distribution shift (sensor noise, illumination, occlusion).
- **UTS performance is mask-ratio dependent**: Best at 50% mask ratio; performance non-monotone with mask ratio. Optimal ratio likely task-dependent and not characterized for other tasks.
- **AKD designed for adapter-based MLLMs**: The KD targets specific adapter modules (query adapters, language adapters). Not directly applicable to MLLMs without adapter-based architectures.
- **DWC compression is extreme (99.98%)**: Extreme compression may lose fine-grained information; only validated on these two benchmarks, not stress-tested with adversarial shifts.
- **Previous methods degrade on MLLM**: TENT and CoTTA, designed for smaller models, degrade performance. CD-CCA's advantage may partly reflect that appropriate baselines for MLLM-scale adaptation did not exist at time of publication.

## Decision knowledge

| Design choice | Cue that motivated it | If absent | Newcomer trap |
|---|---|---|---|
| Two-stage UTS (sample then token) | Sample-level filtering is cheaper and eliminates obviously in-distribution data before token-level processing; token-level filtering on all samples would be expensive (§3.2) | Single-stage filtering: either sends too many tokens (sample-only) or is computationally prohibitive (token-only on all samples) | Treating both stages as interchangeable; sample-level filtering is a coarse guard, token-level is the precision tool |
| KD to adapters, not full model | LLM occupies majority of MLLM parameters; full-model KD at device scale is infeasible; adapters are small, trainable, and positioned at the interface between modalities (§3.3) | Full-model KD: computationally infeasible on device; no KD: no generalization transfer | Expecting standard KD (feature-level, attention-level) to work on MLLMs without MLLM-specific adapter targeting |
| Adaptive quantization in DWC (not fixed) | Different device capabilities require different compression ratios; fixed quantization wastes bandwidth on capable devices or corrupts performance on constrained ones (§3.4) | Fixed quantization: suboptimal for heterogeneous device fleet | DWC is framed as "adaptive" but the adaptation mechanism (how device capability is communicated) is not fully detailed in the paper |

## Not stated in source

- How device capability (for DWC adaptive quantization) is communicated to the cloud is not specified.
- No failure mode analysis: cases where CD-CCA makes device performance worse are not identified or characterized.
- Interaction with privacy constraints: sending device-captured image tokens to the cloud may violate privacy in sensitive deployments; not addressed.
- Energy cost on device-side for UTS computation not measured.
- How many adaptation rounds (R) are needed before convergence not studied; only "1-round scenario" is validated for VQA.

## Relations
- Cluster: [[inference-efficiency]]

- Supports: -
- Contradicts: -
- Superseded by: -

## Expiry

When on-device MLLMs reach sufficient parameter capacity and adaptation capability to handle distribution shifts without cloud assistance, or when privacy-preserving on-device adaptation methods make cloud-reliant approaches unnecessary. Re-verify when: on-device MLLM benchmarks emerge with >7B parameters running locally.
