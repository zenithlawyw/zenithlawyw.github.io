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

The correlation-causation problem in feature attribution is not a niche concern. It is a structural vulnerability that affects every attribution method based on conditional expectations, including most popular implementations of SHAP. A feature that is correlated with the true driver of a prediction will receive inflated importance, while the true driver may appear irrelevant if it is competing with its correlates.

Article 1 of this series established the theoretical foundation for this problem through Janzing et al.'s causal critique. Three recent papers respond to the critique with concrete methods. Ng et al. integrate the PC causal discovery algorithm with SHAP, eliminating the requirement for a domain-expert-supplied causal graph. Sengupta et al. design a lightweight, correlation-aware attribution method that handles grouped features. Chen et al. address a distinct facet of the problem: feature compression in few-shot learning amplifies correlation-based misattribution. They introduce a contrastive cross-class mechanism to recover discriminative signal.

Each paper accepts a different subset of the problem as given and optimises the remainder. Together, they map the solution space for dependency-aware attribution.

Technical commentary for education and research synthesis. Not legal, regulatory, or procurement advice.

## Key Terms

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

  <dt><dt><dfn>Feature compression (in FSL)</dfn></dt>
  <dd>The tendency of FSL backbones to learn compact, highly entangled feature representations that compress discriminative detail, making standard attribution methods produce over-smoothed explanations.</dd>
</dl>

---

## Three Responses to the Correlation Problem

### Ng et al. (2025): Causal SHAP: Removing the Domain-Expert Bottleneck

**The barrier.** Causal variants of SHAP exist, but they require a causal graph specified by a domain expert. This requirement has been the main barrier to adoption: in most practical settings, no domain expert is available, and even when one is, specifying the complete causal structure among d features is prohibitively time-consuming for d > 10.

Causal SHAP with PC discovery removes this bottleneck by automating the causal discovery step {% include references/cite.html key="11228295" %}.

**The method: Causal SHAP with PC discovery.** The pipeline has three stages:

1. **Causal discovery**: The PC algorithm learns a causal DAG from the data by testing conditional independencies among all feature pairs. PC is chosen for its scalability to moderate-dimensional settings (tens of features) and its established theoretical properties.
2. **Causal strength estimation**: The IDA (Intervention calculus when the DAG is Absent) algorithm quantifies the causal effect of each feature on the target, producing causal effect estimates that adjust for confounding.
3. **Causal SHAP computation**: A novel causal value function replaces standard conditional expectations: v*c(S) = E[f(X) | do(X_S = x_S), X*{S̄} ∼ Pr(X\_{S̄} | do(X_S = x_S))]. Non-intervened features are sampled conditional on their causal parents rather than marginally, which is the key departure from standard SHAP. A normalisation step preserves SHAP's three axioms (local accuracy, missingness, consistency). The formal innovation is the causal do-operator inside the value function, which breaks the correlation between intervened and non-intervened features that causes standard SHAP to conflate correlation with causation.

**Key results.** On synthetic datasets with known causal ground truth, Causal SHAP achieves the lowest RMSE among all compared methods and correctly assigns near-zero scores to features that are correlated with but non-causal for the target (e.g., the canonical "drink coffee" feature in a lung cancer prediction task, where coffee drinking is correlated with smoking but has no causal effect). On real biomedical datasets, Causal SHAP achieves best or second-best insertion scores.

**The trade-off.** PC algorithm requires the causal sufficiency assumption (no unobserved confounders) and has known limitations with nonlinear relationships. The method has been tested only up to 31 features. For high-dimensional settings, the causal discovery step becomes unreliable.

**Verified contribution.** The automated causal discovery pipeline removes the main practical barrier to deploying causal SHAP. The empirical demonstration on synthetic data with known ground truth convincingly shows the method's ability to distinguish correlation from causation. Scalability to high-dimensional settings (d > 100) and robustness to PC algorithm violations are **unverified**.

### Sengupta et al. (2026): ExCIR: Correlation-Aware Global Attribution with Efficiency

**The cost problem.** Causal SHAP requires causal discovery, which is computationally expensive and has strong assumptions. What if we do not need causation, but simply need to be aware of correlation and handle it correctly? ExCIR argues that for many practical applications, a correlation-aware score that avoids double-counting correlated features is sufficient {% include references/cite.html key="11498186" %}.

**The method: ExCIR (Correlation-Aware Feature Attribution).** ExCIR computes a global (dataset-level, not instance-level) feature attribution score in a single deterministic pass:

1. **Sign-aligned co-movement**: For each feature, compute its correlation with the model output after robust mid-mean centring, producing a raw score that is positive when the feature moves in the same direction as the output.
2. **Groupwise scoring via BlockCIR**: To handle correlated feature groups, BlockCIR computes attribution for a block of correlated features as a unit, mitigating the double-counting that occurs when correlated features each receive individual credit for shared signal.
3. **Lightweight transfer protocol**: A subsampling method reproduces full attribution rankings using 20% to 40% of the data, achieving 3x to 9x further speedup.

**Key results.** ExCIR achieves strong agreement with SHAP (Kendall-τ = 0.82) at approximately 100× less computational cost (0.17 seconds vs. SHAP's order-of-magnitude higher runtime). The method is validated across 29 diverse benchmarks spanning text, tabular, signals, images, and networks. This is the broadest empirical validation among the papers in this series.

**The subsampling frontier.** ExCIR's lightweight transfer protocol reveals a striking pattern: the Pareto frontier of accuracy versus data fraction consistently shows a knee at 20% to 40% data, and this holds across all five data modalities tested. This suggests a universal property of ranking-preserving subsampling that is independent of data type. If confirmed by independent replication, this finding would have practical value far beyond ExCIR: any method that produces global feature rankings could use 30% of the data for rapid prototyping with predictable quality degradation.

**Class-conditioned extension.** For multi-class models, ExCIR can be computed per class by restricting the output to class-specific logits before computing the co-movement measure. This produces a class-conditioned attribution for each feature, revealing which features drive each class. The extension is natural given ExCIR's deterministic design and requires negligible additional computation.

**The trade-off.** ExCIR fundamentally captures association, not causation. Its scores will be near zero for purely nonlinear relationships that the sign-aligned co-movement measure does not capture. The BlockCIR window size requires a heuristic selection.

**Verified contribution.** The broad cross-domain validation (29 benchmarks) provides strong evidence of the method's generalisability. The computational efficiency advantage over SHAP is clearly demonstrated. The method does not address causal attribution; it is explicitly correlation-aware, not causal. This is stated honestly as a design choice. The correlation-causation gap means ExCIR cannot replace causal attribution when causal claims are required.

### Chen, Hu and Liu (2026): C3A: Contrastive Attribution for Few-Shot Learning

**The regime problem.** Few-shot learning models operate in a fundamentally different regime from standard classifiers. They must generalise from one to five examples per class, which forces their backbone networks to learn compressed, highly entangled feature representations. C3A discovers that this compression causes standard attribution methods (including Grad-CAM, LIME, and SHAP) to produce over-smoothed, uninformative explanations {% include references/cite.html key="11449430" %}.

The root cause is that standard methods attribute at the image level, but FSL models make decisions based on local descriptors extracted from feature maps. The compressions collapse discriminative detail, and the resulting attributions reflect the coarse feature map rather than the actual decision signal.

**The method: C3A (Contrastive Cross-Class Attribution).** The C3A approach strikes me as the one most likely to generalise beyond its stated domain. Contrastivity is core to how humans reason about explanations: we understand a decision not by its absolute properties but by comparison to alternatives. A method that makes this comparative reasoning explicit is operating in a space that standard attribution methods cannot reach. C3A operates in three stages:

1. **Local descriptor extraction**: Given a query image, extract dense local descriptors from the backbone feature map.
2. **Contrastive metric computation**: For each descriptor, compute its similarity to the target class (via k-nearest-neighbour to target class descriptors in a support set) and to competing classes. The contrastive score is the ratio of intraclass to interclass similarity.
3. **Attribution map construction**: Aggregate per-descriptor contrastive scores into a pixel-level attribution map, highlighting regions that are discriminative for the target class relative to competitors.

**Key results.** C3A achieves absolute gains of 19.72% in iAUC and 25.88% in dAAC over state-of-the-art FSL XAI methods across Conv64F and ResNet12 backbones on four few-shot benchmarks (miniImageNet, tieredImageNet, CIFAR-FS, FC100). The qualitative examples show that C3A recoveries fine-grained discriminative features that standard methods miss entirely.

**The trade-off.** C3A is specific to few-shot learning; it exploits the episodic training structure and support-set contrast that defines the FSL paradigm. It requires access to the backbone's feature maps, which is a white-box requirement, and it requires a support set for the contrast computation.

**Verified contribution.** The discovery that FSL feature compression degrades standard attributions is a novel finding with implications beyond XAI for FSL. It suggests that embedding structure itself shapes explanation quality in ways the field has not systematically studied. The empirical gains over existing FSL XAI methods are substantial and validated across multiple benchmarks. Generalisability beyond few-shot image classification to other low-data regimes (e.g., few-shot text or time series classification) is **unverified**.

---

## Cross-Paper Synthesis: Three Different Answers to the Dependency Problem

### What each paper assumes about the problem

| Method      | Problem framed as                                 | Solution approach              | Causal claim                   |
| ----------- | ------------------------------------------------- | ------------------------------ | ------------------------------ |
| Causal SHAP | Need for causal graph → automation                | PC algorithm + IDA             | Yes: interventional            |
| ExCIR       | Need for efficiency with correlation awareness    | Association scoring + grouping | No: explicitly correlational   |
| C3A         | Feature compression in FSL → contrastive decoding | Local descriptor contrast      | Structural (not causal per se) |

The three papers do not compete. They address distinct facets of the dependency problem, and their different starting assumptions lead to different solution properties.

### When correlation awareness is enough

ExCIR raises an important question that the field has not settled: for which decisions do we need causal attributions, and when is correlation awareness sufficient? The answer depends on the decision's stakes and reversibility. A low-stakes, high-volume decision (e.g., product recommendation) can tolerate correlation-aware explanations because the cost of a misattribution is low. A high-stakes decision (e.g., medical diagnosis, loan denial) demands causal attribution because regulatory and ethical accountability requires answering counterfactual questions about what would have happened if a feature had been different.

### The contrastive dimension

C3A introduces a dimension that neither Causal SHAP nor ExCIR addresses: contrastivity. An attribution that says "feature X is important" is less informative than one that says "feature X distinguishes class A from class B." The contrastive framing matches how humans reason about decisions. We want to know not just what drove the outcome, but what made the difference. This dimension is underexplored in the causality literature.

### The scalability challenge

All three methods face scalability constraints that limit their applicability to large-scale models. Causal SHAP is tested only up to 31 features. ExCIR scales better but is limited to global (not instance-level) attribution. C3A requires backbone feature maps and a support set. None has been demonstrated on models with billions of parameters or on very high-dimensional inputs.

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

The papers reviewed here reveal that the dependency problem has no universal solution for the same reason the original attribution problem has none: the right answer depends on what kind of dependency is causing the trouble, and different dependencies require different remedies. Correlated features that are both predictive require correlation-aware grouping. Features correlated through confounding require causal discovery. Features compressed in representation space require contrastive decoding.

The important practical question is not which method is best but which dependency type dominates in a given application. A recommendation system with hundreds of correlated product features needs ExCIR. A medical diagnosis model with confounded risk factors needs Causal SHAP. A few-shot image classifier needs C3A. The next article in this series synthesises these findings into a decision framework for practitioners navigating the method space and deploying attribution within governance structures.

---

_Part 4 of a five-part series on feature attribution, explainability, and interpretability. Educational and research content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise._

<details markdown="1" class="appendix-callout group">
<summary>Technical Appendix</summary>

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

  <dt><dt><dfn>Mid-mean centring</dfn></dt>
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

---

_Publication: 1 July 2026_
_License: Educational and research use. Attribution required for substantive reuse._
