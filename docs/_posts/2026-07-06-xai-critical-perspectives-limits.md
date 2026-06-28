---
layout: post
last_modified_at: 2026-07-06
title: "Critical Perspectives and Limits of Current Explainability Methods"
author: Zenith Law
description: "A rigorous examination of what current explainability methods cannot deliver: false hope in healthcare, conceptual confusion, deployment gaps, audit limitations, and metric proliferation problems."
permalink: /critical-perspectives-limits-xai
intro: "Five papers converge on an uncomfortable finding: current explainability methods are less reliable than their advocates claim. Ghassemi et al. argue that explainable AI cannot deliver trust, transparency, or bias mitigation for clinical decisions. Watson identifies three conceptual problems that no amount of technical refinement can fix. Bhatt et al. show that deployment primarily serves engineers, not affected stakeholders. Casper et al. demonstrate that black-box access limits what auditors can discover. Pawlicki et al. document metric duplication and confusion. Together, these critiques establish that the limitations of the field are not only technical but conceptual, organisational, and structural."
image: /assets/images/critical-perspectives-xai.png
hero:
  image: /assets/images/critical-perspectives-xai.png
keywords: "XAI limitations, explainable AI critique, Ghassemi false hope XAI, Watson conceptual challenges IML, Bhatt deployment gap, Casper black-box audit limits, Pawlicki metric proliferation, XAI healthcare critique, explainability failure modes, XAI trust calibration, Clever Hans artifacts"
catchwords: "XAI critique, false hope, deployment gap, conceptual challenges, black-box limits, metric confusion, healthcare XAI limitations, audit insufficiency, explanation reliability"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - ghassemi2021falsehope
  - watson2022conceptual
  - bhatt2020deployment
  - casper2024blackbox
  - pawlicki2024metrics
related_posts:
  - title: "What Does It Mean for AI to Be Explainable? Foundations of Interpretable ML"
    url: /foundations-interpretable-machine-learning
  - title: "Methods and Techniques for Explaining Machine Learning Models"
    url: /methods-techniques-explaining-ml-models
  - title: "Explainability in Practice: Domains, Evaluation, and Governance"
    url: /explainability-practice-domains-evaluation-governance
  - title: "XAI 2.0 and the Road Ahead: Open Challenges and Future Directions"
    url: /xai20-open-challenges-future-directions
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - XAI critique
  - explainability limits
  - healthcare AI
  - AI auditing
  - XAI deployment
  - evaluation metrics
  - black-box auditing
---

## Introduction

The first two articles in this series established what interpretability means and how current methods work. This article examines what those methods cannot deliver. Five papers, each from a different angle, document limitations that are not merely technical but conceptual, organisational, and structural.

Ghassemi et al. argue that current explainability methods cannot achieve their stated goals of trust, transparency, and bias mitigation. Watson identifies three conceptual problems embedded in the very design of IML methods. Bhatt et al. show that even when explanations are deployed, they serve engineers rather than affected stakeholders. Casper et al. prove that black-box access, the most common audit mode, is structurally insufficient. Pawlicki et al. document a metrics crisis that makes it impossible to compare methods systematically.

The picture is not that XAI is useless. It is that XAI is much less reliable than its advocates claim, and that the field must confront its limitations honestly to make genuine progress.

This article is not legal advice.

## Vocabulary for Limits and Critiques

<dl>
  <dt><dfn>Severe testing</dfn></dt>
  <dd>A framework from the philosophy of science (Mayo, 1996) requiring that a hypothesis must be subjected to tests that it is likely to fail if false. Watson argues that IML methods do not subject their explanations to severe testing.</dd>

  <dt><dfn>Product vs. process explanation</dfn></dt>
  <dd>A product explanation states which features were important for a prediction. A process explanation describes how the model used those features to arrive at its decision. Current IML methods almost exclusively provide product explanations.</dd>

  <dt><dfn>Deployment gap</dfn></dt>
  <dd>The mismatch between the research narrative that explanations serve affected stakeholders and the practice where explanations primarily serve internal ML engineers for debugging.</dd>

  <dt><dfn>Outside-the-box access</dfn></dt>
  <dd>Access to information about the development process of a model: training methodology, data provenance, documentation, deployment details, and internal evaluation results. Casper et al. argue this access level is necessary for rigorous auditing alongside white-box access.</dd>

  <dt><dfn>Metric duplication</dfn></dt>
  <dd>The phenomenon where multiple XAI evaluation metrics measure the same construct under different names, creating the illusion of comprehensive evaluation while actually measuring the same thing repeatedly.</dd>
</dl>

---

## Five Dimensions of Limitation

### Ghassemi et al. (2021): The Clinical Critique

Ghassemi, Oakden-Rayner, and Beam published a pointed critique from within the medical AI community {% include references/cite.html key="ghassemi2021falsehope" %}. Their core argument is that current explainability methods cannot deliver on the promises made on their behalf: engendering trust, providing transparency, and mitigating bias. The argument rests on three documented failure modes.

**Ambiguity.** Different explanation methods applied to the same prediction regularly produce conflicting explanations. Without ground truth, there is no principled way to adjudicate between them. A clinician presented with one explanation from LIME and a different explanation from SHAP has no basis for choosing which to trust.

**Inaccuracy.** Explanations can be systematically misleading. Gradient saturation produces attribution maps that highlight irrelevant features. Clever Hans phenomena (documented in Article 2) show that models can be correct for the wrong reasons, and explanations faithfully reflecting model behaviour will therefore be wrong about reality.

**Inscrutability.** Even if explanations were accurate, clinicians lack training to critically evaluate them. The cognitive load of assessing the validity of an explanation while making a clinical decision creates a situation where explanations may decrease rather than improve decision quality.

The paper does not argue that explainability is impossible. It argues that the current enthusiasm for explainability as a solution to the trust problems of clinical AI is premature, and that rigorous internal and external validation of AI models is a more reliable path to safe deployment.

### Watson (2022): The Conceptual Critique

Watson's critique targets the conceptual foundations rather than empirical performance {% include references/cite.html key="watson2022conceptual" %}. The three challenges are worth restating because they are immune to technical fixes.

**Ambiguity of target.** When SHAP reports that feature x contributed 0.3 to a prediction, what exactly is being explained? The behaviour of the model (the function SHAP is approximating)? The data-generating process (the correlations in the training distribution)? The domain phenomenon (the real-world relationship the model is meant to capture)? Each is a legitimate target, but SHAP only addresses the first, while being interpreted as addressing the third.

**Absent error quantification.** LIME fits a local linear model without reporting confidence intervals. SHAP values are point estimates without standard errors. Neither method subjects its explanations to severe testing: constructing tests that the explanation is likely to fail if it is incorrect. In any scientific context, making claims without error quantification is unacceptable.

**Product over process.** A list of feature attributions describes what the model used but not how it used it. Was the decision process of the model linear (features combine additively) or interactive (features modulate each other's contributions)? Current methods do not distinguish these fundamentally different modes.

Watson's prescription is not to abandon IML but to adopt the methodological standards of the sciences it seeks to support: clear explanatory targets, error quantification, and process-level understanding.

### Bhatt et al. (2020): The Deployment Gap

Bhatt et al. conducted the first empirical study of how organisations actually use explainability in production {% include references/cite.html key="bhatt2020deployment" %}. The results reveal a fundamental mismatch between research narratives and practice.

The study of 11 organisations found that the majority of explainability deployments serve ML engineers debugging models, not end users affected by model decisions. Explanations were used for: model debugging and feature engineering (most common), regulatory compliance documentation, and building internal stakeholder trust. End-user-facing explanations were rare.

The gap matters because the research community motivates explainability as a tool for transparency and accountability to affected stakeholders. If explanations never reach those stakeholders, the normative goals of XAI remain unfulfilled regardless of technical quality.

The paper proposes a stakeholder-centred framework: establish clear goals for what the explanation should achieve for a specific stakeholder, design for that stakeholder's cognitive and domain context, and evaluate whether the goals are met. This framework, while sensible, is rarely applied in practice.

### Casper et al. (2024): Black-Box Audit Limitations

Casper et al. examine a structural constraint on AI auditing {% include references/cite.html key="casper2024blackbox" %}. External auditors typically receive only black-box access (query inputs, observe outputs). The paper demonstrates that this access level is insufficient for rigorous evaluation across multiple dimensions.

Black-box access cannot reliably detect model editing or fine-tuning. Adversarial robustness evaluations are weaker without gradient access. Mechanistic interpretability, understanding how circuits within the model implement behaviours, requires white-box access to weights and activations. Data contamination detection is limited when the training data cannot be inspected.

The three-level framework of the paper (black-box, white-box, outside-the-box) maps specific audit tasks to required access levels. The central recommendation: auditors must disclose their access level for audit results to be interpretable, and regulators should mandate minimum access for high-risk systems.

This critique has direct implications for explainability. Many explanation methods require white-box access (gradients, activations). When auditors only have black-box access, the set of available explanation methods is restricted, and the conclusions that can be drawn from explanations are correspondingly limited.

### Pawlicki et al. (2024): The Metrics Crisis

Pawlicki et al. document a problem that makes XAI evaluation unreliable even when the methods work correctly {% include references/cite.html key="pawlicki2024metrics" %}. The proliferation of evaluation metrics has created three pathologies:

**Metric duplication.** Over 50 distinct XAI evaluation metrics exist, many measuring the same construct under different names. Faithfulness metrics, for example, come in dozens of variants with different mathematical formulations but identical conceptual targets.

**Metric inefficacy.** Some metrics fail to distinguish between high- and low-quality explanations. When all methods receive similar scores, the metric provides no information for method selection.

**Metric confusion.** Different metrics applied to the same explanation method produce diverging assessments. One metric may rank SHAP highest while another ranks LIME highest, leaving the practitioner with no basis for choice.

The paper recommends domain-specific metric selection. The set of metrics appropriate for validating explanations in medical imaging (where pixel-level faithfulness matters) differs from the set for tabular credit scoring (where feature-level stability matters). No universal metric set exists.

---

## Synthesis: The Limits Are Not Only Technical

Across these five papers, a pattern emerges that is more troubling than any single critique. The limitations of current XAI are not only technical (better methods will fix them) but structural (the deployment context constrains what can be achieved) and conceptual (the methods are not designed for the questions they are asked to answer).

Ghassemi et al. and Watson together establish that the conceptual foundations are incomplete. Bhatt et al. establish that even good methods do not reach the stakeholders who need them. Casper et al. show that access constraints limit what methods can be applied. Pawlicki et al. demonstrate that the evaluation infrastructure cannot distinguish good methods from poor ones.

The constructive response is not to abandon XAI but to pursue it with greater honesty about its limitations; to match method choice to the specific question and stakeholder; and to invest in the evaluation infrastructure that the field currently lacks.

---

## Conclusion

The critical perspectives examined in this article do not refute the value of XAI. They demand that the field hold itself to higher standards: clear explanatory targets, error quantification, stakeholder-centred deployment, adequate model access, and reliable evaluation metrics. The next article examines how the field is responding to these demands through domain applications, evaluation frameworks, and governance structures.

---

## Frequently Asked Questions

### What are the main limitations of current XAI methods identified in the literature?

The literature identifies five interconnected limitations: explanation ambiguity across methods, systematic inaccuracy through gradient manipulation, a gap between research and deployment practice, structural limits on black-box auditability, and a metrics crisis where evaluation tools fail to distinguish meaningful differences between methods. These limitations are not merely technical but also conceptual and organisational.

### Why do Ghassemi et al. argue that explainability requirements may harm clinical AI?

Ghassemi et al. argue that mandating explainability for clinical AI could divert resources from rigorous validation through prospective trials and deployment monitoring. They contend that a thoroughly validated model whose outputs clinicians understand through training may be safer than an explainable model whose behaviour has been less rigorously tested. This argument challenges the assumption that explainability is always a net benefit.

### What is the deployment gap that Bhatt et al. identify in XAI practice?

Bhatt et al. surveyed ML practitioners and found that XAI methods are rarely deployed in production because they lack clear integration paths, standardised evaluation criteria, and actionable outputs. Practitioners reported using explanation methods for debugging during development but not for external accountability purposes. This gap between research capability and deployment reality limits the practical impact of XAI.

### How does Casper et al. characterise the limits of black-box audits?

Casper et al. demonstrate that black-box access alone is insufficient for reliable auditing because adversarial inputs can be designed to produce misleading explanations, model editing can change behaviour without detection from explanation outputs, and the inherent ambiguity of post-hoc explanations means that multiple contradictory narratives can be supported by the same audit data.

### What does Pawlicki et al. identify as the metrics crisis in XAI evaluation?

Pawlicki et al. identify three problems: metric duplication where multiple metrics measure the same underlying property and create false diversity, metric inefficacy where some metrics fail to distinguish between random and meaningful explanations, and metric confusion where contradictory results across metrics make it impossible to determine which method is better for a given task.

<details markdown="1" class="appendix-callout group">
<summary>Appendix: Source Material</summary>

### Author and Source Credibility

| Source                 | Author profile                 | Venue                         | Impact            |
| ---------------------- | ------------------------------ | ----------------------------- | ----------------- |
| Ghassemi et al. (2021) | MIT/Harvard Medical            | The Lancet Digital Health     | 500+ citations    |
| Watson (2022)          | University College London      | Synthese (philosophy journal) | Growing citations |
| Bhatt et al. (2020)    | CMU/Cambridge/PAI              | FAT\* (now FAccT)             | 600+ citations    |
| Casper et al. (2024)   | MIT/Harvard/ multi-institution | FAccT 2024                    | Rapidly growing   |
| Pawlicki et al. (2024) | Multi-institution European     | Neurocomputing                | New (2024)        |

### Citability Snapshot

| Claim category                 | Count | Examples                                                                                        |
| ------------------------------ | ----- | ----------------------------------------------------------------------------------------------- |
| Verified (empirical)           | 4     | Explanation ambiguity, deployment gap, black-box audit limits, metric duplication               |
| Verified (conceptual analysis) | 3     | Ambiguity of target, absent error quantification, product vs. process                           |
| Inferred                       | 3     | Trust through validation vs. explanation; end-user inscrutability; structural limits persistent |
| Speculative                    | 1     | Rigorous validation sufficient without explanations (debated)                                   |

</details>
