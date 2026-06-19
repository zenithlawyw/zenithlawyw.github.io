---
layout: post
last_modified_at: 2026-06-26
title: "Feature Attribution in Practice: Selection, Pipelines, and Governance"
author: Zenith Law
description: "A synthesis of 15 core papers and domain applications into practical guidance: how to select attribution methods, integrate them into ML pipelines, and govern their use in production systems."
permalink: /feature-attribution-practice-selection-pipelines-governance
intro: "Four articles. Fifteen core papers. Diverse domains. This final article in the series translates the research into practice: how to select an attribution method given your model type, domain, and accountability requirements; how to integrate attribution into ML pipelines; and what governance structures are needed to ensure explanations serve their intended purpose. The synthesis draws on Kost et al.'s XAI-guided feature selection framework, domain applications from energy forecasting to medical imaging, and four major surveys that establish the broader XAI literature. The message is pragmatic: feature attribution is too immature for universal standards, too important to ignore, and too domain-dependent for one-size-fits-all guidance."
image: /assets/images/feature-attribution-practice-selection-pipelines-governance.png
hero:
  image: /assets/images/feature-attribution-practice-selection-pipelines-governance.png
keywords: "XAI deployment practice, feature attribution selection, XAI governance framework, Kost XAI feature selection, healthcare XAI energy forecasting, XAI pipeline integration, explainable AI production, ML governance explainability, attribution method comparison, domain-specific XAI"
catchwords: "XAI in practice, attribution method selection, feature selection SHAP, production explainability, ML governance, domain applications, Kost framework, XAI pipeline, organisational accountability, EU AI Act compliance"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - KOST2025100648
related_posts:
  - title: "Feature Attribution: Theoretical Foundations and the Limits of Verifiability"
    url: /feature-attribution-foundations-limits-verifiability
  - title: "Attribution Methods for Exact Computation and Higher-Order Interactions"
    url: /feature-attribution-exact-computation-higher-order-methods
  - title: "Measuring Attribution Quality: Metrics, Benchmarks, and Evaluation Frameworks"
    url: /measuring-feature-attribution-quality-metrics-benchmarks
  - title: "Breaking Free from Correlation: Causal and Dependency-Aware Attribution"
    url: /breaking-free-from-correlation-causal-dependency-aware-attribution
categories:
  - Artificial Intelligence
  - Machine Learning
  - Software Engineering
tags:
  - feature attribution
  - XAI deployment
  - production machine learning
  - ML governance
  - feature selection
  - domain applications
  - practical guidance
  - energy forecasting
  - healthcare AI
  - medical imaging
---

## Introduction

Four articles established what feature attribution can and cannot deliver: individual attributions from black-box models cannot be verified; exact computation is possible for specific architectures; no single evaluation metric is sufficient; standard methods conflate association with causation. The practitioner's question follows: what should you actually do?

The answer is not a single recommendation. It is a decision framework organised around the variables that matter: model access, domain stakes, regulatory requirements, computational budget, and stakeholder needs. The synthesis draws on Kost et al.'s XAI-guided feature selection framework as a worked example, a distillation of domain applications, and the major XAI surveys that establish context.

This article is not legal advice.

## Operational and Governance Vocabulary

<dl>
  <dt><dfn>Feature governance</dfn></dt>
  <dd>The organisational practice of documenting, monitoring, and controlling which features are used in ML models, including periodic review of feature relevance, data quality, and drift.</dd>

  <dt><dfn>Dominance index</dfn></dt>
  <dd>A Herfindahl-Hirschman-based measure of how concentrated feature importance is, where high dominance indicates that a single feature drives most of the model's predictive power.</dd>

  <dt><dfn>Model documentation</dfn></dt>
  <dd>The practice of producing structured metadata about a model's intended use, training data, evaluation results, and limitations, formalised by Mitchell et al. (2019) as Model Cards.</dd>

  <dt><dfn>Stakeholder-appropriate explanation</dfn></dt>
  <dd>An explanation whose complexity, format, and content match the intended audience's technical expertise and decision-making needs, as opposed to a single explanation format for all audiences.</dd>

  <dt><dfn>Cost-aware feature selection</dfn></dt>
  <dd>Feature selection that accounts for the acquisition cost of each feature, not just its predictive contribution, enabling trade-offs between model performance and operational expense.</dd>
</dl>

---

## A Worked Example: Kost, Lier and Breitner (2025)

The XAI-FS framework by Kost et al. is the only paper in the selected set that directly addresses how attribution methods should be used within an ML development pipeline {% include references/cite.html key="KOST2025100648" %}. It is therefore the natural starting point for practice-oriented synthesis.

The scenario is a photovoltaic energy forecasting task with 15 features where Global Horizontal Irradiance dominates. The practitioner has two concerns: whether overdependence on GHI creates brittleness, and whether features can be removed to reduce data acquisition costs. The XAI-FS pipeline trains the model and computes attributions (SHAP, ELI5), computes a Herfindahl-Hirschman-based dominance index (GHI scores 0.365, indicating high concentration), tags each feature with acquisition cost, applies a multi-objective decision function balancing accuracy, dominance, and cost, and recommends feature removal. Removing GHI reduces R² from 0.943 to 0.934 while cutting dominance to 0.169 and improving noise robustness.

The framework turns attribution into a design-stage governance tool: the question becomes not "did the model predict correctly?" but "is the model's feature reliance healthy?"

> **Scope:** Validated on a single dataset with gradient boosting only. Uses SHAP and ELI5 but not the newer methods reviewed in this series. The dominance index does not capture interaction effects or dynamic importance under distribution shift. The framework also does not address how attribution-based feature selection interacts with regulatory requirements such as the EU AI Act's transparency obligations, which may mandate retention of specific features for explainability regardless of predictive importance.

---

## Domain Applications: What the Wider Literature Shows

The tier 3 papers in the selection analysis apply attribution methods to specific domains. While none is a standalone methodological contribution, together they reveal patterns about how attribution works in practice.

### Energy and climate (most represented)

The largest domain cluster is energy and climate forecasting, with five papers applying SHAP to wind, solar, heating load, and monsoon prediction. The pattern across all five is consistent: SHAP identifies a small number of dominant physical features that match domain expert intuition. Temporal features (hour of day, day of year) and lagged values of the target variable consistently receive high importance. This alignment with domain knowledge is treated as validation of the attribution method, but it raises a question the papers do not fully address: if attributions merely confirm what domain experts already know, what value do they add?

The answer, from Kost et al., is that the value is in quantification, not discovery. Knowing that GHI is important is not new; knowing that its dominance index is 0.365 and removing it costs only 0.009 in R² is actionable.

### Healthcare and medical imaging (most sensitive)

Four healthcare applications appear, ranging from chronic kidney disease risk prediction (Hina et al., using SHAP) to whole-slide image analysis (Vu et al., using Contrastive Integrated Gradients) and ECG interpretation (van der Valk et al., using VAE disentanglement). The healthcare context imposes requirements that the energy papers do not face: regulatory oversight, the need for causal (not just correlational) explanations, and the requirement that explanations be interpretable by clinicians, not data scientists.

The healthcare papers also reveal a gap. None evaluates whether the provided explanations actually improve clinical decision-making. The assumption that more explainable models lead to better clinician decisions remains untested in the reviewed literature. This is not merely a gap in the papers reviewed here; it reflects a structural limitation of the attribution evaluation field as a whole. User studies are expensive, domain-specific, and difficult to publish in ML venues. Until the research community incentivises deployment-stage evaluation, claims that attribution methods improve decision-making will remain unsupported by direct evidence.

### Finance and cryptocurrency (most challenging)

Two papers apply SHAP to financial time series (cryptocurrency and stock price forecasting). The short-term, high-noise nature of financial data makes attribution fundamentally harder than in physical domains. Feature importance rankings are less stable; small changes in input can produce large changes in attributions; and the non-stationary nature of financial markets means that feature importance itself is time-dependent. These papers validate SHAP's ability to produce _some_ attribution, but do not establish its reliability for financial decision-making.

A deeper issue is that financial attribution faces a ground-truth problem that even synthetic benchmarks cannot fully address. In energy forecasting, the physical relationship between irradiance and solar power output provides a natural validation signal. In finance, the data-generating process is itself shaped by human behaviour, which is not decomposable into independent feature contributions. An attribution method that assigns importance to a technical indicator in a price prediction may be correct relative to the model but meaningless relative to the actual market dynamics the model approximates. This does not make financial XAI useless, but it means practitioners must be correspondingly more cautious about interpreting attributions as explanations of real-world phenomena.

### Geoscience and remote sensing (scalability test)

Two papers apply SHAP at scale to spatiotemporal Earth observation data: European summer wildfires (24 features, continental scale) and coastal land subsidence (InSAR data). These demonstrate that SHAP can be deployed on realistic spatial scales, but the computational cost of Shapley-value approximation becomes a practical concern at this scale.

### Cross-domain patterns

| Domain         | Attribution value         | Key challenge         | Maturity |
| -------------- | ------------------------- | --------------------- | -------- |
| Energy/climate | Quantifying known drivers | Temporal dependencies | High     |
| Healthcare     | Regulatory compliance     | Causal necessity      | Medium   |
| Finance        | Signal in noise           | Instability           | Low      |
| Geoscience     | Scalable analysis         | Computational cost    | Medium   |

---

## Lessons from the Surveys

Four surveys in the selection provide the broader context within which the methodological papers sit.

Ullah et al. (2025) review 155 XAI papers and establish taxonomy dimensions useful for any practitioner designing an XAI strategy. Their key finding: the field skews toward image domains and gradient-based methods, while tabular and time series (the most common production formats) are underserved. A practitioner building a tabular model cannot rely on the field's default recommendations.

Laato et al. (2022) systematically review how to explain AI systems to end users and find that most XAI research assumes a technically literate audience. The explanation formats studied rarely match non-expert stakeholder needs. Deploying an attribution method is not the same as providing an explanation: the output must be translated into a stakeholder-appropriate format, and that translation is itself a design problem.

Preet et al. (2025) provide a pedagogical survey of SHAP useful for team onboarding, covering foundations, implementation variants, and the common pitfall Janzing et al. identified: users do not realise they are choosing between interventional and conditional Shapley values.

Mitchell et al. (2019) introduce Model Cards as a documentation standard. Model Cards are complementary to feature attribution: attribution explains individual decisions, while Model Cards explain the model as a whole.

---

## A Decision Framework for Attribution Method Selection

If I were advising a team starting their XAI journey today, I would tell them to start with the decision framework below and budget at least as much for evaluation as for explanation generation. Drawing on all 15 core papers, the domain applications, and the surveys, I propose a structured decision framework organised by three questions.

### Question 1: What model access do you have?

| Access level                   | Available methods                                      | Limitation                     |
| ------------------------------ | ------------------------------------------------------ | ------------------------------ |
| Black-box (API only)           | LIME, SHAP (KernelSHAP), GAPS, MOFAE                   | Cannot use FACE, ExCIR, or C3A |
| Gradients (white-box)          | Integrated Gradients, Higher-Order IG, SHAP (DeepSHAP) | Requires differentiable model  |
| Weights (white-box)            | FACE                                                   | FNN architectures only         |
| Feature maps (white-box)       | C3A                                                    | FSL models only                |
| Internal structure (white-box) | Decision-path inspection                               | Tree models only               |

### Question 2: What does your domain require?

| Domain requirement         | Preferred approach                                  | Methods to consider               | Methods to avoid               |
| -------------------------- | --------------------------------------------------- | --------------------------------- | ------------------------------ |
| Causal explanation         | Causal SHAP (if < 30 features), ExCIR for awareness | Causal SHAP, ExCIR                | Standard SHAP, LIME            |
| Regulatory audit           | Verifiable attribution, documentation               | VerT-adapted models + Model Cards | Any unverified post-hoc method |
| Low-latency deployment     | FACE (if FNN), ExCIR (global)                       | FACE, ExCIR                       | MOFAE, Higher-Order IG         |
| Human-interpretable output | Contrastive attribution                             | C3A, contrastive SHAP             | Higher-order (complexity)      |
| High-dimensional input     | Standard SHAP or LIME                               | KernelSHAP, LIME                  | Methods requiring feature maps |

### Question 3: What evaluation standard applies?

- **Research publication**: Use at least two evaluation paradigms (e.g., model-centric + data-centric). Report results across multiple datasets. Follow Dehdarirad's multi-factorial approach by stratifying results by evidence type or class.
- **Production deployment**: Supplement automated metrics with human evaluation on a representative sample. Use Moreira et al.'s decision-path inspection for any tree-based model.
- **Regulatory compliance**: The verification impossibility is a live compliance risk. Consider Model Cards for model-level documentation and accept that individual prediction explanations from black-box models cannot be independently verified.

---

## Ten Practical Lessons from This Series

1. **Do not trust a single attribution you cannot cross-validate.** The impossibility result applies to individual explanations. Aggregate statistics across many predictions are more reliable.

2. **Know your Shapley variant.** If you use SHAP, you must know whether your implementation uses interventional or conditional expectations. The difference is not an implementation detail; it changes what the scores mean.

3. **Exact attribution is not a luxury; it is a standard.** For feedforward networks, FACE shows that exact attribution is computationally cheaper than approximation. If your architecture supports it, use it.

4. **Feature interactions will be invisible unless you look for them.** First-order attribution methods miss interactions by construction. For high-stakes settings, supplement first-order with higher-order or interaction-aware analysis.

5. **Evaluation metrics are not interchangeable.** Each metric captures a different aspect of explanation quality. Triangulate across paradigms and acknowledge what each metric misses.

6. **Correlation is not causation, even in attribution.** Causal SHAP and ExCIR offer different responses to this problem. Choose based on whether your use case requires causal claims or can tolerate correlational awareness.

7. **Attribution is a design-stage tool, not just a post-hoc one.** Kost et al.'s XAI-FS shows that attribution can guide feature selection, monitor dominance, and manage acquisition costs well before a model reaches production.

8. **Domain alignment validates but does not substitute for rigour.** Alignment with domain expert intuition is reassuring but not sufficient. Systematic evaluation remains necessary even when attributions look right.

9. **Explainability does not equal a good explanation.** The attribution output must be translated into a format appropriate for the stakeholder. The field's default outputs (heatmaps, bar charts) are poorly suited for non-technical audiences.

10. **The field is converging on conditional guidance.** There is no universal best attribution method. The papers in this series converge on a framework of conditional recommendations: the right method depends on model architecture, domain stakes, evaluation standard, and stakeholder needs.

---

## Questions on Attribution in Practice

### Should I use SHAP or LIME as my default?

The evidence in this series shows both have known failure modes. SHAP conflates correlation with causation (Janzing, Ng). LIME underperforms on time series (Troncoso-García). Use the decision framework above to select based on your specific constraints, and always validate with at least one metric from a different paradigm.

### How should attribution be integrated into an ML pipeline?

At three points: (1) feature selection stage (Kost's XAI-FS approach), (2) model validation stage (evaluation against domain expert baselines), (3) production monitoring stage (tracking attribution stability under distribution shift). Production monitoring for attribution drift is analogous to data and concept drift monitoring: track the rank correlation between current and baseline feature importance distributions, and alert when it drops below a threshold. Most current practice only addresses the second stage.

### What should I tell a regulator about my explanations?

Be honest about what they cannot do. Standard post-hoc explanations from black-box models cannot be verified for individual cases (Bhalla). They are aggregate statistical summaries, not guarantees of model behaviour. If a regulator requires verifiable explanations, you need either an inherently interpretable model or a VerT-adapted model.

### How much should I invest in attribution infrastructure?

Proportional to the cost of an incorrect explanation. For a product recommendation system, lightweight SHAP or LIME may suffice. For a medical diagnostic aid, invest in stronger methods (FACE or Causal SHAP), multi-paradigm evaluation, and stakeholder-specific explanation formats.

### What is the single most important thing a practitioner should do?

Triangulate. Do not rely on a single attribution method, a single evaluation metric, or a single validation dataset. The evidence in this series consistently shows that results are conditional on choices that are easy to overlook when using a single method.

---

## Conclusion

The series supports a convergent conclusion: responsible attribution requires accepting that the field's ambition exceeded its foundations. The response is not abandonment but specialisation. Practitioners who understand the specific constraints of their domain, model, and regulatory context will produce more reliable attributions than those who deploy a general-purpose method and trust its output.

Each new method comes with sharper applicability conditions: exactness for FNNs only, causal discovery under sufficiency assumptions, correlation awareness at the cost of causal claims. This is a sign of a field maturing. The practitioner's best strategy is to be informed about the limits, rigorous in evaluation, and honest with stakeholders about what attribution can and cannot guarantee.

---

_Concludes a series on feature attribution, explainability, and interpretability. Technical and educational content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise. Organisational deployment decisions should be reviewed under applicable professional and regulatory obligations._

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Technical Appendix" %}

### Appendix Table of Contents

- Author and Source Credibility
- Corpus Reviewed
- Citability Snapshot
- Technical Term Definitions
- Full Series Reference Map
- Evidence Maturity Map

### Author and Source Credibility

The primary paper for this article (Kost et al.) appears in Energy and AI (Elsevier), a reputable domain-specific journal. The four surveys appear in diverse venues: a general XAI journal (Ullah), a human-computer interaction review (Laato), a pedagogical outlet (Preet), and a famous workshop paper at ACM FAT\* (Mitchell). Mitchell et al.'s Model Cards paper, while not archival, is one of the most influential works in the broader AI governance literature.

### Corpus Reviewed

1. Kost, L., Lier, S.K. and Breitner, M.H. (2025) 'An explainable artificial intelligence feature selection framework for transparent, trustworthy, and cost-efficient energy forecasting', _Energy and AI_, 22, 100648. doi:10.1016/j.egyai.2025.100648.
2. Ullah, A.A. et al. (2025) 'Explainable artificial intelligence: importance, use domains, stages, output shapes, and challenges', _Journal of XAI Research_.
3. Laato, S. et al. (2022) 'How to explain AI systems to end users: a systematic literature review and research agenda', _Journal of XAI Research_.
4. Preet, R. et al. (2025) 'Exploring SHAP: a deep dive into feature attribution for explainable AI', _XAI Journal_.
5. Mitchell, M. et al. (2019) 'Model cards for model reporting', in _Proceedings of the Conference on Fairness, Accountability, and Transparency (FAT_ 2019)\*. ACM.

### Full Series Reference Map

| Article        | Date   | Papers covered                                            | Focus                 |
| -------------- | ------ | --------------------------------------------------------- | --------------------- |
| 1: Foundations | 10 Jun | Causal critique (2020), Verifiability (2023), DiET (2023) | Theoretical limits    |
| 2: Methods     | 14 Jun | FACE, Higher-Order IG, GAPS, MOFAE                        | New computation       |
| 3: Evaluation  | 18 Jun | WAE, RExQUAL, Counterfactual, Dehdarirad                  | Metrics               |
| 4: Dependency  | 22 Jun | Causal SHAP, ExCIR, C3A                                   | Correlation-causation |
| 5: Practice    | 26 Jun | Kost XAI-FS, surveys, domain apps                         | Deployment            |

### Technical Term Definitions

<dl>
  <dt><dfn>Herfindahl-Hirschman Index (HHI)</dfn></dt>
  <dd>An economic concentration measure adapted by Kost et al. to quantify how concentrated feature importance is across the feature set, with higher values indicating dominance by fewer features.</dd>

  <dt><dfn>Distribution shift</dfn></dt>
  <dd>A change in the data distribution between training and deployment that can cause model performance degradation and also change feature importance rankings, requiring ongoing attribution monitoring.</dd>

  <dt><dfn>Stakeholder-appropriate translation</dfn></dt>
  <dd>The process of converting a technical attribution output (feature importance vector, heatmap) into a format appropriate for the intended audience, such as a natural-language explanation or a visual summary.</dd>

  <dt><dfn>Attribution drift monitoring</dfn></dt>
  <dd>The practice of tracking how feature importance rankings change over time in a production system, analogous to data drift and concept drift monitoring but applied to the explanation layer.</dd>
</dl>

### Evidence Maturity Map

1. **Established practice (replicated across settings)**: (a) SHAP as the dominant attribution method in domain applications; (b) alignment between SHAP-identified important features and domain expert intuition.
2. **Emerging practice (validated in limited settings)**: (a) XAI-guided feature selection (Kost, single dataset); (b) causal SHAP for correlation-causation separation (synthetic + biomedical); (c) attribution for cost-aware feature governance.
3. **Gap (no empirical evidence in reviewed literature)**: (a) whether explanations improve end-user decision-making; (b) attribution stability monitoring in production; (c) stakeholder-appropriate explanation formats for non-technical audiences.

</details>
