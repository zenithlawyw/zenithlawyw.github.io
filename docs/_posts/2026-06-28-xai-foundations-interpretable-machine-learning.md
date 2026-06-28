---
layout: post
last_modified_at: 2026-06-28
title: "What Does It Mean for AI to Be Explainable? Foundations of Interpretable Machine Learning"
author: Zenith Law
description: "A rigorous examination of what interpretability means in machine learning, the taxonomies that organise the XAI field, and the evaluation frameworks that separate genuine understanding from post-hoc rationalisation."
permalink: /foundations-interpretable-machine-learning
intro: "Five papers, spanning 2017 to 2024, collectively establish what interpretability means, how to evaluate it, and where the conceptual boundaries lie. Doshi-Velez and Kim's three-tier evaluation framework, the comprehensive taxonomy of Barredo Arrieta et al., Molnar's practical guide, Watson's philosophical critique, and the knowledge catalogue of Chazette et al. each contribute a distinct piece of the puzzle. Together they reveal that interpretability is neither a single property nor a binary condition. It depends on who is asking, what they need to understand, and at what cost."
image: /assets/images/foundations-interpretable-ml.png
hero:
  image: /assets/images/foundations-interpretable-ml.png
keywords: "interpretable machine learning, XAI foundations, ML interpretability definitions, Doshi-Velez three-tier evaluation, explainable AI taxonomy, interpretability evaluation framework, Molnar interpretable ML, Watson conceptual challenges, XAI evaluation methods, human-grounded evaluation, functionally-grounded evaluation, application-grounded evaluation"
catchwords: "interpretability definition, XAI taxonomy, interpretability evaluation, three-tier framework, intrinsic vs post-hoc, evaluation rigour, conceptual challenges, knowledge catalogue, interpretability spectrum"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - doshivelez2017rigorousscienceinterpretablemachine
  - barredoarrieta2020xai
  - molnar2021interpretable
  - watson2022conceptual
  - chazette2021exploring
related_posts:
  - title: "Methods and Techniques for Explaining Machine Learning Models"
    url: /methods-techniques-explaining-ml-models
  - title: "Critical Perspectives and Limits of Current Explainability Methods"
    url: /critical-perspectives-limits-xai
  - title: "Explainability in Practice: Domains, Evaluation, and Governance"
    url: /explainability-practice-domains-evaluation-governance
  - title: "XAI 2.0 and the Road Ahead: Open Challenges and Future Directions"
    url: /xai20-open-challenges-future-directions
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - interpretable ML
  - XAI foundations
  - interpretability
  - explainable AI
  - ML evaluation
  - conceptual challenges
---

## Introduction

What does it mean for a machine learning model to be interpretable? The question appears straightforward, but five years of sustained investigation have revealed it is anything but. Interpretability is not a single property that a model either possesses or lacks. It is a context-dependent relationship between a model, a human, and a task. The five papers examined in this article each contribute a distinct perspective on this relationship. They address what interpretability is, how to evaluate it, how to achieve it, and where the conceptual boundaries lie.

This article is the first in a five-part series on explainability and interpretability in AI. It establishes the conceptual foundations that the remaining articles build upon.

This article is not legal advice.

## Vocabulary for Interpretability Foundations

<dl>
  <dt><dfn>Interpretability</dfn></dt>
  <dd>The degree to which a human can consistently predict the output of a model. A model is more interpretable than another if its decisions are easier for a human to anticipate. This definition, adapted from Doshi-Velez and Kim, emphasises that interpretability is fundamentally about human understanding, not model architecture.</dd>

  <dt><dfn>Explainability</dfn></dt>
  <dd>A broader concept encompassing both intrinsic interpretability (models that are transparent by design) and post-hoc explanations (methods applied after training to explain individual predictions). Barredo Arrieta et al. define explainable ML as "ML that produces models that are inherently interpretable and/or produces explanations for their predictions."</dd>

  <dt><dfn>Intrinsic interpretability</dfn></dt>
  <dd>Models designed from the outset to be interpretable through their structure: sparse linear models, decision trees with few leaves, rule lists, generalised additive models. The interpretability is a property of the model itself, not an external method.</dd>

  <dt><dfn>Post-hoc interpretability</dfn></dt>
  <dd>Explanation methods applied to an already-trained model without modifying its architecture. Includes LIME, SHAP, Integrated Gradients, LRP, and counterfactual explanations. The interpretability is a property of the explanation method, not the model.</dd>

  <dt><dfn>Application-grounded evaluation</dfn></dt>
  <dd>The highest-validity evaluation tier: measuring interpretability through human performance on the actual task the model is designed to support (e.g., do doctors make better diagnoses with an explainable model?).</dd>

  <dt><dfn>Human-grounded evaluation</dfn></dt>
  <dd>The intermediate evaluation tier: simplified tasks with lay users that test whether explanations support human decision-making in general, without requiring domain expertise (e.g., can people predict the output of a model from its explanation?).</dd>

  <dt><dfn>Functionally-grounded evaluation</dfn></dt>
  <dd>The cheapest evaluation tier: using formal proxy metrics (sparsity, faithfulness, stability) as stand-ins for human understanding. Valid only when the proxy has been empirically validated against human judgement.</dd>
</dl>

---

## Two Frameworks, Three Taxonomies, One Definition

### Doshi-Velez and Kim (2017): The Three-Tier Evaluation Framework

The most cited work on interpretability evaluation is not a technical paper but a conceptual one. Doshi-Velez and Kim recognised that the field needed an evaluation methodology before it could meaningfully compare methods {% include references/cite.html key="doshivelez2017rigorousscienceinterpretablemachine" %}. Their three-tier framework remains the de facto standard for organising XAI evaluation.

**Application-grounded evaluation** measures interpretability through human performance on the real task. If a radiologist makes more accurate diagnoses with an interpretable model than without, the model is interpretable. This has the highest validity but is expensive and domain-specific.

**Human-grounded evaluation** tests whether explanations support human decision-making in simplified settings. A typical experiment asks lay participants to predict the output of a model given its explanation. These experiments are cheaper and more reproducible than application-grounded studies, but they test generic interpretability, not task-specific utility.

**Functionally-grounded evaluation** replaces humans entirely with formal proxy metrics. Sparsity, faithfulness, stability, and complexity are examples. These metrics enable automated comparison at scale, but their validity depends entirely on whether they correlate with human judgement. That dependence requires independent verification through human-grounded experiments.

The central insight of the paper is that these three tiers trade validity for cost. The appropriate tier depends on the evaluation goal. For comparing two similar methods, functionally-grounded evaluation suffices. For regulatory approval, application-grounded evaluation is necessary.

### Barredo Arrieta et al. (2020): The Comprehensive Taxonomy

Barredo Arrieta et al. produced the most comprehensive taxonomy of the XAI field, surveying over 400 references {% include references/cite.html key="barredoarrieta2020xai" %}. The primary partition of the taxonomy, intrinsic vs. post-hoc interpretability, has been widely adopted as the organising principle of the field.

**Intrinsic interpretability** covers models that are transparent by design: linear regression, logistic regression, decision trees, decision rules, rule-based classifiers, generalised additive models, and Bayesian models. These models have limited expressiveness but offer direct insight into their decision logic.

**Post-hoc interpretability** covers methods that explain already-trained models. Barredo Arrieta et al. organise post-hoc methods along multiple dimensions:

- _By scope_: Local explanations (explain individual predictions) vs. global explanations (explain the entire model behaviour).
- _By model dependence_: Model-specific (e.g., tree interpreters, LRP for neural networks) vs. model-agnostic (e.g., LIME, SHAP, partial dependence plots).
- _By output type_: Text explanations, visual explanations, example-based explanations (e.g., counterfactuals, prototypes), and feature attribution explanations.

The taxonomy connects technical explainability to broader responsible AI principles, situating XAI as one of four pillars alongside fairness, accountability, and transparency. This framing has been influential, but it assumes a coherence between these principles that is not always present in practice. An explainable model can be unfair; a fair model can be unintelligible.

### Chazette et al. (2021): The Knowledge Catalogue

Chazette et al. addressed a complementary gap: how do different stakeholders define explainability, and how can these definitions be reconciled? {% include references/cite.html key="chazette2021exploring" %} Their knowledge catalogue maps explainability definitions to stakeholder types, usage contexts, and explanation goals. The key insight is that explainability is not a single requirement but a bundle of potentially conflicting requirements that must be prioritised based on the specific deployment context.

### Watson (2022): Three Conceptual Challenges

Watson's philosophical critique cuts deeper than technical limitations {% include references/cite.html key="watson2022conceptual" %}. He identifies three conceptual problems that no amount of technical refinement can fix.

**Ambiguity of target:** IML methods do not clearly distinguish between explaining the model, the data-generating process, or the domain phenomenon. SHAP values explain the model but are routinely interpreted as explaining reality. This category error is built into the method, not a misuse.

**Disregard for error rates:** No standard IML method reports confidence intervals or performs severe testing. The local linear fit of LIME has no uncertainty quantification. SHAP values lack standard errors. This makes it impossible to distinguish signal from noise in explanations.

**Product over process:** IML emphasises the final explanation product (a saliency map, a Shapley value) rather than the process by which the model arrived at its decision. Describing which features were important is different from explaining how the model used them.

These challenges are particularly troubling because they are not fixable by better engineering. They require reconceptualising what interpretability means and what it can deliver.

### Molnar (2020): The Practical Synthesis

Molnar's _Interpretable Machine Learning_ provides the most accessible practical guide to interpretability methods {% include references/cite.html key="molnar2021interpretable" %}. The book covers both intrinsic interpretable models and model-agnostic methods, with critical analysis of the strengths and weaknesses of each method. Its structure mirrors the Barredo Arrieta taxonomy, presenting intrinsic methods first and then post-hoc. The practical emphasis makes it a valuable companion to the theoretical and conceptual works discussed above.

---

## Synthesis: Interpretability Is a Relationship, Not a Property

Across these five papers, a coherent picture emerges. Interpretability is a relationship between at least four elements. These elements are the model, the human, the task, and the stakes. A model is interpretable relative to a specific person trying to accomplish a specific task under specific constraints. The same model may be interpretable for a data scientist debugging a pipeline and opaque for a patient affected by its decisions.

This relational view has consequences. It means that calls for "interpretable AI" are underspecified without answers to interpretability for whom, for what purpose, and at what cost. It means that the distinction between intrinsic and post-hoc interpretability, while useful, does not capture the full space of interpretability requirements. And it means that evaluation must be matched to the deployment context, not chosen from a menu of convenient proxy metrics.

The three papers examined in the next article build on this foundation by examining the specific methods that the field has developed to produce explanations.

---

## Conclusion

The foundational question, what does it mean for AI to be explainable, does not have a single answer. It has a framework. Doshi-Velez and Kim provide the evaluation methodology. Barredo Arrieta et al. provide the taxonomy. Molnar provides the practical compendium. Watson and Chazette et al. provide the critical perspective that prevents the field from mistaking technical sophistication for conceptual clarity.

The next article in this series examines the specific explanation methods and techniques that operationalise these frameworks, from gradient-based attribution to concept-based explanations.

---

## Frequently Asked Questions

### What distinguishes interpretability from explainability in machine learning?

Interpretability refers to the degree to which a human can consistently predict the output of a model, a property of the model itself (Doshi-Velez and Kim, 2017). Explainability refers to the broader field encompassing both inherently interpretable models and post-hoc methods that generate explanations after training (Barredo Arrieta et al., 2020). The distinction matters because interpretability is a design choice while explainability is a broader research programme.

### What are the main dimensions of interpretability taxonomies in the literature?

The literature converges on several recurring dimensions: intrinsic versus post-hoc methods, model-specific versus model-agnostic approaches, and local versus global explanations (Barredo Arrieta et al., 2020). These dimensions are not orthogonal and methods can combine aspects of multiple categories. The field has not yet settled on a single standardised taxonomy but the building blocks are widely agreed.

### How does Doshi-Velez and Kim's three-tier framework structure XAI evaluation?

The framework distinguishes application-grounded evaluation (real task, real users), human-grounded evaluation (simplified task, lay users), and functionally-grounded evaluation (no humans, formal proxy for interpretability). Each tier trades off cost against ecological validity. Application-grounded provides the strongest evidence but is expensive; functionally-grounded is scalable but requires validation that the proxy actually measures interpretability.

### What conceptual challenges does Watson identify for post-hoc explanations?

Watson identifies three categories: ambiguity (the same explanation can support contradictory conclusions), inaccuracy (explanations can be systematically misleading), and product-process confusion (evaluating the explanation rather than the explanatory process). These challenges apply specifically to post-hoc methods and question whether such explanations can satisfy scientific standards of evidence.

### What role do taxonomies play in structuring XAI research and practice?

Taxonomies serve three functions: they create shared vocabulary for cross-study comparison, they identify gaps where no methods exist for important categories, and they help practitioners select appropriate methods for their specific task. Chazette et al. (2021) demonstrate this through a knowledge catalogue that maps user needs to technical explainability requirements.

<details markdown="1" class="appendix-callout group">
<summary>Appendix: Source Material</summary>

### Author and Source Credibility

| Source                        | Author profile                   | Venue                         | Citation count | Tier                   |
| ----------------------------- | -------------------------------- | ----------------------------- | -------------- | ---------------------- |
| Doshi-Velez & Kim (2017)      | Harvard/Google Brain researchers | arXiv (ML community)          | 4000+          | Foundational           |
| Barredo Arrieta et al. (2020) | Multi-institution European team  | Information Fusion            | 8000+          | Authoritative          |
| Molnar (2020)                 | Independent statistician         | Self-published (CC license)   | Widely used    | Practical reference    |
| Watson (2022)                 | UCL philosopher of science       | Synthese (philosophy journal) | Growing        | Conceptual critique    |
| Chazette et al. (2021)        | LUH/Siemens researchers          | IEEE RE Conference            | Moderate       | Definitional synthesis |

### Corpus Reviewed

- Doshi-Velez & Kim (2017): 50+ references across interpretability, HCI, and cognitive science
- Barredo Arrieta et al. (2020): 400+ references across XAI literature to 2019
- Molnar (2021): Book-length treatment of interpretability methods
- Watson (2022): Draws on philosophy of science (Mayo, Woodward, Cartwright)
- Chazette et al. (2021): Requirements engineering literature on explainability

### Citability Snapshot

| Claim category             | Count | Examples                                                                         |
| -------------------------- | ----- | -------------------------------------------------------------------------------- |
| Verified (field consensus) | 4     | Three-tier framework, intrinsic vs. post-hoc taxonomy, interpretability spectrum |
| Inferred from evidence     | 2     | Proxy metric validity requires human validation                                  |
| Speculative                | 2     | Responsible AI framing as consensus, relational model of interpretability        |

### Technical Term Definitions

| Term                 | Definition used in this article                              | Source                        |
| -------------------- | ------------------------------------------------------------ | ----------------------------- |
| Interpretability     | Degree to which human can consistently predict model output  | Doshi-Velez & Kim (2017)      |
| Explainability       | ML producing inherently interpretable models or explanations | Barredo Arrieta et al. (2020) |
| Post-hoc             | Explanations applied after training                          | Barredo Arrieta et al. (2020) |
| Application-grounded | Evaluation on real task with real users                      | Doshi-Velez & Kim (2017)      |

### Evidence Maturity Map

| Finding                                            | Evidence level                      | Sources                                                           |
| -------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------- |
| Three-tier evaluation framework                    | Verified (field consensus)          | Doshi-Velez & Kim (2017); Barredo Arrieta et al. (2020)           |
| Intrinsic vs. post-hoc taxonomy                    | Verified (field consensus)          | Barredo Arrieta et al. (2020); Samek et al. (2021); Molnar (2021) |
| Conceptual challenges (ambiguity, error, product)  | Inferred from analysis              | Watson (2022)                                                     |
| Knowledge catalogue for explainability definitions | Verified (requirements engineering) | Chazette et al. (2021)                                            |
| Interpretability is task-dependent                 | Verified (field consensus)          | All five sources                                                  |

</details>
