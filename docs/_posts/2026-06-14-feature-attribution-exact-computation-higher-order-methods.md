---
layout: post
last_modified_at: 2026-06-14
title: "Attribution Methods for Exact Computation and Higher-Order Interactions"
author: Zenith Law
description: "Four papers push beyond standard post-hoc attribution: exact computation for feedforward networks, higher-order interaction terms, optimised Shapley rewards, and multi-objective trade-off frameworks."
permalink: /feature-attribution-exact-computation-higher-order-methods
intro: "Standard attribution methods are approximate: they sample, they perturb, they linearise. Four recent papers abandon approximation in favour of exact computation, higher-order interaction modelling, explicit optimisation of evaluation criteria, and multi-objective trade-off surfaces. One computes exact attributions for feedforward networks. Another extends Integrated Gradients to capture feature interactions via operator theory. A third optimises Shapley-value rewards for generality and precision directly. The fourth treats explanation quality as a multi-objective problem with conflicting criteria. Each method solves a specific limitation of standard attributions, and each reveals different facets of what it means for an attribution to be good."
image: /assets/images/feature-attribution-exact-computation-higher-order-methods.png
hero:
  image: /assets/images/feature-attribution-exact-computation-higher-order-methods.png
keywords: "exact feature attribution, feedforward neural network explainability, higher-order integrated gradients, GAPS Shapley attribution, MOFAE multi-objective XAI, faithful attribution exact computation, feature interaction attribution, XAI trade-off analysis, model-specific attribution methods, attribution evaluation criteria"
catchwords: "exact attribution, FACE method, higher-order interactions, GAPS, MOFAE, model-specific XAI, faithful attribution, Pareto-optimal explanations, integrated gradients extension, Shapley optimisation"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - 11461829
  - CARLESBOU2026108277
  - 10021127
  - 10.1145/3617380
related_posts:
  - title: "Feature Attribution: Theoretical Foundations and the Limits of Verifiability"
    url: /feature-attribution-foundations-limits-verifiability
  - title: "Measuring Attribution Quality: Metrics, Benchmarks, and Evaluation Frameworks"
    url: /measuring-feature-attribution-quality-metrics-benchmarks
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - feature attribution
  - explainable AI
  - exact computation
  - higher-order interactions
  - integrated gradients
  - Shapley value
  - multi-objective optimisation
  - feedforward neural network
---

## Introduction

The gap between theory and practice in feature attribution is not primarily a gap in accuracy. It is a gap in kind. Standard methods such as LIME, SHAP, and Integrated Gradients produce approximate scores that mix genuine model signal with artefacts of the approximation. Janzing et al. challenged the theoretical foundations. Bhalla et al. proved the approximations cannot be checked. The papers reviewed here take a different approach: instead of asking whether attributions can be trusted, they ask how to compute them better.

Each of the four papers in this review abandons a different simplifying assumption that made standard methods tractable. Carles-Bou and Carmona abandon model agnosticism: if you know the architecture, you can compute exact attributions. Butler et al. abandon first-order thinking: feature interactions require higher-order attribution operators. Daley et al. abandon the passive Shapley calculation: instead of computing and then evaluating, they optimise for evaluation criteria directly. Wang et al. abandon the single-best-explanation assumption: different stakeholders need different trade-offs, and those trade-offs should be explicit.

None of these methods is a drop-in replacement for standard SHAP or LIME. Each makes deliberate trade-offs: architectural specificity, computational cost, interpretability of the output. Understanding those trade-offs is the purpose of the review that follows.

Technical commentary for education and research synthesis. Not legal, regulatory, or procurement advice.

## Key Terms

<dl>
  <dt><dfn>Model-specific attribution</dfn></dt>
  <dd>An attribution method that exploits knowledge of the model architecture (e.g., activation functions, weight matrices) to compute explanations, as opposed to model-agnostic methods that treat the model as a black box.</dd>

  <dt><dfn>Higher-order attribution</dfn></dt>
  <dd>An attribution that captures interactions between features, typically by computing second-order (or higher) derivatives that measure how the importance of one feature changes with the value of another.</dd>

  <dt><dfn>Piecewise-linear network</dfn></dt>
  <dd>A neural network using activation functions such as ReLU that partition the input space into linear regions, within which the network behaves as a linear function of its inputs.</dd>

  <dt><dfn>Pareto front</dfn></dt>
  <dd>The set of solutions in a multi-objective optimisation problem where no single objective can be improved without degrading another, providing a spectrum of acceptable trade-offs rather than a single best solution.</dd>

  <dt><dfn>Generality (in attribution)</dfn></dt>
  <dd>The consistency of an attribution across instances of the same class: a general explanation assigns similar importance to similar features for similar predictions.</dd>

  <dt><dfn>Precision (in attribution)</dfn></dt>
  <dd>The degree to which an attribution avoids assigning importance to features that would support a different class: a precise explanation is specific to the predicted class.</dd>
</dl>

---

## Four Routes Beyond Approximation

### Carles-Bou and Carmona (2026): Exact Attribution Through Architecture Exploitation

**The gap.** All attribution methods that treat the model as a black box are fundamentally approximate. They sample, perturb, or linearise because they have no access to the model's internal structure. A 2026 paper in Neural Networks asks a specific question: what if you do have access, and the model has a specific, well-understood architecture? {% include references/cite.html key="CARLESBOU2026108277" %}

**The method: FACE (Feature Attribution Computed Exactly).** FACE exploits the piecewise-linear nature of feedforward neural networks with ReLU activations. For any given input, the activation pattern of each neuron determines which linear region of the input space the point falls into. Within that region, the entire network is a linear function of the input: the composition of learned weight matrices and activation patterns yields a single linear transformation. Attribution is then computed exactly as the Hadamard product of the composite weight matrix with the input. This is a closed-form computation requiring no sampling, no perturbation, and no approximations. In my reading, FACE's result that exact computation can be cheaper than approximation is the most underappreciated finding in this batch. The field has accepted approximation overhead as inevitable for so long that a method proving otherwise demands attention.

**The mechanics of exactness.** FACE exploits the structure of piecewise-linear networks. For any input, each ReLU neuron's activation pattern partitions the input space into linear regions. Within a given region, the network reduces to a single linear transformation: the composition of learned weight matrices conditioned on the activation pattern. This composite weight matrix Wᵢ, when combined with the input via Hadamard product, yields the exact attribution. The critical insight is that the forward pass determines which linear region the input falls into, and within that region, the backward pass recovers the exact linear coefficients. No sampling, no perturbation, and no numerical integration is required.

**What makes this different.** Standard attribution methods must trade computational cost against accuracy. FACE does not: it is exact by construction. The paper demonstrates perfect fidelity (ICC2/kappa = 1.000) across all datasets and architectures, which is a mathematical necessity given the method's design. FACE is also 1 to 2 orders of magnitude faster than LIME and kernelSHAP because it requires only a single forward and backward pass.

**The trade-off.** FACE is architecture-specific. It works for feedforward networks with piecewise-linear activations. Convolutional networks with pooling layers, transformers with attention, and recurrent architectures are not covered. The method also requires white-box access to weights; it does not apply to API-only model access scenarios.

**Verified contribution.** The mathematical derivation of exact FNN attribution is sound. The fidelity and speed advantages over model-agnostic methods on comparable architectures are verified within the paper's experimental scope. Scalability to very deep networks and generalisation to non-piecewise-linear activations are **unverified** and may face fundamental mathematical obstacles.

### Butler, Feng and Djurić (2026): Higher-Order Attribution Through Operator Theory

**The limitation.** Standard Integrated Gradients produces a single importance score per feature. It captures first-order effects: how much does changing this feature change the output? But features interact. The importance of one feature may depend on the value of another. Those interactions are invisible to first-order methods.

A 2026 ICASSP paper addresses this by developing an operator-theoretic framework that extends Integrated Gradients naturally to higher orders {% include references/cite.html key="11461829" %}

**The framework.** The insight is to view first-order attribution as a linear operator Aᵢ applied to the predictive function f(x). The attribution for feature i is Aᵢf(x). Second-order attribution corresponds to the composition AᵢAⱼf(x), which yields the Integrated Hessian, measuring how the importance of feature i changes with feature j. Higher orders follow the same compositional pattern.

The framework satisfies several desirable properties: linearity, symmetry (second-order attribution for i,j equals that for j,i), marginalisation (summing second-order attributions over j recovers the first-order attribution for i), and completeness (the sum of all attributions at all orders equals the prediction difference).

**The marginalisation property is practically important.** It means that a practitioner can compute first-order attributions using standard IG, then optionally expand to higher orders for interaction analysis without changing the base attributions. The first-order scores remain valid regardless of whether second-order terms are computed. This backward-compatibility with existing IG implementations lowers the adoption barrier.

**Connection to other fields.** The paper draws an explicit connection between XAI attribution and topological signal processing: first-order attributions correspond to node signals on a graph, second-order to edge signals, and higher-order terms to simplicial complexes. This framing opens the possibility of applying graph-theoretic tools (spectral analysis, community detection, graph Laplacian methods) to attribution analysis. On a housing valuation dataset, second-order attribution graphs reveal clusters of jointly-acting features: distance to metro, number of stores, and latitude form a natural cluster that would be invisible to first-order methods.

**The trade-off.** Higher-order attributions multiply the computational cost: second-order requires O(d²) computations for d features. The paper's empirical validation is limited to two small tabular experiments, and the method's behaviour on high-dimensional data (images, text) is not evaluated.

**Verified contribution.** The operator-theoretic unification of first-order and higher-order attribution is mathematically elegant and connects several previously disparate literatures. The satisfaction of axiomatic properties is proven. Empirical validation beyond two small tabular datasets is **unverified**, and computational tractability at scale is an open question.

### Daley et al. (2022): GAPS: Attribution as Optimisation

**The framing.** Both LIME and SHAP produce attributions, but a prior study by Ratul et al. showed that they perform poorly on two specific quality criteria: generality (consistency across same-class instances) and precision (avoiding explanations that would fit a different class). GAPS takes a different approach: if we know the evaluation criteria, we should optimise for them directly rather than hoping general-purpose methods happen to satisfy them {% include references/cite.html key="10021127" %}

**The method: GAPS (Generality and Precision Shapley Attributions).** GAPS introduces a reward function for Shapley-value-style attribution that combines three terms:

- Confidence expectation (how confident is the model in its prediction given this feature subset?)
- Same-class confidence reward (does the explanation produce high confidence for the correct class?)
- Opposite-class penalty (does the explanation inadvertently produce high confidence for the wrong class?)

The coefficients of this three-term objective become the attribution scores, computed via KernelSHAP-weighted linear regression. The method directly optimises the properties that generality and precision metrics measure.

**Key results.** On the UNSW-NB15 cybersecurity dataset, GAPS outperforms both LIME and SHAP on generality and precision. On the ICS Power System dataset, GAPS outperforms LIME but does not consistently outperform SHAP, suggesting that the benefit is domain-dependent.

**The trade-off.** GAPS requires defining what generality and precision mean for the specific task, introduces three hyperparameters (the reward term weights), and has been evaluated only on binary classification with Random Forest classifiers. The paper lacks theoretical guarantees about convergence or uniqueness of the solution.

**Verified contribution.** The framing of attribution generation as direct optimisation of evaluation criteria is conceptually important and empirically demonstrated on two datasets. The comparative advantage over LIME and SHAP is **partially verified**: it holds on one of two datasets. Generalisation to multi-class, deep learning, and regression settings is **unverified**.

### Wang et al. (2024): MOFAE: Attribution as Multi-Objective Optimisation

**The challenge.** The previous papers assumed that there is a single best attribution for a given prediction. MOFAE challenges this assumption directly: what if explanation quality has multiple, conflicting dimensions, and no single explanation can maximise them all? {% include references/cite.html key="10.1145/3617380" %}

**The method: MOFAE (Multi-Objective Feature Attribution Explanation).** MOFAE treats feature-attribution explanation as a multi-objective optimisation problem with three objectives:

- **Faithfulness**: how well does the explanation predict the model's behaviour when features are removed?
- **Average sensitivity**: how stable is the explanation to small input perturbations?
- **Complexity**: how simple is the explanation (measured via entropy)?

The NSGA-III evolutionary algorithm evolves a population of candidate explanation vectors, each representing a different trade-off among the three objectives. The result is a Pareto front of explanations rather than a single output.

**Key results.** Across 8 UCI tabular datasets, MOFAE solutions dominate competitor methods (Gradient Descent, Integrated Gradients, Gradient\*Input, SmoothGrad, LIME, SHAP) in 33.72% to 80.20% of pairwise comparisons while being dominated only 0% to 0.07% of the time. The Pareto front reveals qualitatively different explanations at its extremes: high-faithfulness explanations use many features; low-complexity explanations focus on few.

**When MOFAE struggles.** The Iris and German Credit datasets are "hard" for MOFAE. On German Credit, MOFAE solutions dominate Integrated Gradients in only 0.03% of comparisons. This suggests that for datasets with strong inherent structure or well-separated classes, gradient-based methods are already near-optimal on all three objectives, and the multi-objective search has little room for improvement. The finding is informative: MOFAE's value is greatest when the default methods are known to be incomplete, not when they already perform well.

**The trade-off.** Each explanation requires a full evolutionary run (~6 seconds for small tabular datasets), which limits real-time deployment. Interpreting the Pareto front requires domain expertise; stakeholders must choose which trade-off point is acceptable for their use case.

**Verified contribution.** The demonstration that explanation quality metrics are inherently conflicting is a significant empirical finding validated across multiple datasets. The Pareto-front approach gives users explicit control over trade-offs that other methods hide. Real-time applicability is **unverified**: the computational cost of NSGA-III evolutionary search is prohibitive for interactive settings.

---

## Cross-Paper Synthesis: Four Strategies for Better Attribution

### The approximation spectrum

The four papers occupy distinct positions on a spectrum from full model access to complete agnosticism:

| Method          | Model access            | Approximation                | Computation               | Generality                 |
| --------------- | ----------------------- | ---------------------------- | ------------------------- | -------------------------- |
| FACE            | White-box (weights)     | None (exact)                 | Very fast                 | FNN only                   |
| Higher-Order IG | White-box (gradients)   | Linear approx. at each order | O(d²) per order           | Any differentiable model   |
| GAPS            | Black-box (predictions) | Shapley approx. via sampling | Modest                    | Any model (tested RF only) |
| MOFAE           | Black-box (predictions) | Evolutionary search          | Expensive (~6s per point) | Any model                  |

No single method dominates. The choice depends on what the practitioner knows about the model, how much computation they can afford, and which aspects of explanation quality matter most for their use case.

### The interaction blind spot

First-order attribution, the default for LIME, SHAP, and Integrated Gradients, misses interactions by construction. Butler et al. provide a theoretical framework for going beyond first order, but the computational cost scales quadratically. MOFAE can in principle capture interactions through the faithfulness objective, since a faithful explanation of a highly interactive model would need to reflect those interactions. But none of these methods makes interactions easy to visualise or communicate to non-expert stakeholders.

### Optimisation vs. computation

A deeper distinction separates FACE and Higher-Order IG (which compute attributions) from GAPS and MOFAE (which optimise them). Computing an attribution assumes there is a ground-truth importance that the method should recover. Optimising an attribution assumes there are multiple desirable properties and the method should find a point in trade-off space. These are philosophically different positions. The evaluation literature (covered in Article 3 of this series) has not yet settled which framing is more productive.

### The missing pieces

- **Large-scale validation**: None of these methods has been demonstrated on models with more than tens of millions of parameters.
- **User studies**: None evaluates whether the improved attributions lead to better human decision-making.
- **Temporal and sequential data**: All four methods are designed for static, tabular or image inputs.

---

## Questions on Attribution Methods

### Can FACE be extended to transformers?

Not directly. Transformers use attention mechanisms and layer normalisation, which do not produce piecewise-linear regions in the same way as ReLU-activated feedforward networks. A transformer-specific exact method would require a different mathematical approach.

### How does MOFAE's Pareto front help a practitioner?

It forces explicit trade-off decisions. A healthcare deployment might prioritise faithfulness (the explanation must accurately reflect the model) over complexity (the explanation can be long). A consumer-facing product might invert those priorities. MOFAE generates both options and lets the domain expert choose, rather than hiding the trade-off inside a single score.

### Is GAPS's reward function architecture-dependent?

The reward function operates on model predictions, which are available for any architecture. The paper's restriction to Random Forest is a choice about experimental scope, not a limitation of the method.

### Does higher-order attribution always improve explanation quality?

Not necessarily. Higher-order terms increase interpretability cost: a stakeholder who struggles to understand first-order attributions will be overwhelmed by second-order interaction maps. The value of higher-order attribution depends on whether feature interactions are materially important for the decision. This question can be answered empirically before deploying the explanation method.

### Which of these methods is closest to production-ready?

FACE is the most mature for its target architecture (FNNs) and offers a clear advantage over approximations. MOFAE and higher-order IG require further scalability work. GAPS needs broader validation across model types and domains.

---

## Conclusion

What unites these four papers is a shift in what a good attribution method looks like. The previous generation of methods aimed at universal applicability: SHAP and LIME work on any model, any domain, any task. The methods reviewed here accept reduced scope in exchange for stronger guarantees: exactness for specific architectures, interaction sensitivity at higher computational cost, direct optimisation of known criteria, and explicit trade-off visualisation. This is a maturing field, not a fragmenting one.

The open question for practitioners is whether the available exact and optimised methods cover their use case. For feedforward networks, FACE is a direct replacement for approximate methods. For problems requiring interaction analysis, higher-order IG provides a principled framework. For teams with known evaluation criteria, GAPS offers a bespoke alternative. The next article in this series asks how to evaluate whether any of these methods actually produces better explanations than the approximate alternatives they seek to replace.

---

_Part 2 of a five-part series on feature attribution, explainability, and interpretability. Educational and research content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise._

<details markdown="1" class="appendix-callout group">
<summary>Technical Appendix</summary>

### Appendix Table of Contents

- Author and Source Credibility
- Corpus Reviewed
- Citability Snapshot
- Technical Term Definitions
- Method Comparison Matrix
- Evidence Maturity Map

### Author and Source Credibility

All four papers appear in peer-reviewed venues: Neural Networks (Elsevier, Carles-Bou), ICASSP (IEEE, Butler), IEEE Big Data (Daley), and ACM TELO (Wang). Venue quality ranges from top journal (Neural Networks) to workshop-track conference (IEEE Big Data). None is a predatory or non-archival publication.

### Corpus Reviewed

1. Carles-Bou, J.L. and Carmona, E.J. (2026) 'Achieving faithful explainability in feedforward neural networks through accurately computed feature attribution', _Neural Networks_, 195, 108277. doi:10.1016/j.neunet.2025.108277.
2. Butler, K., Feng, G. and Djurić, P.M. (2026) 'Higher-order feature attribution: bridging statistics, explainable AI, and topological signal processing', in _ICASSP 2026_. IEEE. doi:10.1109/ICASSP55912.2026.11461829.
3. Daley, B., Ratul, Q.E.A., Serra, E. and Cuzzocrea, A. (2022) 'GAPS: generality and precision with Shapley attribution', in _2022 IEEE International Conference on Big Data (Big Data)_. IEEE. doi:10.1109/BigData55660.2022.10021127.
4. Wang, Z., Huang, C., Li, Y. and Yao, X. (2024) 'Multi-objective feature attribution explanation for explainable machine learning', _ACM Transactions on Evolutionary Learning_, 4(1), Article 2. doi:10.1145/3617380.

### Citability Snapshot

| Criterion            | FACE              | Higher-Order IG    | GAPS                | MOFAE           |
| -------------------- | ----------------- | ------------------ | ------------------- | --------------- |
| Methodology          | Exact computation | Operator theory    | Reward optimisation | MOO + evolution |
| Venue                | Neural Networks   | ICASSP             | IEEE Big Data       | ACM TELO        |
| Empirical breadth    | Multiple datasets | 2 tabular datasets | 2 datasets          | 8 UCI datasets  |
| Architecture support | FNN only          | Differentiable     | Any (RF tested)     | Any             |
| Production readiness | High (for FNNs)   | Low                | Low to Medium       | Low             |

### Technical Term Definitions

<dl>
  <dt><dfn>Integrated Hessian</dfn></dt>
  <dd>The second-order extension of Integrated Gradients, measuring how the importance of one feature changes with the value of another by integrating the mixed partial derivative along the interpolation path.</dd>

  <dt><dfn>NSGA-III</dfn></dt>
  <dd>A reference-point-based multi-objective evolutionary algorithm that maintains diversity in the Pareto front by guiding search toward well-spread reference directions in objective space.</dd>

  <dt><dfn>Hadamard product</dfn></dt>
  <dd>An element-wise multiplication of two matrices or vectors of the same dimensions, used in FACE to combine the composite weight matrix with the input.</dd>

  <dt><dfn>ICC2 (Intraclass Correlation Coefficient type 2)</dfn></dt>
  <dd>A measure of absolute agreement between two sets of ratings, used by Carles-Bou and Carmona to quantify the fidelity of their computed attributions against ground-truth model behaviour.</dd>
</dl>

### Method Comparison Matrix

| Property               | FACE                  | Higher-Order IG         | GAPS                  | MOFAE                   |
| ---------------------- | --------------------- | ----------------------- | --------------------- | ----------------------- |
| Exact or approximate   | Exact                 | Approximate (per-order) | Approximate (Shapley) | Approximate (evolution) |
| Handles interactions   | No (first-order only) | Yes (any order)         | Implicitly            | Via faithfulness        |
| Model access needed    | Weights               | Gradients               | Predictions           | Predictions             |
| Compute cost per point | O(d)                  | O(d²) per order         | Variable              | ~6 seconds              |
| Hyperparameters        | 0                     | Order k                 | 3 reward weights      | NSGA-III parameters     |

### Evidence Maturity Map

1. **Proof-based (verified within assumptions)**: (a) FACE exactness for piecewise-linear FNNs; (b) higher-order IG completeness property.
2. **Demonstrated with empirical evidence (bounded)**: (a) FACE speed and fidelity on multiple datasets; (b) MOFAE Pareto dominance over comparators on 8 UCI datasets; (c) GAPS generality/precision improvement on UNSW-NB15.
3. **Partial or contradictory evidence**: GAPS on ICS Power System (fails to outperform SHAP).
4. **Inferred synthesis (not directly tested)**: (a) scalability of higher-order IG to high-dimensional data; (b) production readiness of MOFAE under latency constraints; (c) applicability of FACE beyond FNN architectures.

</details>

---

_Publication: 23 June 2026_
_License: Educational and research use. Attribution required for substantive reuse._
