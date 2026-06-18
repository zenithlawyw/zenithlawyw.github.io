---
layout: post
last_modified_at: 2026-06-18
title: "Measuring Attribution Quality: Metrics, Benchmarks, and Evaluation Frameworks"
author: Zenith Law
description: "Four papers on how to evaluate feature attribution quality: a time-series-specific metric, an association-rule approach, a comprehensive counterfactual benchmark, and a multi-factorial NLP evaluation framework."
permalink: /measuring-feature-attribution-quality-metrics-benchmarks
intro: "If attribution methods cannot be verified for individual cases (as Bhalla et al. proved), how should they be evaluated? The answer is aggregate benchmarking, but the literature disagrees on both the metrics and the methodology. WAE evaluates attributions against data-inherent properties rather than model behaviour. RExQUAL uses association rules to quantify explanation quality for time series. The counterfactual benchmark by Moreira et al. reveals that standard evaluation metrics are insufficient and decision-path inspection is necessary. Dehdarirad's unified framework shows that attribution faithfulness is conditional on model architecture, dataset, and evidence type, with no universal best method. Together, these papers define the current state and limits of attribution evaluation."
image: /assets/images/measuring-feature-attribution-quality-metrics-benchmarks.png
hero:
  image: /assets/images/measuring-feature-attribution-quality-metrics-benchmarks.png
keywords: "XAI evaluation metrics, WAE window-based attribution, RExQUAL association rules, counterfactual benchmark XAI, counterfactual evaluation benchmark, multi-factorial explainability framework, attribution faithfulness metrics, time series XAI evaluation, NLP feature attribution, XAI benchmarking methodology"
catchwords: "attribution evaluation, XAI metrics, WAE, RExQUAL, counterfactual benchmarking, faithfulness measurement, time series attribution, NLP explainability, Dehdarirad framework, decision-path inspection"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - CHEN2025129379
  - 10.1145/3672553
  - 10879535
  - DEHDARIRAD2025100101
related_posts:
  - title: "Feature Attribution: Theoretical Foundations and the Limits of Verifiability"
    url: /feature-attribution-foundations-limits-verifiability
  - title: "Attribution Methods for Exact Computation and Higher-Order Interactions"
    url: /feature-attribution-exact-computation-higher-order-methods
  - title: "Breaking Free from Correlation: Causal and Dependency-Aware Attribution"
    url: /breaking-free-from-correlation-causal-dependency-aware-attribution
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - feature attribution
  - XAI evaluation
  - benchmarking
  - faithfulness
  - time series
  - counterfactual
  - natural language processing
  - evaluation metrics
---

## Introduction

The question that follows from the foundational critique in Article 1 of this series is: if we cannot verify individual attributions, how do we know which method to use? The field's answer is aggregate benchmarking, evaluating attribution methods across many examples and computing summary metrics. But this answer raises its own question: which metrics should we trust?

The four papers in this review approach the evaluation problem from different directions. Chen and Zhang argue that evaluations should be data-centric, comparing attributions against properties of the data rather than the model. Troncoso-García et al. propose association rules as a model-independent quality metric for time series. Moreira et al. conduct the largest counterfactual benchmark to date and conclude that quantitative metrics alone are broken and must be supplemented by decision-path inspection. Dehdarirad runs a multi-factorial experiment showing that attribution faithfulness depends on model type, dataset, and evidence polarity, and that there is no universal best method.

Each paper tells us something different about what evaluation can and cannot establish. Together, they reveal that the evaluation problem is as hard as the attribution problem itself.

Technical commentary for education and research synthesis. Not legal, regulatory, or procurement advice.

## Key Terms

<dl>
  <dt><dfn>Faithfulness metric</dfn></dt>
  <dd>A quantitative measure of how accurately an attribution reflects the model's actual decision process, typically computed by perturbing features and measuring the correlation between attribution scores and prediction changes.</dd>

  <dt><dfn>Counterfactual explanation</dfn></dt>
  <dd>A minimal change to the input that would change the model's prediction, answering the question "what would need to be different for this outcome to change?" rather than "which features were important for this outcome?"</dd>

  <dt><dfn>Decision-path inspection</dfn></dt>
  <dd>A qualitative evaluation method that examines the actual decision rules a model uses (e.g., tree paths) and compares them against the features highlighted by attribution methods, revealing mismatches that quantitative metrics miss.</dd>

  <dt><dfn>AOPC (Area Over the Perturbation Curve)</dfn></dt>
  <dd>A faithfulness metric that measures how quickly the model's prediction changes when features are removed in order of decreasing attribution importance, with steeper drops indicating more faithful attributions.</dd>

  <dt><dfn>Association rule</dfn></dt>
  <dd>A discovered pattern of the form "if features A and B have certain values, then the prediction is C" with associated metrics for support (frequency) and confidence (reliability), used by RExQUAL to evaluate explanation quality.</dd>

  <dt><dfn>Ground-truth proxy</dfn></dt>
  <dd>An indirect measure used as a substitute for true feature importance when ground truth is unavailable, such as using data predictability as a proxy for which features matter in a forecasting task.</dd>
</dl>

---

## Four Approaches to the Evaluation Problem

### Chen and Zhang (2025): Data-Centric Evaluation with WAE

**The circularity problem.** Most faithfulness metrics work by perturbing the model: removing or masking features and measuring how the prediction changes. The WAE paper argues that this creates a circular dependency: you are evaluating an attribution method using the same model it is trying to explain {% include references/cite.html key="CHEN2025129379" %}. If the model is brittle or OOD-sensitive (as the verifiability impossibility proof showed), the evaluation metric itself is unreliable.

**The method: WAE (Window-based Attribution RMSE).** WAE takes a fundamentally different approach. Instead of perturbing the model, it compares attributions against a data-inherent property: the predictability of each time window within the time series. The intuition is that more predictable segments of a time series are driven by stronger, more consistent signals, and an attribution method should assign higher importance to features that correspond to these predictable segments.

The metric is computed in four steps:

1. Estimate the predictability of each time window using real entropy.
2. Compute attribution-based feature importance for the same windows.
3. Aggregate importance over windows and compare against the predictability ranking.
4. The RMSE between the attribution ranking and the predictability ranking is the WAE score.

Two validation hypotheses are confirmed: more advanced methods (SHAP, LEMNA) achieve lower WAE than simpler ones (LIME), and more interpretable datasets yield lower WAE for the same method.

**What makes this different.** WAE is orthogonal to the faithfulness family of metrics. It evaluates against data properties rather than model properties. This means it remains valid even when the model has known OOD sensitivity, the critique that undermines perturbation-based metrics. The trade-off is that WAE assumes a specific relationship between data predictability and feature importance that may not hold for all domains or tasks.

**Verified contribution.** The data-centric framing is a genuine departure from the perturbation-based evaluation paradigm and addresses a real vulnerability in existing metrics. The two validation hypotheses are confirmed on the paper's experimental setup. The core assumption, that predictability is a valid proxy for importance, is **incompletely verified**. The paper does not provide independent evidence linking predictability to human-judged feature relevance.

### Troncoso-García et al. (2025): Model-Independent Evaluation with RExQUAL

**The reference problem.** Evaluating attribution methods requires comparing them against something. Most methods compare against the model (perturbation-based) or the data (data-centric). RExQUAL proposes evaluating against discovered rules: patterns that emerge from the data independent of both the model and the attribution method {% include references/cite.html key="10879535" %}.

**The method: RExQUAL (Rule-based Explanation QUALity).** The metric operates in four stages:

1. Train the predictive model and generate attributions using candidate methods.
2. Extract K key features from each explanation using the elbow method.
3. Run the Apriori association rule mining algorithm to discover rules of the form "if these feature values, then this prediction."
4. Compute RExQUAL as `confidence(Q) × support(Q) × (K_f / K)`, where Q is the rule set, K_f is the number of features actually appearing in rules, and K is the target number.

The metric measures how well the features identified by an attribution method support the generation of high-quality association rules that match the model's behaviour.

**Key results.** On Spanish electric demand and SAGRA evapotranspiration datasets, a method called RULEx achieves the highest RExQUAL (0.876 on SAGRA), followed by SHAP. A Bayesian analysis confirms the statistical significance: probability 0.996 that RULEx outperforms SHAP, and probability 1.0 that both outperform LIME and random selection. LIME performs worse than random, suggesting its linear-surrogate approach is fundamentally unsuited to time series forecasting where local linearity assumptions break down.

**A striking anomaly.** On the multivariate SAGRA dataset, SHAP actually underperforms random feature selection (RExQUAL 0.251 vs 0.482). This suggests that SHAP's attributions may be actively misleading for multivariate time series, not merely uninformative. The implication for practitioners is cautionary: if the only available metric says random selection beats your attribution method, the metric may be flawed, or the method may genuinely be worse than useless for that domain.

**What makes this different.** Unlike perturbation-based metrics, RExQUAL does not require additional model evaluations. Unlike data-centric metrics, it evaluates against discovered structure rather than assumed structure. The association-rule paradigm also provides human-readable rules that could, in principle, be inspected by domain experts.

**Verified contribution.** The RExQUAL framework provides a genuinely novel paradigm for evaluating attribution quality. The finding that LIME underperforms random selection on time series is a strong empirical result. The independence of the metric from model-specific validation is **partially verified**: the association rule quality metrics (support, confidence) require further validation against human judgement.

### Moreira et al. (2025): The Counterfactual Benchmark and Its Broken Metrics

**The insufficiency problem.** Counterfactual explanation methods (which find minimal input changes to alter a prediction) are typically evaluated using quantitative metrics: proximity (how close is the counterfactual to the original?), sparsity (how many features changed?), and validity (does it actually change the prediction?). The largest counterfactual benchmark to date finds these metrics insufficient {% include references/cite.html key="10.1145/3672553" %}.

**The benchmark.** Four counterfactual algorithms (DiCE, GrowingSpheresCF, Prototype, WatcherCF) are evaluated across three model types (Decision Tree, Random Forest, Neural Network) on 25 tabular datasets. The scale (25 datasets is unusually comprehensive for the XAI benchmarking literature) allows the authors to draw comparisons that smaller studies cannot.

**Three key findings.**

First, the underlying model type has no significant impact on counterfactual generation quality. This finding challenged my own assumption that simpler models yield more trustworthy explanations. The data says otherwise: counterfactual algorithms adapt to whatever boundary the model has learned, and the adaption makes model type irrelevant. Counterfactual algorithms are always faithful to their model; they will find a valid counterfactual relative to that model's decision boundary regardless of architecture. Similar patterns are learned across architectures when the data is well-represented. This finding directly challenges the common assumption that simpler models yield better explanations.

Second, quantitative metrics alone cannot distinguish between plausible and implausible explanations. The authors introduce counterfactual inspection analysis via decision path comparison. For example, WatcherCF optimises for minimum proximity (distance from the original point), but paradoxically produces the largest feature changes for certain features (e.g., Age changing from 34 to 81 in a healthcare dataset). The quantitative metric says this is a high-quality counterfactual; the decision-path inspection reveals it is implausible.

Third, DiCE achieves the best practical balance because it explicitly incorporates diversity and plausibility constraints, even though it does not dominate on any single quantitative metric.

**The replication crisis.** The authors observe that the counterfactual XAI field faces an incipient replication crisis. Despite dozens of proposed methods, there is no standardised evaluation framework, no commonly accepted set of benchmark datasets, and no consensus on which metrics matter. The field lacks the infrastructure for cumulative science that other ML subfields (e.g., image classification with ImageNet, NLP with GLUE) have established. This diagnosis, if accurate, applies beyond counterfactuals to the broader attribution evaluation literature.

**Verified contribution.** The finding that model type does not significantly affect counterfactual quality is statistically robust across 25 datasets and multiple model types. The demonstration that quantitative-only evaluation is broken is empirically convincing. The recommendation to supplement metrics with decision-path inspection is well-supported by evidence. The generalisability to non-tabular data (images, text, time series) is **unverified**.

### Dehdarirad (2025): A Multi-Factorial Framework for NLP Attribution

**The generalisation problem.** Most evaluation studies in XAI compare methods on a single metric and a single task, leading to claims that "method X outperforms method Y" that do not generalise. A controlled multi-factorial experiment tests when and why one method outperforms another {% include references/cite.html key="DEHDARIRAD2025100101" %}.

**The framework.** The study compares SHAP, LIME, and Integrated Gradients across:

- **Classical models**: Logistic Regression, Random Forest
- **Transformer models**: DistilBERT, RoBERTa
- **Datasets**: Three binary text classification datasets
- **Evidence type**: Positive (features supporting the prediction) vs negative (features opposing it)
- **Metrics**: Automated (AOPC, log-odds) and human (relevance ratings from 100 raters)

**Key findings.**

First, no universal best method exists. SHAP excels for classical models with positive evidence. LIME performs as well as or better than SHAP on complex transformers for negative evidence. Integrated Gradients produces more faithful explanations for negative evidence with DistilBERT than with RoBERTa. The smaller model yields better explanations.

Second, model scale does not monotonically improve explainability. DistilBERT, despite being smaller and less accurate than RoBERTa, produces more faithful attributions. This challenges the assumption that better models automatically yield better explanations.

Third, human evaluation reveals patterns that automated metrics miss. The correlation between automated faithfulness scores and human relevance ratings is modest, suggesting that current automated metrics capture only part of what makes an explanation useful to a human.

**Verified contribution.** The multi-factorial design provides the strongest available evidence that attribution faithfulness is conditional on model architecture, dataset, and evidence type. The finding of non-monotonic model-scale-explainability is robust within the experiment's scope. Generalisability beyond English text classification (e.g., to multilingual, multimodal, or regression tasks) is **unverified**.

---

## Cross-Paper Synthesis: The State of Attribution Evaluation

### The evaluation crisis is real and structural

All four papers converge on a sobering conclusion: current evaluation methodology is insufficient. Chen and Zhang show that model-centric metrics have a circular dependency problem. Troncoso-García et al. offer an alternative but acknowledge it requires further validation. Moreira et al. prove that quantitative metrics alone are broken. Dehdarirad shows that evaluation results are highly conditional on experimental choices.

The structural problem is that attribution evaluation requires a ground truth that is definitionally unavailable for real-world tasks. Bhalla et al.'s impossibility result is not just a theoretical curiosity. It cascades into the evaluation literature, which must resort to proxies, perturbations, or human judgement, each with its own limitations.

### Three families of evaluation metrics

The papers define three distinct evaluation paradigms, each with different guarantees and limitations:

| Paradigm          | Examples                           | Ground truth                       | Limitation                           |
| ----------------- | ---------------------------------- | ---------------------------------- | ------------------------------------ |
| Model-centric     | AOPC, log-odds, insertion/deletion | Model behaviour under perturbation | OOD sensitivity; circular dependency |
| Data-centric      | WAE                                | Data predictability                | Assumes predictability = importance  |
| Discovery-centric | RExQUAL                            | Association rules                  | Requires validation of rule quality  |
| Human-centric     | User studies, relevance ratings    | Human judgement                    | Expensive; hard to replicate         |

### The convergent validity gap

An open question across all four papers is whether the different evaluation paradigms converge on the same ranking of methods. Dehdarirad's finding of modest correlation between automated and human metrics suggests they may not. The papers do not compare WAE, RExQUAL, AOPC, and human ratings on the same datasets with the same methods. Without such a comparison, we cannot know whether a method that scores well on WAE also scores well on RExQUAL or human evaluation. Convergent validity studies, where multiple metrics from different paradigms are applied to the same experimental setup, are the most urgently needed work in attribution evaluation.

### Practical implications

1. **Triangulate**: No single metric is sufficient. Practitioners should use at least two metrics from different paradigms.
2. **Domain matters**: Dehdarirad's findings suggest evaluation results may not transfer across domains or architectures.
3. **Inspecting > scoring**: Moreira et al.'s decision-path inspection should be a standard complement to quantitative evaluation, especially in high-stakes settings.
4. **Time series needs dedicated treatment**: Both WAE and RExQUAL were developed specifically for time series, and LIME specifically underperforms in this domain.

---

## Questions on Attribution Evaluation

### Can WAE and RExQUAL be used together?

Yes, they measure different things. WAE evaluates against data properties; RExQUAL evaluates against discovered rules. A method that scores well on both provides convergent evidence of quality.

### Does Moreira et al.'s finding about model type generalise beyond counterfactuals?

It has not been tested for attribution methods. The finding that different architectures learn similar patterns on well-represented data is plausible for attribution as well, but the counterfactual-specific nature of the benchmark means direct extrapolation is speculative.

### Is there a standardised benchmark suite for attribution evaluation?

No. The papers reviewed here suggest why: domain, architecture, and task interact too strongly for a single benchmark to be universally informative. The field is moving toward task-specific evaluation suites rather than a single leaderboard.

### How should a practitioner choose between evaluation metrics?

Start by asking: what kind of failure matters most? If false positive attributions (highlighting irrelevant features) are the main risk, use precision-oriented metrics. If false negatives (missing important features) are worse, use recall-oriented metrics or human evaluation. No single metric captures both.

### Does human evaluation correlate with automated metrics?

Dehdarirad's results show modest correlation, suggesting that human and automated metrics capture partially overlapping but distinct constructs. Automated metrics are cheaper and more reproducible; human evaluation is necessary for deployment decisions that affect end users.

---

## Conclusion

The evaluation field faces a structural problem that the papers in this review make visible but do not solve: every evaluation paradigm relies on a proxy for ground truth, and each proxy has blind spots. Perturbation-based metrics break when the model is OOD-sensitive. Data-centric metrics assume predictability equals importance. Rule-based metrics depend on the quality of discovered associations. Human evaluation is expensive and noisy. The solution is not to pick the best proxy but to combine proxies whose blind spots do not overlap.

The most productive direction for future work is not a new metric. It is a systematic understanding of when existing metrics disagree and why. Dehdarirad's multi-factorial approach provides a template: control for model type, dataset, and evidence polarity, and report conditional results rather than aggregate rankings. The field needs fewer single-number claims and more conditional analysis of the form "under these conditions, method X outperforms method Y by this margin on this construct." The next article in this series examines whether the methods themselves can escape the correlational trap that metrics are trying to measure.

---

_Part 3 of a five-part series on feature attribution, explainability, and interpretability. Educational and research content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise._

<details markdown="1" class="appendix-callout group">
<summary>Technical Appendix</summary>

### Appendix Table of Contents

- Author and Source Credibility
- Corpus Reviewed
- Citability Snapshot
- Technical Term Definitions
- Metric Comparison Matrix
- Evidence Maturity Map

### Author and Source Credibility

All four papers appear in established venues: Neurocomputing (Chen & Zhang), TPAMI (IEEE, Troncoso-García), ACM Computing Surveys (Moreira), Data and Information Management (Dehdarirad). Venue quality ranges from top journal (TPAMI, ACM Computing Surveys) to mid-tier (Neurocomputing, Data and Information Management).

### Corpus Reviewed

1. Chen, Y. and Zhang, S. (2025) 'WAE: an evaluation metric for attribution-based XAI on time series forecasting', _Neurocomputing_, 622, 129379. doi:10.1016/j.neucom.2025.129379.
2. Troncoso-García, Á.R., Martínez-Ballesteros, M., Martínez-Álvarez, F. and Troncoso, A. (2025) 'A new metric based on association rules to assess feature-attribution explainability techniques for time series forecasting', _IEEE Transactions on Pattern Analysis and Machine Intelligence_, 47(5), 4140 to 4155. doi:10.1109/TPAMI.2025.3540513.
3. Moreira, C., Chou, Y.-L., Hsieh, C., Ouyang, C., Pereira, J. and Jorge, J. (2025) 'Benchmarking instance-centric counterfactual algorithms for XAI: from white box to black box', _ACM Computing Surveys_, 57(6), Article 145. doi:10.1145/3672553.
4. Dehdarirad, T. (2025) 'Evaluating explainability in language classification models: a unified framework incorporating feature attribution methods and key factors affecting faithfulness', _Data and Information Management_, 9, 100101. doi:10.1016/j.dim.2025.100101.

### Citability Snapshot

| Criterion         | WAE                  | RExQUAL                 | Counterfactual          | Dehdarirad             |
| ----------------- | -------------------- | ----------------------- | ----------------------- | ---------------------- |
| Methodology       | Data-centric metric  | Association-rule metric | Empirical benchmark     | Multi-factorial eval   |
| Venue             | Neurocomputing       | TPAMI                   | ACM Comput. Surv.       | DIM                    |
| Empirical breadth | Multiple TS datasets | 2 TS datasets           | 25 datasets × 4 methods | 3 datasets × 3 methods |
| Domain focus      | Time series          | Time series             | Tabular (general)       | NLP text               |
| Human eval        | No                   | No                      | No                      | Yes (100 raters)       |

### Technical Term Definitions

<dl>
  <dt><dfn>Real entropy</dfn></dt>
  <dd>A measure of the inherent unpredictability of a time series, with lower entropy indicating more predictable windows that are argued to be driven by stronger underlying signals.</dd>

  <dt><dfn>Elbow method</dfn></dt>
  <dd>A heuristic for selecting the number of key features from an attribution ranking by identifying the point where the cumulative importance curve's slope changes most sharply.</dd>

  <dt><dfn>Apriori algorithm</dfn></dt>
  <dd>A classic association rule mining algorithm that identifies frequent itemsets and generates rules with confidence above a threshold, used by RExQUAL to extract rule-based explanations from attribution results.</dd>

  <dt><dfn>Log-odds deletion metric</dfn></dt>
  <dd>A faithfulness metric that measures the change in log-odds of the predicted class as features are removed in order of decreasing importance, quantifying how much each feature contributes to the prediction confidence.</dd>

  <dt><dfn>Plausibility (in counterfactuals)</dfn></dt>
  <dd>The degree to which a counterfactual example could occur in the real world, as opposed to merely satisfying the mathematical constraint of changing the model's prediction.</dd>
</dl>

### Metric Comparison Matrix

| Property               | WAE                  | RExQUAL           | AOPC/Log-odds      | Decision-path   |
| ---------------------- | -------------------- | ----------------- | ------------------ | --------------- |
| Evaluates against      | Data entropy         | Association rules | Model perturbation | Model structure |
| Model access needed    | None                 | None              | Predictions        | White-box       |
| Domain specificity     | Time series          | Time series       | Any                | Tree models     |
| Human interpretability | Medium               | High (as rules)   | Low                | High            |
| Computational cost     | Low (estimates only) | Medium (Apriori)  | Low                | None            |

### Evidence Maturity Map

1. **Strong empirical evidence (replicated across settings)**: (a) Model type has no significant effect on counterfactual quality (Moreira); (b) SHAP outperforms LIME on most tabular benchmarks (Dehdarirad, Moreira).
2. **Demonstrated on limited settings**: (a) WAE validation on time series datasets; (b) RExQUAL on two energy datasets; (c) Dehdarirad's full multi-factorial results.
3. **Partial or contradictory evidence**: LIME performing worse than random on time series (Troncoso-García) vs. acceptable performance on NLP (Dehdarirad).
4. **Inferred synthesis**: (a) Generalisability of Moreira's findings to attribution (not counterfactual) methods; (b) transferability of evaluation results across domains.

</details>

---

_Publication: 27 June 2026_
_License: Educational and research use. Attribution required for substantive reuse._
