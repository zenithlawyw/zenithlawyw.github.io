---
layout: post
last_modified_at: 2026-06-22
title: "Breaking Free from Correlation: Causal and Dependency-Aware Feature Attribution"
author: Zenith Law
description: "Three papers tackle the correlation-causation tension in feature attribution: automated causal discovery for SHAP, correlation-aware global scoring, and contrastive cross-class attribution for few-shot learning."
permalink: /breaking-free-from-correlation-causal-dependency-aware-attribution
intro: "Feature attributions conflate correlation with causation. A feature that co-varies with the target receives high importance even when it plays no causal role in the model's decision, a vulnerability that a 2020 proof showed is inherent to conditional Shapley-value methods. Three recent papers attack this problem from different angles. One automates causal discovery to produce dependency-aware SHAP values without requiring a domain-expert causal graph. Another develops a correlation-aware attribution method that explicitly handles correlated feature groups for efficient transfer. The third uses contrastive cross-class comparison to produce fine-grained attributions for few-shot learners, where feature compression amplifies the correlation problem. Each advances a different piece of the solution, and each reveals how hard the correlation problem actually is."
image: /assets/images/breaking-free-from-correlation-causal-dependency-aware-attribution.png
hero:
  image: /assets/images/breaking-free-from-correlation-causal-dependency-aware-attribution.png
keywords: "causal SHAP, causal feature attribution, correlation-aware XAI, ExCIR attribution, C3A explainability, few-shot learning attribution, automated causal discovery XAI, dependency-aware attribution, PC algorithm SHAP, feature correlation in explainability"
catchwords: "causal SHAP, ExCIR, C3A, correlation-aware attribution, causal discovery, few-shot explainability, automated causal SHAP, efficient correlation attribution, contrastive cross-class attribution, feature dependency"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - 11449430
  - 11228295
  - 11498186
related_posts:
  - title: "Feature Attribution: Theoretical Foundations and the Limits of Verifiability"
    url: /feature-attribution-foundations-limits-verifiability
  - title: "Measuring Attribution Quality: Metrics, Benchmarks, and Evaluation Frameworks"
    url: /measuring-feature-attribution-quality-metrics-benchmarks
  - title: "Feature Attribution in Practice: Selection, Pipelines, and Governance"
    url: /feature-attribution-practice-selection-pipelines-governance
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - feature attribution
  - causal inference
  - correlation-aware attribution
  - causal SHAP
  - few-shot learning
  - causal discovery
  - XAI
  - explainable AI
  - contrastive attribution
---

## Introduction

The correlation-causation problem in feature attribution is structural: a feature that is correlated with the true driver of a prediction receives inflated importance, while the true driver may appear irrelevant. Every attribution method based on conditional expectations inherits this vulnerability. [Feature Attribution: Foundations, Limits, and Verifiability](/feature-attribution-foundations-limits-verifiability) established the theoretical foundation; three recent papers respond with concrete methods.

Ng et al. integrate causal discovery with SHAP to remove the domain-expert bottleneck. Sengupta et al. design a lightweight correlation-aware method that handles grouped features. Chen et al. show that feature compression in few-shot learning amplifies misattribution, and introduce a contrastive cross-class mechanism to recover discriminative signal.

Each method's approach and evidentiary support is covered below. The dependency type that dominates in a given application determines which tool fits.

This article is not legal advice.

## Causal and Dependency Terms

<dl>
  <dt><dfn>Causal discovery</dfn></dt>
  <dd>The task of inferring causal relationships from observational data, typically by testing conditional independencies to construct a directed acyclic graph (DAG) representing the data-generating process.</dd>

  <dt><dfn>PC algorithm</dfn></dt>
  <dd>A constraint-based causal discovery algorithm named after its inventors (Peter and Clark) that starts from a fully connected graph and iteratively removes edges based on conditional independence tests.</dd>

  <dt><dfn>Do-operator</dfn></dt>
  <dd>A mathematical operator in causal inference representing an intervention that sets a variable to a specific value while breaking its natural dependencies on its causes, written as do(X = x).</dd>

  <dt><dfn>Contrastive explanation</dfn></dt>
  <dd>An explanation that highlights features distinguishing a target class from a contrast class, answering "why this prediction rather than that one?" rather than "why this prediction?"</dd>

  <dt><dfn>Few-shot learning (FSL)</dfn></dt>
  <dd>A learning paradigm where models must generalise from very few labelled examples per class, typically relying on episodic training and metric-based classification in embedding space.</dd>

  <dt><dfn>Feature compression (in FSL)</dfn></dt>
  <dd>The tendency of FSL backbones to learn compact, highly entangled feature representations that compress discriminative detail, making standard attribution methods produce over-smoothed explanations.</dd>
</dl>

---

## Three Responses to the Correlation Problem

### Ng et al. (2025): Causal SHAP: Removing the Domain-Expert Bottleneck

Causal variants of SHAP exist, but they require a causal graph specified by a domain expert. That requirement is the main adoption barrier: specifying the complete causal structure among d features is prohibitively time-consuming beyond ten features. {% include references/cite.html key="11228295" %} Causal SHAP with PC discovery automates the causal discovery step, producing a three-stage pipeline: the PC algorithm learns a causal DAG from the data, IDA quantifies causal effect sizes adjusting for confounding, and a novel causal value function replaces standard conditional expectations with a do-operator formulation that breaks the correlation between intervened and non-intervened features.

On synthetic data with known ground truth, Causal SHAP achieves the lowest RMSE among all compared methods and correctly assigns near-zero scores to correlated-but-non-causal features. On real biomedical datasets, it achieves best or second-best insertion scores.

> **Core requirement:** PC requires the causal sufficiency assumption (no unobserved confounders) and has known limitations with nonlinear relationships. Tested only up to 31 features.

**Study limitations:** The automated causal discovery pipeline removes the main practical barrier to deploying causal SHAP. The synthetic validation convincingly shows correlation-causation separation. Scalability beyond 31 features and robustness to PC algorithm violations remain unconfirmed.

### Sengupta et al. (2026): ExCIR: Correlation-Aware Global Attribution with Efficiency

What if you do not need causation, only correlation awareness that avoids double-counting correlated features? {% include references/cite.html key="11498186" %} ExCIR computes a global feature attribution score in a single deterministic pass. Sign-aligned co-movement scores each feature's correlation with model output after robust centring. BlockCIR handles correlated feature groups as a unit to mitigate double-counting. A lightweight transfer protocol reproduces full attribution rankings using 20% to 40% of the data, achieving 3x to 9x speedup.

ExCIR achieves strong agreement with SHAP (Kendall-τ = 0.82) at 100x less computational cost, validated across 29 benchmarks spanning text, tabular, signals, images, and networks. This is the broadest empirical validation in the series. The subsampling knee at 20% to 40% data holds across all five modalities, suggesting a universal property of ranking-preserving subsampling, though independent replication is needed. ExCIR also satisfies translation invariance and positive-scale invariance: scores remain unchanged under feature shift or rescaling, so model recalibrations produce consistent rankings without re-computation.

> **Design boundary:** ExCIR captures association, not causation. It is explicitly correlation-aware by design choice. The correlation-causation gap means ExCIR cannot replace causal attribution when causal claims are required.

**Study limitations:** The cross-domain validation (29 benchmarks) provides strong evidence of generalisability. The computational efficiency advantage is clearly demonstrated. The method does not address causal attribution, which is an honest design constraint rather than a limitation.

### Chen, Hu and Liu (2026): C3A: Contrastive Attribution for Few-Shot Learning

Few-shot learning models generalise from one to five examples per class, forcing their backbones to learn compressed, highly entangled feature representations. {% include references/cite.html key="11449430" %} C3A discovers that this compression causes standard attribution methods (Grad-CAM, LIME, SHAP) to produce over-smoothed, uninformative explanations. The root cause: standard methods attribute at the image level, but FSL models decide based on local descriptors extracted from feature maps, and compression collapses the discriminative detail those methods need.

C3A (Contrastive Cross-Class Attribution) operates in three stages: extract dense local descriptors from the backbone feature map, compute each descriptor's similarity to the target class versus competing classes via k-nearest-neighbour in the support set, and aggregate contrastive scores into a pixel-level attribution map. The contrastive framing matches how humans reason about decisions: we understand outcomes by comparison to alternatives, not by absolute scores.

C3A achieves absolute gains of 19.72% in iAUC and 25.88% in dAAC over leading FSL XAI methods across four few-shot benchmarks. The contrastive principle has the potential to generalise beyond FSL, but the method itself requires the episodic training structure and support sets that define the paradigm.

> **Applicability:** C3A requires white-box access to feature maps and a labelled support set at explanation time. It is specific to few-shot learning in its current form.

**Study limitations:** The finding that FSL feature compression degrades standard attributions is novel with implications beyond FSL XAI. The empirical gains over existing methods are substantial and validated across multiple benchmarks. Generalisability beyond few-shot image classification to other low-data regimes is unconfirmed. The robustness of C3A attributions to adversarial input manipulation has not been tested, nor has the method been adapted to non-visual modalities such as few-shot text classification.

---

## Cross-Paper Synthesis: Three Different Answers to the Dependency Problem

### What each paper assumes about the problem

| Method      | Problem framed as                                 | Solution approach              | Causal claim                   |
| ----------- | ------------------------------------------------- | ------------------------------ | ------------------------------ |
| Causal SHAP | Need for causal graph → automation                | PC algorithm + IDA             | Yes: interventional            |
| ExCIR       | Need for efficiency with correlation awareness    | Association scoring + grouping | No: explicitly correlational   |
| C3A         | Feature compression in FSL → contrastive decoding | Local descriptor contrast      | Structural (not causal per se) |

The three papers do not compete. They address distinct facets of the dependency problem, and their different starting assumptions lead to different solution properties.

The C3A approach strikes me as the one most likely to generalise beyond its stated domain. The contrastive principle, attributing by comparing what the model sees in one class versus another, matches how humans naturally reason about decisions. Nothing about it is specific to few-shot image classification.

### When correlation awareness is enough

ExCIR raises an important question that the field has not settled: for which decisions do we need causal attributions, and when is correlation awareness sufficient? The answer depends on the decision's stakes and reversibility. A low-stakes, high-volume decision (e.g., product recommendation) can tolerate correlation-aware explanations because the cost of a misattribution is low. A high-stakes decision (e.g., medical diagnosis, loan denial) demands causal attribution because regulatory and ethical accountability requires answering counterfactual questions about what would have happened if a feature had been different.

### The contrastive dimension

C3A introduces a dimension that neither Causal SHAP nor ExCIR addresses: contrastivity. An attribution that says "feature X is important" is less informative than one that says "feature X distinguishes class A from class B." The contrastive framing matches how humans reason about decisions. We want to know not just what drove the outcome, but what made the difference. This dimension is underexplored in the causality literature.

### The scalability challenge

All three methods face scalability constraints that limit their applicability to large-scale models. Causal SHAP is tested only up to 31 features; the PC algorithm's exponential growth in conditional independence tests makes higher dimensions intractable without alternative discovery methods such as GES or NOTEARS. ExCIR scales better but is limited to global (not instance-level) attribution. C3A requires backbone feature maps and a support set, and its per-pixel perturbation becomes computationally intensive at higher resolutions. None has been demonstrated on models with billions of parameters or on very high-dimensional inputs.

---

## Questions on Dependency-Aware Attribution

### Can ExCIR be extended to instance-level attribution?

The paper focuses on global attribution: a single score per feature for the entire dataset. Instance-level attribution would require recomputing the co-movement measure per-instance, which would eliminate the computational advantage over SHAP.

### Does Causal SHAP's PC algorithm fail with many features?

PC has known scalability issues beyond approximately 50 features due to the exponential growth of conditional independence tests. For high-dimensional settings, alternative causal discovery methods (e.g., NOTEARS for continuous optimisation) would be needed.

### Does C3A require a labelled support set at explanation time?

The contrastive metric compares query descriptors against labelled support set descriptors for each candidate class. This is standard in FSL evaluation and is available whenever the model is deployed for FSL classification.

### How should a practitioner choose between Causal SHAP and ExCIR?

If causation is provably required (regulatory, medical, high-stakes), invest in Causal SHAP despite its assumptions and scalability limits. If correlation awareness is sufficient and computational efficiency matters, ExCIR offers a practical alternative. The threshold between "causation required" and "correlation sufficient" is a domain-specific policy judgement, not a technical one.

### Does contrastive attribution generalise beyond few-shot learning?

The contrastive principle, attributing by comparing what the model sees in the target class versus competing classes, is general. Future work could apply it to standard classification by using class-conditional feature statistics as the contrast reference, though this has not been systematically tested.

---

## Conclusion

The dependency problem has no universal solution for the same reason the attribution problem has none: the right answer depends on what kind of dependency is causing the trouble. Correlated features that are both predictive need correlation-aware grouping. Features correlated through confounding need causal discovery. Features compressed in representation space need contrastive decoding.

The practical question is not which method is best but which dependency type dominates in your application. A forthcoming article on selection and governance synthesises these findings into a decision framework for practitioners.

---

_Part 4 of a series on feature attribution, explainability, and interpretability. Technical and educational content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise._

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Technical Appendix" %}

### Appendix Table of Contents

- Author and Source Credibility
- Corpus Reviewed
- Citability Snapshot
- Technical Term Definitions
- Dependency-Awareness Spectrum
- Evidence Maturity Map

### Author and Source Credibility

All three papers appear in peer-reviewed venues: IJCNN (IEEE, Ng), AAIML (IEEE, Sengupta), and TNNLS (IEEE, Chen). Ng et al. and Chen et al. are from established academic AI groups; Sengupta et al. include researchers from the University of Oslo.

### Corpus Reviewed

1. Ng, W.Y., Wang, L.R., Liu, S. and Fan, X. (2025) 'Causal SHAP: feature attribution with dependency awareness through causal discovery', in _2025 International Joint Conference on Neural Networks (IJCNN)_. IEEE. doi:10.1109/IJCNN64981.2025.11228295.
2. Sengupta, P., Zhang, Y., Eliassen, F. and Maharjan, S. (2026) 'Correlation-aware feature attribution based explainable AI', in _2026 International Conference on Advances in Artificial Intelligence and Machine Learning (AAIML)_. IEEE. doi:10.1109/AAIML67890.2026.11498186.
3. Chen, L., Hu, P. and Liu, Z. (2026) 'Seeing what few-shot learners see: contrastive cross-class attribution for explainability', _IEEE Transactions on Neural Networks and Learning Systems_ (in press). doi:10.1109/TNNLS.2026.3672242.

### Citability Snapshot

| Criterion         | Causal SHAP             | ExCIR                        | C3A                           |
| ----------------- | ----------------------- | ---------------------------- | ----------------------------- |
| Methodology       | Causal discovery + SHAP | Correlation-aware scoring    | Contrastive local descriptors |
| Venue             | IJCNN (IEEE)            | AAIML (IEEE)                 | TNNLS (IEEE)                  |
| Venue type        | Conference              | Conference                   | Journal                       |
| Empirical breadth | Synthetic + biomedical  | 29 diverse benchmarks        | 4 few-shot benchmarks         |
| Theoretical rigor | [H] Axiomatic grounding | [M] Deterministic derivation | [H] Contrastive formalisation |
| Domain focus      | Tabular (biomedical)    | Cross-domain                 | Few-shot image                |

[H] = High, [M] = Medium

### Technical Term Definitions

<dl>
  <dt><dfn>IDA (Intervention calculus when DAG is Absent)</dfn></dt>
  <dd>A method that bounds causal effects from observational data given a partially known causal graph, used by Causal SHAP to quantify feature-to-target causal strengths.</dd>

  <dt><dfn>Mid-mean centring</dfn></dt>
  <dd>A robust centring method that removes the top and bottom quartiles before computing the mean, used by ExCIR to reduce the influence of outliers on the correlation measure.</dd>

  <dt><dfn>Support set</dfn></dt>
  <dd>The set of labelled examples provided to a few-shot learner at inference time, used by C3A to compute the class-conditional descriptor statistics for contrastive comparison.</dd>

  <dt><dfn>Episodic training</dfn></dt>
  <dd>A training paradigm for few-shot learning where each episode samples a small support set and query set from different classes, forcing the model to learn to generalise from few examples.</dd>

  <dt><dfn>iAUC (insertion Area Under the Curve)</dfn></dt>
  <dd>An attribution faithfulness metric that measures how quickly model confidence increases when features are inserted in order of decreasing attribution importance.</dd>

  <dt><dfn>dAAC (deletion Area Under the Accuracy Curve)</dfn></dt>
  <dd>An attribution faithfulness metric that measures how quickly model accuracy degrades when features are removed in order of decreasing attribution importance.</dd>
</dl>

### Dependency-Awareness Spectrum

| Property                    | No awareness (SHAP)    | Correlation-aware (ExCIR) | Causal-aware (Causal SHAP) |
| --------------------------- | ---------------------- | ------------------------- | -------------------------- |
| Handles correlated features | No (double counts)     | Yes (group scoring)       | Yes (causal adjustment)    |
| Handles confounding         | No                     | No                        | Yes                        |
| Requires causal assumptions | No                     | No                        | Yes (PC algorithm)         |
| Computational cost          | High (Shapley approx.) | Very low                  | High (discovery + Shapley) |
| Causal interpretability     | Correlational          | Correlational             | Interventional             |

### Evidence Maturity Map

1. **Strong empirical evidence**: (a) ExCIR agreement with SHAP across 29 benchmarks; (b) C3A gains over FSL XAI baselines on 4 benchmarks; (c) Causal SHAP's correct handling of correlated-but-non-causal features on synthetic data.
2. **Demonstrated on limited settings**: (a) Causal SHAP on biomedical datasets; (b) ExCIR for grouped feature scoring; (c) C3A qualitative attribution maps.
3. **Inferred synthesis**: (a) Applicability of causal attribution in high-dimensional settings; (b) generalisability of C3A beyond few-shot image classification; (c) practical decision boundary between correlation-aware and causal attribution needs.

</details>
