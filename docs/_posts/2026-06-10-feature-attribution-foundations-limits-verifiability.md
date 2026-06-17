---
layout: post
last_modified_at: 2026-06-10
title: "Feature Attribution: Theoretical Foundations and the Limits of Verifiability"
author: Zenith Law
description: "Three foundational papers reshape how we think about faithfulness, verifiability, and the causal grounding of feature attributions, with hard limits on what post-hoc methods can guarantee."
permalink: /feature-attribution-foundations-limits-verifiability
intro: "Three papers, published between 2020 and 2023, independently arrived at the same uncomfortable conclusion: standard feature attributions cannot be trusted as reliable explanations of model behaviour. The first uses causal reasoning to expose a fundamental flaw in Shapley-value-based attribution. The second proves that verifiability (the ability to check whether an attribution is correct) is mathematically impossible for black-box models. The companion paper shows that the path to faithful attribution requires changing the model itself, not just improving the explanation method. Together, these papers reshape the theoretical foundations of feature attribution and establish hard limits that any practitioner or researcher must understand before deploying attribution methods in high-stakes settings."
image: /assets/images/feature-attribution-foundations-limits-verifiability.png
hero:
  image: /assets/images/feature-attribution-foundations-limits-verifiability.png
keywords: "feature attribution, explainable AI, XAI foundations, SHAP causal critique, verifiable attributions, verifiability tuning, Shapley values causal critique, faithfulness in XAI, post hoc explainability, inherent interpretability, model verifiability, discriminative feature attribution"
catchwords: "feature attribution, faithfulness, verifiability, causal SHAP critique, distractor erasure tuning, verifiability tuning, post-hoc interpretability, XAI theory, Shapley values, model transparency"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - NEURIPS2023_89beb2a3
  - bhalla2023verifiable
  - pmlr-v108-janzing20a
related_posts:
  - title: "Attribution Methods for Exact Computation and Higher-Order Interactions"
    url: /feature-attribution-exact-computation-higher-order-methods
  - title: "Measuring Attribution Quality: Metrics, Benchmarks, and Evaluation Frameworks"
    url: /measuring-feature-attribution-quality-metrics-benchmarks
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - feature attribution
  - explainable AI
  - XAI
  - faithfulness
  - verifiability
  - Shapley values
  - causal inference
  - interpretability
---

## Introduction

Feature attribution is the dominant paradigm for explaining machine learning model predictions. Given an input and a model, attribution methods assign a relevance score to each feature indicating how much it contributed to the output. The logic is intuitive: if a feature receives a high score, it was important for the decision; if it receives a low score, it was not.

That intuition, three papers argue, is built on sand.

Three foundational works independently identified structural problems with how attribution is conceived, computed, and validated. None of these papers is a survey. Each makes a specific, falsifiable claim about the limits of what attribution methods can deliver. Taken together, they establish the boundary conditions within which all subsequent attribution research operates, whether subsequent work acknowledges them or not.

Technical commentary for education and research synthesis. Not legal, regulatory, or procurement advice.

## Key Terms

<dl>
  <dt><dfn>Feature attribution</dfn></dt>
  <dd>A scalar score assigned to each input feature indicating its contribution to a model's output for a given prediction, forming the basis of most post-hoc explanation methods.</dd>

  <dt><dfn>Faithfulness</dfn></dt>
  <dd>The degree to which an attribution accurately reflects the model's actual decision process, as opposed to artefacts of the explanation method or the model's sensitivity to out-of-distribution inputs.</dd>

  <dt><dfn>Verifiability</dfn></dt>
   <dd>The ability to systematically determine whether a given attribution is correct by comparing predicted model behaviour under feature removal against actual model output, introduced as a formal criterion in the verifiability impossibility paper.</dd>

  <dt><dfn>Post-hoc explainability</dfn></dt>
  <dd>The class of explanation methods applied to an already-trained model without modifying its architecture or training procedure, encompassing methods such as LIME, SHAP, and Integrated Gradients.</dd>

  <dt><dfn>Inherent interpretability</dfn></dt>
  <dd>Models designed from the outset to be interpretable through their structure (e.g., sparse linear models, decision trees with few leaves), as opposed to requiring external explanation.</dd>

  <dt><dfn>Interventional vs observational conditioning</dfn></dt>
  <dd>A distinction from causal inference: interventional conditioning sets a variable's value by intervention (<em>do</em>-operator), while observational conditioning selects only instances where the variable already takes that value, carrying implicit confounding bias.</dd>
</dl>

---

## Three Papers, One Uncomfortable Conclusion

### Janzing, Minorics and Blöbaum (2020): The Causal Critique of Shapley-Value Attribution

**What is at stake.** Shapley-value-based attribution methods such as SHAP {% include references/cite.html key="pmlr-v108-janzing20a" %} rely on a critical design choice: when a subset of features is removed, how should the model behave? Two answers exist in the literature. The conditional approach samples dropped features from their conditional distribution given the kept features. The interventional approach uses the marginal distribution, effectively breaking dependencies between features.

The paper's central claim is that the interventional approach (using unconditional expectations) is the correct one, and that the widespread adoption of conditional expectations in the SHAP literature rests on a misunderstanding of the causal structure of the problem.

**The formal argument.** Lemma 1 proves that conditional expectations violate the Sensitivity axiom of Shapley-value attributions. Consider a two-feature system where f(x₁, x₂) = x₁ and x₂ is correlated with x₁ but causally irrelevant. Under conditional expectations, x₂ receives non-zero attribution because E[f &#124; x₂] changes with x₂ through the correlation. Under interventional (marginal) expectations, x₂ receives zero because E[f(x₁, X₂)] marginalises over X₂. The proof is mathematically straightforward once you commit to a causal framing of what attribution means, but it exposes a choice most users never inspect. The choice between conditional and interventional expectations is not a tuning parameter; it is a decision about what "attribution" means. The paper further shows that attempts to "improve" SHAP by better approximating conditional expectations, such as the approach by Aas et al. (2019), are moving in what the causal analysis reveals is the wrong direction.

**Empirical demonstration.** On synthetic multivariate Gaussian data where ground-truth coefficients are known, interventional expectations yield Shapley-value attributions with substantially lower error against known coefficients. On human activity recognition data, the distinction affects feature rankings materially.

**What this means.** The paper does not say SHAP is useless. It says SHAP's theoretical justification depends on a choice that most users do not realise they are making. The software implementation (KernelExplainer) approximates conditional expectations using a background dataset. The paper argues this is correct only by accident, because the approximation happens to resemble interventional sampling. Any subsequent method that explicitly attempts conditional expectations inherits the sensitivity violation.

**Verified contribution.** The causal formalisation of the dropped-features sampling problem is rigorous and has reshaped the subsequent Shapley-value attribution literature. The claim that interventional expectations satisfy Sensitivity and conditional expectations do not is mathematically proven and replicable. The empirical generalisability beyond Gaussian and HAR data is **unverified**: the paper includes only two experiments.

### Bhalla, Srinivas and Lakkaraju (2023b): The Verifiability Impossibility

**The question.** Suppose an attribution method produces a heatmap or feature-importance vector for a given prediction. Is there any way to check, systematically and for any input, whether that attribution is correct? Verification is a weaker requirement than faithfulness: you do not need the attribution to perfectly reflect the model's reasoning; you only need the ability to detect when it does not.

The paper proves that even this weaker requirement is impossible for standard black-box models {% include references/cite.html key="bhalla2023verifiable" %}.

**The impossibility argument.** The root cause is that masking or removing features (the core mechanism for evaluating attributions) produces out-of-distribution (OOD) inputs. When you set a pixel to zero, replace a word with a mask token, or remove a tabular feature, you are feeding the model an input drawn from a distribution it never saw during training. The model's response to that OOD input need not correspond to its behaviour on the data distribution, making it impossible to distinguish between:

- An incorrect attribution (the method assigned importance to the wrong features), and
- A correct attribution on an OOD input (the feature really was important, but the model's response to the masked input is unreliable).

A key conceptual contribution of this paper is disentangling **attribution correctness** (does the attribution identify discriminative features?) from **model verifiability** (does the model behave consistently when unimportant features are masked?). These are distinct evaluation dimensions that prior work conflated. A model could be verifiable (predictions remain stable under feature removal) while producing incorrect attributions. Conversely, attributions could be correct while the model is unverifiable (predictions change for reasons unrelated to the attribution). The paper argues that the field must evaluate both dimensions separately, not collapse them into a single faithfulness score.

**VerT: Verifiability Tuning.** The paper does not stop at the negative result. It proposes Verifiability Tuning (VerT), which transforms the model itself so that masking unimportant features does not change predictions. A model is verifiable when, for any input and any feature subset, the prediction with masked features matches the prediction with original features if and only if the masked features are genuinely irrelevant. On MNIST, VerT achieves near-perfect verifiability (ℓ₁ prediction difference of 0.027), meaning attributions can now be checked.

**A surprising negative result.** Input dropout training, a common approach for encouraging robustness (where the model is trained on randomly masked inputs), actually reduces verifiability compared to the original model. On MNIST, the original model achieves a verifiability ℓ₁ of 0.107, the VerT-adapted model 0.027, but the input-dropout model scores 0.167, worse than no adaptation. Random masking teaches the model to ignore any feature, not specifically the non-discriminative ones, which makes the model's behaviour under masking harder to interpret, not easier.

**What this means.** The impossibility result is permanent for any model that has not been specifically adapted for verifiability. Practitioners cannot check whether a LIME or SHAP explanation on a standard model is correct. The only path to verifiable attribution is to change the model, which means accepting the accuracy-verifiability trade-off that VerT introduces. Input dropout, which might seem like a lightweight alternative to VerT, is counterproductive.

**Verified contribution.** The formal proof that standard black-box attributions are unverifiable is rigorous. The empirical demonstration of VerT's effectiveness on MNIST is replicable. The generalisability of VerT to complex architectures (Transformers, large vision models) is **unverified**: the paper's experiments focus on smaller-scale settings.

### Bhalla, Srinivas and Lakkaraju (2023a): Discriminative Attributions as a Bridge

**The failure mode.** The verifiability paper was about checking attributions. This companion paper asks a different question: what makes an attribution faithful in the first place? The authors identify a specific failure mode called the **distractor hypothesis**: standard attribution methods fail because the model itself is not robust to erasure of non-discriminative features {% include references/cite.html key="NEURIPS2023_89beb2a3" %}.

**The concept of discriminative attributions.** A discriminative attribution assigns high scores only to features that are both necessary and sufficient for the model's decision, ignoring correlated but irrelevant features (distractors). The paper formalises a signal-distractor decomposition as a ground-truth framework for evaluating attributions: features are partitioned into those that carry discriminative signal and those that are noise or accidental correlates.

**DiET: Distractor Erasure Tuning.** The proposed method, Distractor Erasure Tuning (DiET), adapts pre-trained black-box models to become robust against distractor erasure. When a distractor feature is removed, the model's prediction should not change. The training objective alternates between mask learning (which features are distractors for this input?) and model distillation (how can we preserve original predictions while achieving erasure robustness?). After DiET adaptation, gradient-based attribution methods such as GradCAM and Integrated Gradients achieve significantly higher Intersection over Union with ground-truth masks.

**Key results.** Across multiple architectures and datasets, DiET-adapted models produce attributions that match ground-truth signal masks substantially better than the same attribution methods applied to the original model. Prediction agreement between the adapted and original models remains above 0.975. The transformation preserves model behaviour on in-distribution inputs.

**Adversarial robustness.** An additional finding that deserves attention: DiET resists adversarial gradient manipulation even though it does not directly optimise for gradient robustness. Gradient-based attribution methods such as SmoothGrad and GradCAM degrade severely under adversarial attacks designed to manipulate attributions (Heo et al., 2019). DiET's attributions remain stable. This suggests that Q-robustness, the property of maintaining predictions under feature removal, incidentally confers protection against a different threat model entirely.

**What this means.** DiET bridges post-hoc and inherent interpretability without requiring architectural changes. The model remains a black box in deployment, but its behaviour under feature perturbation has been shaped so that standard attribution methods now produce faithful explanations. The paper does not require new explanation methods. It changes the model to make existing methods work.

**Verified contribution.** The formal Q-robustness framework provides a principled way to think about when and why attributions fail. The semi-synthetic ground-truth validation using controlled signal-distractor datasets is replicable. The computational cost of DiET and its scalability to very large models are **unverified**: the paper acknowledges that fine-tuning large models may be expensive.

---

## Cross-Paper Synthesis: The Limits We Cannot Work Around

Three papers with three different entry points converge on a shared picture that is sobering for the XAI field.

### The verification hierarchy

Taken together, the papers establish a hierarchy of progressively stronger properties:

1. **Usability** (not formally studied in these papers): An attribution is produced and displayed. The evaluation literature (Articles 3 and 4 of this series) examines this empirically.
2. **Correctness**: An attribution accurately reflects the true feature importance for this prediction. This is what most methods claim approximately.
3. **Verifiability**: The ability to check correctness. Proved impossible for black-box models without transformation.
4. **Faithfulness**: Correctness under erasure of non-discriminative features. Requires model-level intervention.
5. **Causal soundness**: Correctness with respect to interventional (not observational) queries. Requires careful design choice in the attribution method itself.

Each layer depends on the one below. Without verifiability, correctness claims cannot be checked. Without causal soundness, the attribution scores conflate correlation with causation. Without faithfulness, the attribution may reflect OOD sensitivity rather than genuine model reasoning.

### The model-centric turn

A radical implication runs through both Bhalla papers: the problem is not the attribution method. The problem is the model. You cannot fix explanation quality without modifying what is being explained. This is a fundamentally different stance from the mainstream XAI literature, which treats the model as fixed and searches for better explanation techniques.

### Three papers, one shared formalism

The three papers share a deeper mathematical connection than is immediately apparent. All three rely on the concept of Q-counterfactuals: removing features and replacing them with values drawn from a distribution Q. Janzing argues that Q must be the marginal (interventional) distribution for causal correctness. Bhalla et al. show that when Q is fixed and the model is adapted to it (via VerT or DiET), the Q-counterfactual evaluation becomes reliable. The choice of Q thus connects the causal, verifiability, and discriminative analyses. Changing Q changes what the attribution means, which distribution the model must be robust to, and which evaluation paradigm applies. This unified perspective is rarely stated explicitly in the literature but emerges clearly when the three papers are read together.

### Remaining open questions

- **Scale**: Do DiET and VerT scale to models with hundreds of billions of parameters?
- **Interaction effects**: The causal analysis of Shapley values is about individual features. How do interactions change the picture?
- **Temporal attribution**: How does the verifiability framing extend to time series, where feature removal must respect temporal structure?
- **Practical guidance**: If standard attributions cannot be verified, what should practitioners do today?

These questions guide the subsequent articles in this series.

---

## Questions on Foundational Attribution Theory

### If standard attributions cannot be verified, why do they remain widely used?

Because the impossibility result applies to checking any individual attribution, not to evaluating aggregate performance across many examples. Practitioners can still compare methods on benchmarks, track consistency across similar inputs, and use domain expertise to spot implausible explanations. The result says: do not trust any single attribution you cannot cross-validate.

### Does the Janzing critique apply to TreeSHAP?

TreeSHAP uses conditional expectations by exploiting the tree structure to compute them exactly. Janzing's critique applies: conditional SHAP assigns non-zero attribution to features that are correlated with the target but causally irrelevant. Whether this is acceptable depends on whether the user wants a causal or predictive decomposition of the model's output. This is a distinction the paper argues many practitioners do not recognise.

### Is VerT compatible with DiET?

The two methods are complementary. DiET makes models robust to distractor removal, improving attribution correctness. VerT ensures that correctness can be checked. A model could be both discriminatively trained and verifiable. The papers were published independently from the same group and share training infrastructure, but the combined effect has not been empirically evaluated.

### Does the impossibility result apply to inherently interpretable models?

No. The proof assumes a black-box model where the internal decision boundary cannot be inspected. Decision trees with few leaves, sparse linear models, and rule-based systems are verifiable by construction because their decision logic is transparent. This is a direct argument for inherent interpretability in high-stakes applications.

### How do these foundational critiques relate to the EU AI Act's explainability requirements?

The EU AI Act requires that high-risk AI systems provide meaningful explanations of their decisions. The impossibility result raises a compliance question: if a standard black-box model's attributions cannot be verified, can they constitute a "meaningful explanation" under the regulation? This tension is unresolved in the legal literature and is likely to be tested as enforcement begins.

---

## Conclusion

The next question, given unverifiable attributions, is whether the field can build evaluation frameworks that are honest about their limits. That requires metrics that do not depend on perturbing the very models whose fragility we now recognise, evaluation paradigms that treat ground-truth absence as a design constraint rather than an inconvenience, and methods that are transparent about their causal assumptions. Each of these directions has its own trade-offs, examined in the articles that follow.

None of the critiques reviewed here invalidates attribution methods. They do, however, change what responsible use looks like. An attribution you cannot verify is a diagnostic signal, not a certified fact. A Shapley-value ranking that ignores causal structure is a correlation summary, not an explanation. Practitioners who understand these limits are in a stronger position than those who trust their tools uncritically. The papers that follow in this series examine how the field is building tools that respect these boundaries.

---

_Part 1 of a five-part series on feature attribution, explainability, and interpretability. Educational and research content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise._

<details markdown="1" class="appendix-callout group">
<summary>Technical Appendix</summary>

### Appendix Table of Contents

- Author and Source Credibility
- Corpus Reviewed
- Citability Snapshot
- Technical Term Definitions
- Evidence Maturity Map

### Author and Source Credibility

All three papers appear in top-tier venues: NeurIPS (DiET), ICML (VerT), and AISTATS (Janzing). Bhalla et al. are from Harvard and the University of Chicago; Janzing et al. are from the Max Planck Institute for Intelligent Systems. All three papers have been cited as foundational works in subsequent XAI literature.

### Corpus Reviewed

1. Janzing, D., Minorics, L. and Blöbaum, P. (2020) 'Feature relevance quantification in explainable AI: a causal problem', in _Proceedings of the 23rd International Conference on Artificial Intelligence and Statistics (AISTATS 2020)_. PMLR, 108.
2. Bhalla, U., Srinivas, S. and Lakkaraju, H. (2023a) 'Discriminative feature attributions: bridging post hoc explainability and inherent interpretability', in _Advances in Neural Information Processing Systems 37 (NeurIPS 2023)_.
3. Bhalla, U., Srinivas, S. and Lakkaraju, H. (2023b) 'Verifiable feature attributions: a bridge between post hoc explainability and inherent interpretability', in _Proceedings of the 40th International Conference on Machine Learning (ICML 2023)_. PMLR 202.

### Citability Snapshot

| Criterion         | Causal Critique (2020) | Verifiability (2023) | DiET (2023)         |
| ----------------- | ---------------------- | -------------------- | ------------------- |
| Methodology       | Causal formalisation   | Impossibility proof  | Training framework  |
| Provenance        | AISTATS (top-tier)     | ICML (top-tier)      | NeurIPS (top-tier)  |
| Venue type        | Conference             | Conference           | Conference          |
| Empirical breadth | 2 datasets             | Focused on MNIST     | 3+ architectures    |
| Replicability     | Gaussian + HAR         | Verified on MNIST    | Semi-synthetic GT   |
| Theoretical rigor | [H] Proof-based        | [H] Proof-based      | [M] Framework-based |

[H] = High, [M] = Medium

### Technical Term Definitions

<dl>
  <dt><dfn>Shapley value</dfn></dt>
  <dd>A solution concept from cooperative game theory that distributes the total value of a coalition among its members based on each member's marginal contribution, averaged over all possible coalitions.</dd>

  <dt><dfn>Sensitivity axiom</dfn></dt>
  <dd>The requirement that a feature that never appears in any optimal coalition (and thus never affects the prediction in any context) should receive zero attribution, analogous to the dummy player axiom in game theory.</dd>

  <dt><dfn>Distractor feature</dfn></dt>
  <dd>A feature that is correlated with the target in the training data but is not part of the model's actual decision boundary, causing attribution methods to assign importance to it spuriously.</dd>

  <dt><dfn>Out-of-distribution (OOD) sensitivity</dfn></dt>
  <dd>The tendency of machine learning models to produce unreliable outputs on inputs that fall outside their training distribution, which is the root cause of the verifiability impossibility.</dd>

  <dt><dfn>Q-robustness</dfn></dt>
  <dd>A property introduced by Bhalla et al. where a model's prediction remains unchanged when non-discriminative (distractor) features are removed, characterised by <em>Q</em> levels corresponding to the fraction of features a model can lose without changing its output.</dd>
</dl>

### Evidence Maturity Map

1. **Proof-based (verified within assumptions)**: (a) The sensitivity violation under conditional expectations; (b) The impossibility proof for black-box verifiability.
2. **Demonstrated with empirical evidence (bounded)**: (a) DiET attribution improvement on semi-synthetic data; (b) VerT verifiability on MNIST.
3. **Inferred synthesis (not directly tested)**: (a) Compatibility of DiET and VerT; (b) scalability to large language or vision models; (c) generalisability of Janzing's empirical findings beyond Gaussian and HAR data.

</details>

---

_Publication: 19 June 2026_
_License: Educational and research use. Attribution required for substantive reuse._
