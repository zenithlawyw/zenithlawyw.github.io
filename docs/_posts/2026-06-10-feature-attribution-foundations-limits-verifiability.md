---
layout: post
last_modified_at: 2026-06-10
title: "Feature Attribution: Theoretical Foundations and the Limits of Verifiability"
author: Zenith Law
description: "Three foundational papers reshape how we think about faithfulness, verifiability, and the causal grounding of feature attributions, with hard limits on what post-hoc methods can guarantee."
permalink: /feature-attribution-foundations-limits-verifiability
intro: "Three papers, published between 2020 and 2023, independently arrived at the same uncomfortable conclusion: standard feature attributions cannot be trusted as reliable explanations of model behaviour. The first uses causal reasoning to expose a fundamental flaw in Shapley-value-based attribution. The second proves that verifiability (the ability to check whether an attribution is correct) is mathematically impossible for standard black-box models, but proposes Verifiability Tuning as a constructive path around this limitation. The third, a companion paper to the second, shows that the path to faithful attribution requires changing the model itself, not just improving the explanation method. Together, these papers reshape the theoretical foundations of feature attribution and establish hard limits that any practitioner or researcher must understand before deploying attribution methods in high-stakes settings."
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

Standard feature attributions carry a guarantee they cannot honour. Three papers, published between 2020 and 2023, each proved a different piece of the problem from complementary angles: Janzing et al. (2020) showed that Shapley-value attributions conflate correlation with causation unless the value function is chosen correctly; Bhalla et al. (2023b) proved that black-box attributions cannot be verified for individual cases without model adaptation; and Bhalla et al. (2023a) demonstrated that the only reliable path to faithful attribution requires changing the model itself, not swapping explanation methods.

Each paper's core argument, formal mechanism, and evidentiary support are examined below. Together they establish hard limits that any practitioner deploying attribution methods in high-stakes settings must confront.

This article is not legal advice.

## Vocabulary for Attribution Theory

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

The choice between conditional and interventional expectations when removing features is the single most consequential decision in Shapley-value attribution, and most users never inspect it. {% include references/cite.html key="pmlr-v108-janzing20a" %} The paper's central claim is that the interventional approach is the correct one, a position that remains actively debated in the literature. The paper argues that the widespread adoption of conditional expectations in the SHAP literature rests on a misunderstanding of the causal structure of the problem. The core demonstration, presented as a formal argument, shows that conditional expectations violate the Sensitivity axiom of Shapley-value attributions: consider a two-feature system where f(x₁, x₂) = x₁ and x₂ is causally irrelevant but correlated with x₁. Under conditional expectations, x₂ receives non-zero attribution. Under interventional (marginal) expectations, x₂ receives zero. The proof is mathematically straightforward once you commit to a causal framing, but it exposes a choice most users never inspect.

> **Core claim:** The choice between conditional and interventional expectations is not a tuning parameter. It is a decision about what "attribution" means.

On synthetic multivariate Gaussian data with known coefficients, interventional expectations yield substantially lower attribution error. On human activity recognition data, the distinction affects feature rankings materially. The paper does not say SHAP is useless. It says SHAP's theoretical justification depends on an unexamined design choice, and attempts to "improve" SHAP by better approximating conditional expectations are moving in the wrong direction.

**Study limitations:** The empirical demonstration covers only two datasets (Gaussian synthetic and HAR). Generalisability beyond these settings is unconfirmed. The causal formalisation of the dropped-features sampling problem is rigorous, and the sensitivity violation proof is mathematically sound and replicable, but the empirical breadth is narrow.

### Bhalla, Srinivas and Lakkaraju (2023b): The Verifiability Impossibility and a Constructive Path

Can an attribution be checked? For standard black-box models, the paper answers with an unambiguous no. {% include references/cite.html key="bhalla2023verifiable" %} Verification is a weaker requirement than faithfulness: you do not need the attribution to perfectly reflect the model's reasoning, only the ability to detect when it does not. The paper proves even that weaker requirement is impossible for unmodified models. The root cause: masking features produces out-of-distribution (OOD) inputs, and the model's response to OOD inputs need not correspond to its behaviour on the training distribution. You cannot distinguish between an incorrect attribution and a correct one evaluated on an unreliable input.

A key conceptual contribution is disentangling **attribution correctness** (does the attribution identify discriminative features?) from **model verifiability** (does the model behave consistently when unimportant features are masked?). These are distinct dimensions that prior work conflated into a single faithfulness score.

The paper does not stop at the negative result. It proposes Verifiability Tuning (VerT), which transforms the model so that masking unimportant features does not change predictions. On MNIST, VerT achieves near-perfect verifiability (ℓ₁ prediction difference of 0.027). A surprising negative result emerges: input dropout training, a common robustness technique, actually reduces verifiability (scoring 0.167 versus the original model's 0.107). Random masking teaches the model to ignore any feature, not specifically the non-discriminative ones.

> **Practical implication:** The impossibility result is permanent for any model not specifically adapted for verifiability. Practitioners cannot check whether a LIME or SHAP explanation on a standard model is correct. Input dropout, which might seem like a lightweight alternative, is counterproductive.

**Study limitations:** The formal proof that standard black-box attributions are unverifiable is rigorous. The VerT demonstration on MNIST is replicable. Generalisability to complex architectures (Transformers, large vision models) is unconfirmed; the paper's experiments focus on smaller-scale settings.

### Bhalla, Srinivas and Lakkaraju (2023a): Discriminative Attributions as a Bridge

The verifiability paper was about checking attributions. This companion paper asks what makes an attribution faithful in the first place. {% include references/cite.html key="NEURIPS2023_89beb2a3" %} The authors identify the **distractor hypothesis**: standard methods fail because the model itself is not robust to erasure of non-discriminative features. A discriminative attribution assigns high scores only to features that are both necessary and sufficient for the model's decision, ignoring correlated but irrelevant distractors. The paper formalises a signal-distractor decomposition as a ground-truth framework: features are partitioned into those carrying discriminative signal and those that are noise or accidental correlates.

Distractor Erasure Tuning (DiET) adapts pre-trained black-box models to become robust against distractor removal. The training objective alternates between mask learning (which features are distractors for this input?) and model distillation (how to preserve predictions while achieving erasure robustness?). After DiET adaptation, gradient-based methods such as GradCAM and Integrated Gradients achieve significantly higher Intersection over Union with ground-truth masks. Prediction agreement between adapted and original models remains above 0.975. The model remains a black box in deployment, but its behaviour under perturbation has been shaped so that standard methods now produce faithful explanations. The paper does not require new explanation methods. It changes the model to make existing methods work.

An additional finding worth highlighting: DiET resists adversarial gradient manipulation even though it does not directly optimise for gradient robustness. Methods such as SmoothGrad and GradCAM degrade severely under adversarial attribution attacks (Heo et al., 2019); DiET's attributions remain stable. Q-robustness, the property of maintaining predictions under feature removal, incidentally confers protection against a different threat model entirely.

> **Design principle:** The problem is not the attribution method. The problem is the model. You cannot fix explanation quality without modifying what is being explained.

**Study limitations:** The formal Q-robustness framework provides a principled way to reason about attribution failure. The semi-synthetic validation using controlled signal-distractor datasets is replicable. The computational cost of DiET and its scalability to very large models are unconfirmed; the paper acknowledges that fine-tuning large models may be expensive.

---

## Cross-Paper Synthesis: The Limits We Cannot Work Around

Three papers with three different entry points converge on a shared picture that is sobering for the XAI field.

### The verification hierarchy

Taken together, the papers establish a hierarchy of progressively stronger properties:

1. **Usability** (not formally studied in these papers): An attribution is produced and displayed. The evaluation literature (forthcoming articles on metrics and causal attribution) examines this empirically.
2. **Correctness**: An attribution accurately reflects the true feature importance for this prediction. This is what most methods claim approximately.
3. **Verifiability**: The ability to check correctness. Proved impossible for black-box models without transformation.
4. **Faithfulness**: Correctness under erasure of non-discriminative features. Requires model-level intervention.
5. **Causal soundness**: Correctness with respect to interventional (not observational) queries. Requires careful design choice in the attribution method itself.

Each layer depends on the one below. Without verifiability, correctness claims cannot be checked. Without causal soundness, the attribution scores conflate correlation with causation. Without faithfulness, the attribution may reflect OOD sensitivity rather than genuine model reasoning.

### The model-centric turn

I find this implication both compelling and unsettling. Compelling because the theoretical case is clear: you cannot explain a model that is not designed to be explainable. Unsettling because standard practice treats the model as fixed and the explanation method as the thing to improve, which the Bhalla papers show is backwards.

A radical implication runs through both Bhalla papers: the problem is not the attribution method. The problem is the model. You cannot fix explanation quality without modifying what is being explained. This stance is fundamentally different from the mainstream XAI literature, which treats the model as fixed and searches for better explanation techniques.

### Three papers, one shared formalism

The three papers share a deeper mathematical connection than is immediately apparent. All three rely on Q-counterfactuals: removing features and replacing them with values drawn from a distribution Q. Janzing argues that Q must be the marginal (interventional) distribution for causal correctness. Bhalla et al. show that when Q is fixed and the model is adapted to it, the Q-counterfactual evaluation becomes reliable. The choice of Q thus connects the causal, verifiability, and discriminative analyses. Changing Q changes what the attribution means. This unified perspective is rarely stated explicitly in the literature but emerges clearly when the three papers are read together.

### A live debate, not a settled one

The three papers present a coherent critique, but they represent one side of an active academic debate. A dissenting position holds that the impossibility result, while formally correct, applies most forcefully to toy settings with extreme OOD sensitivity, and that practitioners using SHAP in well-engineered pipelines with domain-validated features often obtain stable, practically useful attributions. Work by Rudin (2019) and others argues for inherent interpretability as the primary path, suggesting that post-hoc methods should be avoided entirely in high-stakes settings rather than patched through model adaptation. The Bhalla papers' model-centric turn offers a third way, but neither side has yet produced the large-scale, multi-domain evidence needed to resolve the debate. This series aims to inform, not adjudicate.

### Remaining open questions

- **Scale**: Do DiET and VerT scale to models with hundreds of billions of parameters?
- **Interaction effects**: The causal analysis of Shapley values is about individual features. How do interactions change the picture?
- **Temporal attribution**: How does the verifiability framing extend to time series, where feature removal must respect temporal structure?
- **Practical guidance**: If standard attributions cannot be verified, what should practitioners do today?

- **Adversarial attribution attacks**: DiET resists gradient manipulation incidentally; whether verifiability tuning confers systematic adversarial robustness is unexamined.
- **Multimodal and multilingual attribution**: All three papers focus on single-modality (vision or tabular) settings. How the Q-counterfactual framing extends to text, audio, or multimodal models is unexplored.

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

None of the critiques reviewed here invalidates attribution methods. They change what responsible use looks like. An attribution you cannot verify is a diagnostic signal, not a certified fact. A Shapley-value ranking that ignores causal structure is a correlation summary, not an explanation. Practitioners who understand these limits are in a stronger position than those who trust their tools uncritically.

The next question, covered in the [articles that follow](/measuring-feature-attribution-quality-metrics-benchmarks), is whether the field can build evaluation frameworks that are honest about their limits.

---

_Part 1 of a series on feature attribution, explainability, and interpretability. Technical and educational content. Not legal, regulatory, or procurement advice. Claims bounded to the cited papers' own reported results unless explicitly stated otherwise._

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Technical Appendix" %}

### Appendix Table of Contents

- Author and Source Credibility
- Corpus Reviewed
- Citability Snapshot
- Technical Term Definitions
- Evidence Maturity Map

### Author and Source Credibility

Two of the three papers appear in top-tier venues: NeurIPS (DiET) and AISTATS (Janzing). The VerT paper was presented at the ICML 2023 Workshop on Interpretable Machine Learning in Healthcare (IMLH), a more specialised venue. Bhalla et al. are from Harvard and the University of Chicago; Janzing et al. are from the Max Planck Institute for Intelligent Systems. All three papers have been cited as foundational works in subsequent XAI literature.

### Corpus Reviewed

1. Janzing, D., Minorics, L. and Blöbaum, P. (2020) 'Feature relevance quantification in explainable AI: a causal problem', in _Proceedings of the 23rd International Conference on Artificial Intelligence and Statistics (AISTATS 2020)_. PMLR, 108.
2. Bhalla, U., Srinivas, S. and Lakkaraju, H. (2023a) 'Discriminative feature attributions: bridging post hoc explainability and inherent interpretability', in _Advances in Neural Information Processing Systems 37 (NeurIPS 2023)_.
3. Bhalla, U., Srinivas, S. and Lakkaraju, H. (2023b) 'Verifiable feature attributions: a bridge between post hoc explainability and inherent interpretability', in _ICML 2023 Workshop on Interpretable Machine Learning in Healthcare (IMLH)_.

### Citability Snapshot

| Criterion         | Causal Critique (2020) | Verifiability (2023)        | DiET (2023)         |
| ----------------- | ---------------------- | --------------------------- | ------------------- |
| Methodology       | Causal formalisation   | Impossibility proof         | Training framework  |
| Provenance        | AISTATS (top-tier)     | ICML workshop (specialised) | NeurIPS (top-tier)  |
| Venue type        | Conference             | Workshop                    | Conference          |
| Empirical breadth | 2 datasets             | Focused on MNIST            | 3+ architectures    |
| Replicability     | Gaussian + HAR         | Verified on MNIST           | Semi-synthetic GT   |
| Theoretical rigor | [H] Proof-based        | [H] Proof-based             | [M] Framework-based |

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
