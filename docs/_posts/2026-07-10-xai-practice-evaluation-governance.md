---
layout: post
last_modified_at: 2026-07-10
title: "Explainability in Practice: Domains, Evaluation, and Governance"
author: Zenith Law
description: "A synthesis of domain-specific XAI applications, evaluation frameworks, and governance structures that translate theoretical foundations into operational practice."
permalink: /explainability-practice-domains-evaluation-governance
intro: "The previous articles established foundations, methods, and limits. This article examines how XAI is applied in practice across domains, how it is evaluated, and what governance structures are needed. Domain applications from medical imaging to cybersecurity demonstrate that XAI requirements are fundamentally domain-dependent. Evaluation frameworks from Salvi et al. and Dwivedi et al. reveal that no universal metric set exists. Governance structures from Casper et al. and Bhatt et al. establish that transparency, access, and accountability require organisational commitment beyond any technical solution."
image: /assets/images/xai-practice-domains.png
hero:
  image: /assets/images/xai-practice-domains.png
keywords: "XAI domain applications, medical XAI, cybersecurity XAI, XAI evaluation frameworks, Salvi explainability uncertainty, XAI governance, accountable AI, EU AI Act explainability, domain-specific explanations, XAI deployment practice"
catchwords: "XAI practice, domain applications, evaluation frameworks, governance structures, medical imaging XAI, cybersecurity XAI, uncertainty quantification, accountable AI, regulatory compliance, deployment guide"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - salvi2025uncertainty
  - dwivedi2023xai
  - bhatt2020deployment
  - casper2024blackbox
  - hassija2024interpreting
related_posts:
  - title: "Critical Perspectives and Limits of Current Explainability Methods"
    url: /critical-perspectives-limits-xai
  - title: "XAI 2.0 and the Road Ahead: Open Challenges and Future Directions"
    url: /xai20-open-challenges-future-directions
categories:
  - Artificial Intelligence
  - Machine Learning
  - Software Engineering
tags:
  - XAI practice
  - domain applications
  - evaluation frameworks
  - governance
  - medical AI
  - cybersecurity XAI
  - uncertainty quantification
  - regulatory compliance
---

## Introduction

The first three articles in this series established what XAI means, how it works, and where it falls short. This article answers the practitioner's question: what do you actually do? The answer is not a single recommendation but a situated decision framework.

Domain applications demonstrate that XAI requirements vary fundamentally by context. Evaluation frameworks show that metrics must be chosen for the specific use case, not adopted from a menu. Governance structures reveal that organisational commitment matters as much as technical capability. The synthesis draws on domain surveys covering medical imaging, cybersecurity, and IoT; evaluation frameworks linking explainability with uncertainty quantification; and deployment studies that characterise how organisations currently use XAI.

This article is not legal advice.

## Vocabulary for XAI Practice

<dl>
  <dt><dfn>Uncertainty-aware explanation</dfn></dt>
  <dd>An explanation that quantifies the confidence in its own attribution scores, following Salvi et al.'s thesis that explainability and uncertainty are "two sides of the same coin."</dd>

  <dt><dfn>Model documentation</dfn></dt>
  <dd>Structured records of model purpose, development data, performance characteristics, and known limitations. Model Cards and Datasheets are prominent examples. Documentation is a governance mechanism that does not require explanation methods.</dd>

  <dt><dfn>Feature governance</dfn></dt>
  <dd>The organisational practice of documenting, monitoring, and controlling which features are used in ML models, including periodic review of feature relevance, data quality, and drift.</dd>

  <dt><dfn>Accountability</dfn></dt>
  <dd>The organisational infrastructure that ensures someone is responsible for model decisions, independent of whether the model is explainable. Accountability structures include escalation paths, audit trails, and designated human-in-the-loop roles.</dd>
</dl>

---

## Domain-Specific XAI Requirements

### Medical Imaging and Clinical Decision Support

Medical XAI surveys (Hossain et al. 2025; Tjoa & Guan 2021; Nazir et al. 2023) reveal that healthcare presents uniquely demanding XAI requirements. Explanations must be faithful enough to support clinical decisions, interpretable enough for clinicians with limited ML training, and robust enough to withstand regulatory scrutiny under frameworks like the EU Medical Device Regulation.

The dominant approach in medical imaging combines Grad-CAM or LRP visualisations with clinician evaluation. This approach has documented vulnerabilities: Clever Hans artifacts (hospital markers, imaging equipment watermarks) produce compelling but misleading explanations. Clinicians who trust these visualisations may develop overconfidence in models that rely on spurious correlations.

Ghassemi et al.'s critique (discussed in Article 3) poses a challenge that the medical XAI community has not fully answered: if explanations can be systematically misleading and clinicians cannot evaluate their reliability, do explanations in their current form improve or degrade clinical decision-making?

### Cybersecurity

Cybersecurity presents a different set of challenges. Pawlicki et al.'s evaluation of XAI metrics in a cybersecurity context found that explanation speed matters more than in other domains. Threat detection requires real-time or near-real-time explanations. The evaluation metrics that work for offline medical imaging analysis are inappropriate for streaming security data.

Feature attribution methods (SHAP, LIME) dominate security XAI, but the evaluation literature reveals that metric proliferation is particularly acute in this domain. Multiple metrics claiming to measure "faithfulness" produce systematically different rankings of the same methods applied to the same security data.

### Internet of Things

IoT XAI (Kök et al. 2023) operates under severe resource constraints. Deep neural network explanations that require gradient computation may be infeasible on edge devices. This has led to interest in intrinsically interpretable models (decision trees, rule lists) that provide explanations as a byproduct of their architecture rather than requiring post-hoc computation.

### Geospatial and Environmental XAI

Roussel et al. (2025) propose a quality-aware XAI framework for geospatial analysis that connects explanation quality to downstream decision quality. The framework evaluates whether improving explanation quality actually improves decision outcomes, a direct answer to Ghassemi et al.'s challenge.

## Evaluation Frameworks

### Salvi et al. (2025): Explainability and Uncertainty as Two Sides of the Same Coin

Salvi et al. propose a framework unifying explainability with uncertainty quantification {% include references/cite.html key="salvi2025uncertainty" %}. The thesis is that explanations without uncertainty bounds are fundamentally incomplete. A SHAP value of 0.3 for feature x means something different when the confidence interval is ±0.02 than when it is ±0.25.

The framework maps explanation types to corresponding uncertainty types. Feature attributions require attribution uncertainty. Counterfactual explanations require counterfactual uncertainty. Concept-based explanations require concept uncertainty. This mapping provides a principled basis for selecting evaluation metrics.

### Dwivedi et al. (2023): Core Ideas, Techniques, and Solutions

Dwivedi et al. provide a broad survey emphasising practical solutions {% include references/cite.html key="dwivedi2023xai" %}. The paper organises methods by their deployment readiness and provides selection guidelines matching methods to use cases. The practical emphasis makes it a valuable complement to the conceptual and critical analyses discussed in previous articles.

### Hassija et al. (2024): Model-Agnostic Methods for Black-Box Models

Hassija et al. focus specifically on interpreting black-box models {% include references/cite.html key="hassija2024interpreting" %}. Their survey covers model-agnostic methods including LIME, SHAP, partial dependence plots, accumulated local effects, and permutation feature importance. The emphasis on black-box methods reflects the practical reality that practitioners often cannot access model internals.

## Governance Structures

### Organisational Accountability

Bhatt et al.'s deployment study (Article 3) established that most XAI serves internal stakeholders. The constructive response is not to abandon XAI but to build organisational structures that redirect explanations toward the stakeholders who need them.

The paper's stakeholder-centred framework is a governance mechanism: establish clear goals for what the explanation should achieve for a specific stakeholder; design for that stakeholder's cognitive and domain context; evaluate whether the goals are met. This framework translates technical explainability into organisational accountability.

### Access Governance

Casper et al.'s three-level access framework (black-box, white-box, outside-the-box) provides a governance structure for model auditing. Organisations deploying high-risk AI systems should establish policies determining what level of access external auditors require, with the default presumption that black-box access alone is insufficient for rigorous evaluation.

### Regulatory Context

The EU AI Act establishes requirements for explainability and transparency that vary by risk category. High-risk AI systems must provide meaningful information about the logic involved in decision-making. The Act does not specify which explanation methods to use, creating both flexibility and uncertainty. Practitioners should design explanation pipelines that can adapt to evolving regulatory requirements.

---

## Synthesis: Practice Requires Integration

The practitioner's challenge is integrating these dimensions: selecting methods appropriate for the domain, choosing evaluation metrics that measure what matters for the specific use case, and building governance structures that ensure explanations reach the stakeholders who need them.

No single method, metric, or governance structure suffices. Domain determines method requirements. Use case determines metric selection. Organisational context determines governance design. The integration is the practice.

---

## Conclusion

Explainability in practice is a situated, multi-dimensional challenge. Domain applications demonstrate that general-purpose XAI guidance is insufficient. Evaluation frameworks show that metrics must be chosen for the specific context. Governance structures reveal that organisational commitment is as important as technical capability.

The final article in this series examines where XAI is heading: the open challenges identified by Longo et al.'s XAI 2.0 manifesto and the emerging directions that will shape the field.

---

## Frequently Asked Questions

### What domain-specific requirements exist for XAI in medical imaging and clinical settings?

Medical imaging requires explanation methods that are robust to Clever Hans artifacts, produce spatially coherent attribution maps, and provide uncertainty quantification alongside explanations. Clinical deployment additionally demands explanations that align with medical reasoning workflows, regulatory compliance under frameworks such as the EU AI Act, and validation against established diagnostic standards rather than purely technical metrics.

### How does the EU AI Act affect XAI deployment and governance requirements?

The EU AI Act classifies AI systems by risk level and imposes transparency obligations that include documentation of training data, model architecture, and intended use. For high-risk systems, it requires human oversight mechanisms and technical documentation of explainability properties. The Act creates legal accountability for explanation quality without prescribing specific technical standards, creating both pressure and flexibility.

### What evaluation frameworks exist for assessing explanation quality in practice?

Three main frameworks have emerged: functionally-grounded evaluation using formal proxies such as faithfulness and completeness (Samek et al., 2021), human-grounded evaluation through user studies that measure how explanations affect human decision-making, and application-grounded evaluation in real deployment contexts. Dwivedi et al. (2023) provide a practical synthesis linking method selection to evaluation criteria.

### How does Salvi et al. connect explainability and uncertainty in their framework?

Salvi et al. (2025) argue that explanations without uncertainty quantification are fundamentally incomplete because users cannot distinguish between confident model predictions and those near decision boundaries. Their framework integrates uncertainty estimates into explanation outputs by modifying attribution methods to propagate epistemic and aleatoric uncertainty through the explanation computation.

### What governance structures are needed for responsible XAI deployment?

Effective governance requires organisational accountability mechanisms including designated explainability officers, access governance that matches explanation detail to stakeholder roles, documented decision frameworks for method selection, and regular audit cycles that verify explanations remain faithful after model updates. These structures bridge the gap between technical capability and responsible practice.

<details markdown="1" class="appendix-callout group">
<summary>Appendix: Source Material</summary>

### Author and Source Credibility

| Source                | Profile                   | Venue                 | Focus                       |
| --------------------- | ------------------------- | --------------------- | --------------------------- |
| Salvi et al. (2025)   | Multi-institution Italian | Information Fusion    | Uncertainty-XAI integration |
| Dwivedi et al. (2023) | Multi-institution         | ACM Computing Surveys | Practical XAI solutions     |
| Hassija et al. (2024) | Multi-institution Indian  | Cognitive Computation | Black-box interpretation    |
| Bhatt et al. (2020)   | CMU/Cambridge/PAI         | FAT\* (FAccT)         | Deployment practice         |
| Casper et al. (2024)  | MIT/Harvard               | FAccT 2024            | Audit governance            |

### Domain Coverage

| Domain          | Primary methods documented   | Key challenge                            | Source examples                     |
| --------------- | ---------------------------- | ---------------------------------------- | ----------------------------------- |
| Medical imaging | Grad-CAM, LRP, saliency maps | Clever Hans artifacts, clinician trust   | Hossain 2025, Tjoa 2021, Nazir 2023 |
| Cybersecurity   | SHAP, LIME, Anchors          | Real-time requirements, metric confusion | Pawlicki 2024                       |
| IoT             | Decision trees, rule lists   | Resource constraints                     | Kök 2023                            |
| Geospatial      | Quality-aware frameworks     | Decision-outcome evaluation              | Roussel 2025                        |

### Citability Snapshot

| Claim category       | Count | Examples                                                                                               |
| -------------------- | ----- | ------------------------------------------------------------------------------------------------------ |
| Verified (survey)    | 4     | Domain-specific requirements; metric proliferation; black-box methods scope; uncertainty-XAI link      |
| Verified (empirical) | 2     | Deployment gap persists; access level determines audit quality                                         |
| Inferred             | 3     | Governance structures needed; integration is the challenge; regulatory flexibility creates uncertainty |

</details>
