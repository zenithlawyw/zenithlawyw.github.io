---
layout: post
title: "Support Vector Machine Series Part 2: Benchmark and Error Forensics on UCI HAR"
author: Zenith Law
description: "Support Vector Machine benchmark deep dive on UCI HAR with class-level errors, confusion corridors, PCA geometry, and R versus Python implementation parity."
permalink: /support-vector-machine-series-part-2-benchmark-error-analysis-har
intro: "Support Vector Machine (SVM) benchmark results are only useful when read at class level, not just headline accuracy. Part 2 of this series analyzes UCI HAR outcomes, confusion flows, and geometry signals to show where SVM is strong, where it degrades, and why those patterns matter in practice."
related_posts:
  - title: "Support Vector Machine: Practical Guide to Margins, Kernels, and Tuning"
    url: /support-vector-machine-practical-guide-kernels-margin-tuning
  - title: "Support Vector Machine Series Part 3: Tuning, Monitoring, and Deployment Governance"
    url: /support-vector-machine-series-part-3-tuning-monitoring-deployment-governance
  - title: "Data Provenance in Machine Learning: Traceability, Graph Methods, and Governance Lessons"
    url: /data-provenance-ml-lifecycle-traceability-graph-methods-ten-lessons
  - title: "Deadlock and Resource Contention: Operating Systems Theory Applied to Supply Chains, Cloud Platforms, and LLM Systems"
    url: /deadlock-resource-contention-operating-systems-supply-chains-cloud-llm
image: /assets/images/support-vector-machine-part-2-benchmark-forensics.png
hero:
  image: /assets/images/support-vector-machine-part-2-benchmark-forensics.png
keywords: "support vector machine benchmark, svm confusion matrix analysis, uci har svm results, svm vs random forest har, class level model evaluation, svm error analysis, r vs python svm implementation, pca svm interpretation, model diagnostics, svm misclassification corridor analysis"
catchwords: "svm benchmark, uci har, confusion matrix, class-level metrics, error forensics, r vs python, pca, random forest baseline"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - svm-2026-ref1
  - svm-2026-ref2
  - svm-2026-ref5
  - svm-2026-ref6
  - svm-2026-ref9
  - svm-2026-ref12
  - svm-2026-ref13
  - svm-2026-ref14
  - svm-2026-ref15
  - svm-2026-ref16
  - svm-2026-ref18
  - svm-2026-ref19
  - svm-2026-ref20
categories:
  - Artificial Intelligence
tags:
  - support vector machine
  - benchmark
  - confusion matrix
  - model evaluation
  - uci har
---

## Introduction

This second article in the SVM series focuses on one question: what do benchmark results actually say about model behavior once we move beyond aggregate accuracy? Using the [UCI Human Activity Recognition dataset](https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones) {% include references/cite.html key="svm-2026-ref16" %}, we compare an RBF SVM pipeline against a Random Forest baseline and inspect class-level precision, recall, F1, confusion corridors, tuning stability, and PCA geometry signals.

If you have not read the conceptual foundation, start with [Part 1: Margins, Kernels, and Core Algorithms](/support-vector-machine-practical-guide-kernels-margin-tuning). For system-level reliability analogies in resource contention, see [deadlock and resource contention lessons](/deadlock-resource-contention-operating-systems-supply-chains-cloud-llm).

## Scope and Claim Classification

This benchmark-focused article separates claims into three classes:

1. **Run-confirmed findings** report the measured outcomes for this HAR experiment setup.
2. **Interpretive synthesis** explains likely geometric or operational reasons behind observed class behavior.
3. **Deployment recommendations** propose practical controls for production monitoring and retraining.

Results are intentionally scoped to the dataset, feature pipeline, split assumptions, and tuning grid used in this run. They should inform transfer decisions, not be treated as universal rankings for all activity-recognition contexts.

## Reference and Maintenance Note

Benchmark conclusions should be revisited when key dependencies, preprocessing contracts, or dataset distributions change. Re-run parity checks and class-corridor diagnostics after material library, feature-engineering, or data-governance updates.

## Benchmark Setup and Reproducibility Boundaries

The benchmark design used:

1. Subject-compatible train/test split consistent with HAR conventions.
2. Feature scaling fit on training data and applied unchanged to test data.
3. RBF SVM with one-vs-all decomposition and grid search over $C$ and $\gamma$.
4. Random Forest baseline tuned under comparable CV protocol.

R and Python implementations were aligned by hyperparameter grid and fold logic to check language-level consistency ({% include references/cite.html key="svm-2026-ref13" %}; {% include references/cite.html key="svm-2026-ref14" %}; {% include references/cite.html key="svm-2026-ref15" %}; {% include references/cite.html key="svm-2026-ref20" %}).

**Scope note:** This is a single-dataset, single-task benchmark. It supports careful operational inference for sensor-based activity classification, not universal model ranking.

## Aggregate Metrics: Useful but Insufficient

Top-level outcomes from this run:

| Metric   |    SVM |     RF |
| -------- | -----: | -----: |
| Accuracy | 0.8829 | 0.9396 |
| Macro F1 | 0.8808 | 0.9370 |
| Kappa    | 0.8595 | 0.9274 |

At first glance, RF is the stronger overall fit. In this run, that is supported by higher accuracy, macro F1, and kappa. The conclusion is still incomplete, because operational risk sits in specific class transitions, not in averages.

## Class-Level Diagnostics: Where SVM Holds and Slips

Selected class profile:

- LAYING: near-ceiling SVM behavior.
- SITTING and STANDING: dominant static-class confusion corridor.
- WALKING-related subclasses: overlap-driven dynamic-class spillovers.

SVM class asymmetry in this run:

1. SITTING recall is high while precision drops, signaling over-assignment pressure.
2. STANDING precision is high while recall drops, signaling conservative boundary placement.
3. WALKING_UPSTAIRS and WALKING_DOWNSTAIRS show structured bidirectional errors.

This pattern is coherent with kernel locality behavior and neighborhood overlap in transformed space ({% include references/cite.html key="svm-2026-ref18" %}; {% include references/cite.html key="svm-2026-ref19" %}; {% include references/cite.html key="svm-2026-ref15" %}).

## Error Corridors, Not Random Noise

Largest SVM confusion transitions in this run:

1. STANDING -> SITTING.
2. WALKING -> WALKING_DOWNSTAIRS.
3. WALKING_UPSTAIRS -> WALKING.

RF reduces the same corridors, which indicates shared ambiguity zones with stronger suppression by tree-based partitioning in this feature geometry.

Operational implication: treat these corridors as monitoring units. In production dashboards, pairwise transition counts are often more actionable than global F1.

## Error Topology and Boundary Geometry

The confusion pattern indicates a geometry mismatch, not random instability. LAYING remains easy, while posture-adjacent and stair-adjacent classes concentrate most errors. This is consistent with the theory that margin methods perform best when local neighborhoods retain separability under the selected kernel width {% include references/cite.html key="svm-2026-ref1" %} {% include references/cite.html key="svm-2026-ref2" %}.

The practical takeaway is that class-pair topology should be treated as a first-class artifact:

1. Static posture pairs often require feature redesign around orientation and transition context.
2. Gait subclasses often require windowing or frequency features that reduce local overlap.
3. Aggregate metrics should be interpreted as summaries, not deployment decisions.

## Why RF Wins Here Without Invalidating SVM Theory

This benchmark does not contradict large-margin foundations. It shows that tree ensembles can better absorb overlap-heavy feature neighborhoods in this dataset. SVM remains theoretically coherent and operationally useful, but not the strongest empirical fit for these class corridors in this run.

Model selection therefore becomes conditional:

1. Use SVM when boundary control and disciplined regularization are priorities.
2. Use RF when local overlap dominates despite careful SVM tuning.
3. Keep both in the candidate set until class-level risk criteria are met.

## Calibration and Decision-Threshold Implications

Where outputs feed thresholded actions, margin quality and probability quality must be audited separately. Platt-style calibration and pairwise coupling literature provide workable pathways, but calibration quality should be tested per class because corridor classes can remain overconfident even when macro metrics are strong {% include references/cite.html key="svm-2026-ref5" %} {% include references/cite.html key="svm-2026-ref6" %}.

## Robustness Checks Before Promotion

Before promoting this benchmark pattern into production policy, add four checks:

1. Grouped validation by subject/entity to reduce split optimism.
2. Stability analysis around near-optimal hyperparameter neighborhoods.
3. Class-specific calibration diagnostics.
4. Comparator retention over successive retraining cycles, especially when class frequencies drift.

## Hyperparameter Stability Signal

SVM reached its best CV region around $\gamma=0.001$ and $C=50$, then softened at higher $C$. RF response across tested mtry values was flatter.

Interpretation:

1. SVM delivered competitive quality but with a narrower stable region.
2. RF delivered stronger quality with broader tuning tolerance.

Under frequent retraining, that difference changes operational burden and drift risk.

## PCA Geometry Reading

PCA analysis showed:

- Rapid early variance capture.
- Slow tail compression for higher variance thresholds.
- Partial macro-separation of static versus dynamic regimes.
- Persistent local overlap among walking-related subclasses.

This explains why SVM can remain strong on easy global separations while repeating specific local confusions.

## R and Python Parity: Why It Matters

Closely aligned results across this run's R and Python pipelines, under matched preprocessing and split assumptions, suggest that observed performance differences were driven by model-data interaction rather than language artifacts. This is valuable for reproducible engineering:

1. It reduces toolchain tribalism.
2. It improves reproducibility across teams.
3. It keeps methodological critique focused on data, assumptions, and evaluation design.

For a broader model-governance continuity perspective, connect this with [data provenance and traceability methods](/data-provenance-ml-lifecycle-traceability-graph-methods-ten-lessons).

## Practical Conclusions from the Benchmark

1. SVM remains strong and defensible in this task class, but not best-in-run here.
2. RF is empirically superior for this dataset's overlap-heavy boundary regions.
3. Class-level diagnostics change model selection decisions more than headline metrics.
4. Tuning stability should be treated as a first-class operational criterion.

## Continue the Series

For implementation playbooks and deployment controls, continue with [Part 3: Tuning, Monitoring, and Deployment Governance Playbook](/support-vector-machine-series-part-3-tuning-monitoring-deployment-governance).

## Frequently Asked Questions

### Why is macro F1 not enough for SVM evaluation?

Macro F1 averages class behavior and can hide concentrated failure corridors that dominate real-world risk, especially in near-neighbor class pairs.

### Does better RF accuracy mean SVM is a bad model?

No. It means RF is the better fit for this specific dataset geometry and operating objective; SVM can still be strong in other structured regimes.

### How should I use confusion corridors in production?

Track the highest-frequency class transitions as explicit alert channels and tie retraining or threshold updates to corridor-specific drift.

### Why compare R and Python if both use libsvm-style tooling?

Parity checks still matter because they expose silent preprocessing or CV mismatches and improve reproducibility across mixed-language teams.

## Conclusion

The HAR benchmark shows a clear but nuanced result: SVM is robust and informative, while RF is stronger for the overlap profile in this run. The key outcome is diagnostic clarity about where and why each model family wins. Part 3 turns these diagnostics into a deployment governance playbook with explicit tuning, monitoring, and escalation controls.
