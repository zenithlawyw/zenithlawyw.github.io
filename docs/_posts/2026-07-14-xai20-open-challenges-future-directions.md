---
layout: post
last_modified_at: 2026-07-14
title: "XAI 2.0 and the Road Ahead: Open Challenges and Future Directions"
author: Zenith Law
description: "A synthesis of the open challenges facing explainable AI, from the XAI 2.0 manifesto to emerging directions in interdisciplinary research, human-centred evaluation, and regulatory alignment."
permalink: /xai20-open-challenges-future-directions
intro: "The XAI 2.0 manifesto identifies 22 open challenges spanning technical, human-centred, regulatory, and methodological dimensions. This final article in the series synthesises those challenges, connects them to the findings of the previous four articles, and identifies the research directions that will define the next generation of explainability. The central message is that XAI must transition from a method-centric discipline focused on producing explanations to a human-centred discipline focused on supporting understanding."
image: /assets/images/xai20-open-challenges.png
hero:
  image: /assets/images/xai20-open-challenges.png
keywords: "XAI 2.0, open challenges XAI, Longo XAI manifesto, interdisciplinary XAI, human-centred explainability, XAI evaluation standards, EU AI Act explainability, XAI regulatory alignment, future XAI directions, explainability research agenda, cognitive science XAI"
catchwords: "XAI 2.0, open challenges, interdisciplinary research, human-centred XAI, regulatory alignment, evaluation standards, future research, long-term agenda, paradigm shift, understanding vs explanation"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - LONGO2024102301
  - watson2022conceptual
  - ghassemi2021falsehope
  - bhatt2020deployment
  - pawlicki2024metrics
related_posts:
  - title: "What Does It Mean for AI to Be Explainable? Foundations of Interpretable ML"
    url: /foundations-interpretable-machine-learning
  - title: "Critical Perspectives and Limits of Current Explainability Methods"
    url: /critical-perspectives-limits-xai
  - title: "Explainability in Practice: Domains, Evaluation, and Governance"
    url: /explainability-practice-domains-evaluation-governance
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - XAI 2.0
  - open challenges
  - future directions
  - interdisciplinary
  - human-centred AI
  - regulatory alignment
  - evaluation standards
  - cognitive science
---

## Introduction

The XAI 2.0 manifesto, authored by 27 leading XAI researchers and published in Information Fusion in 2024, identifies 22 open challenges across five themes {% include references/cite.html key="LONGO2024102301" %}. This final article in the series synthesises those challenges, connects them to the findings of the previous four articles, and maps the research directions that will define the next generation of explainability.

The central thesis of the XAI 2.0 manifesto is that the field must transition from a method-centric discipline focused on producing explanations to a human-centred discipline focused on supporting understanding. This framing recasts every technical challenge as a human-centred challenge, and every methodological question as an interdisciplinary question.

This article is not legal advice.

## Vocabulary for XAI 2.0

<dl>
  <dt><dfn>Method-centric XAI</dfn></dt>
  <dd>The dominant paradigm in XAI 1.0: develop an explanation method, demonstrate it on benchmark datasets, evaluate with proxy metrics. The focus is on the method, not the user.</dd>

  <dt><dfn>Human-centred XAI</dfn></dt>
  <dd>The paradigm proposed for XAI 2.0: start with what humans need to understand, design explanations to meet those needs, evaluate by measuring whether understanding improves.</dd>

  <dt><dfn>Explanation personalisation</dfn></dt>
  <dd>The design of explanations tailored to individual users' cognitive characteristics, domain expertise, and task context. A single explanation format cannot serve all stakeholders.</dd>

  <dt><dfn>Cognitive load</dfn></dt>
  <dd>The mental effort required to process and evaluate an explanation. Explanations that impose high cognitive load may be counterproductive, particularly in high-stakes, time-constrained decisions.</dd>
</dl>

---

## The 22 Open Challenges

### Technical Challenges

**1. Formal definitions.** The field still lacks a universally accepted formal definition of explainability. The definition of Barredo Arrieta et al. is the closest to consensus, but it is descriptive rather than formal. Without formal definitions, mathematical guarantees about explanation quality are impossible.

**2. Evaluation metrics.** The metrics crisis documented by Pawlicki et al. ([Critical Perspectives and Limits of Current Explainability Methods](/critical-perspectives-limits-xai)) remains unresolved. Over 50 metrics exist, many are redundant, and no standardised evaluation framework has emerged. The XAI 2.0 manifesto calls for community-wide agreement on core evaluation constructs.

**3. Robustness of explanations.** Explanations should be stable under small input perturbations that do not change the prediction. Current methods vary in their robustness, and there is no standard for acceptable stability.

**4. Completeness vs. selectivity trade-off.** Comprehensive explanations (showing all contributing features) may be too complex for human understanding. Selective explanations (showing only the most important features) risk omitting essential information. There is no principled framework for navigating this trade-off.

**5. Ground truth for explanations.** Unlike classification, there is no ground truth for explanations. Even for simple models, what counts as the "correct" explanation depends on the explanatory target (model, data, or phenomenon. Watson's first challenge).

**6. Reproducibility and generalisation.** Explanation methods often produce different results across random seeds, data splits, or software implementations. Reproducibility standards for XAI research are underdeveloped.

### Human-Centred Challenges

**7. Cognitive load.** Explanations impose cognitive demands on users that may exceed their processing capacity, particularly in high-stakes environments like clinical decision-making (the inscrutability challenge of Ghassemi et al.{% include references/cite.html key="ghassemi2021falsehope" %}).

**8. Trust calibration.** Explanations can produce both under-trust (users ignore reliable models) and over-trust (users accept unreliable explanations). The goal is calibrated trust: matching user confidence to actual model reliability.

**9. Explanation personalisation.** Different stakeholders (regulators, clinicians, patients, engineers) need different explanations. Current methods produce one-size-fits-all outputs.

**10. Mental models.** Explanations should help users build accurate mental models of system behaviour. Current methods provide attribution scores that support shallow understanding.

**11. Longitudinal effects.** Most XAI research studies one-shot explanation consumption. Real-world use involves repeated, cumulative engagement with explanations over time.

### Interdisciplinary Challenges

**12. Bridging XAI and HCI.** Explanation method design is currently driven by ML researchers, not HCI experts. The result is methods optimised for technical properties (axioms, completeness) rather than usability.

**13. Cognitive science integration.** Understanding how humans process explanations requires integrating cognitive science findings on causal reasoning, counterfactual thinking, and explanation evaluation.

**14. Philosophy of explanation.** Watson's conceptual critique draws on philosophy of science. The field must engage more deeply with philosophical work on what constitutes a good explanation.

**15. Social science perspectives.** Organisational adoption of XAI (the deployment gap of Bhatt et al.{% include references/cite.html key="bhatt2020deployment" %}) is a social science question as much as a technical one.

**16. Legal and regulatory alignment.** The EU AI Act and emerging regulations create requirements that current XAI methods may not satisfy. Legal scholars must collaborate with XAI researchers to operationalise regulatory concepts.

### Regulatory Challenges

**17. Operationalising the right to explanation.** GDPR Article 22 and the EU AI Act establish rights to meaningful information about automated decisions. What counts as "meaningful" is undefined, creating legal uncertainty.

**18. Auditing frameworks.** The access-level framework of Casper et al. provides a starting point, but auditing standards for explanation quality do not exist.

**19. Standardisation.** Unlike software testing or security evaluation, there are no ISO standards for XAI evaluation.

### Methodological Challenges

**20. Longitudinal studies.** Most XAI research evaluates explanations in single-session lab studies. Longitudinal studies tracking how understanding develops over time are almost absent.

**21. Field studies.** The deployment study of Bhatt et al. remains the only empirical characterisation of XAI in practice. More field studies are needed.

**22. Human-grounded evaluation validation.** Functionally-grounded metrics require validation against human judgement. This validation is almost never performed, meaning the field uses proxy metrics whose relationship to actual interpretability is unknown.

## Connecting the Challenges to the Series Findings

The 22 challenges are not independent. They form a coherent structure that connects directly to the findings of the previous four articles.

| Article                  | Key finding                                        | Connected XAI 2.0 challenges                                                            |
| ------------------------ | -------------------------------------------------- | --------------------------------------------------------------------------------------- |
| 1. Foundations           | Interpretability is a relationship, not a property | Challenges 1 (formal definitions), 7 (cognitive load), 11 (longitudinal effects)        |
| 2. Methods               | Method choice shapes what can be known             | Challenges 4 (completeness vs. selectivity), 5 (ground truth), 8 (trust calibration)    |
| 3. Critical perspectives | Limits are conceptual, not only technical          | Challenges 14 (philosophy), 13 (cognitive science), 9 (personalisation)                 |
| 4. Practice              | Integration is the challenge                       | Challenges 15 (social science), 18 (auditing), 19 (standardisation), 21 (field studies) |

## Research Directions

### From Method-Centric to Human-Centred

The paradigm shift that Longo et al. advocate requires reorienting XAI research. Instead of asking "what explanation method should we develop?" the field should ask "what do humans need to understand, and how can we support that understanding?" This shifts the evaluation criterion from technical properties (axioms satisfied) to human outcomes (understanding improved).

### Interdisciplinary Infrastructure

Several challenges require infrastructure that no single discipline can build. The integration of cognitive science findings into XAI design requires sustained collaboration between ML researchers and cognitive scientists. The development of auditing standards requires collaboration between technical researchers, legal scholars, and regulators. The longitudinal and field studies required for challenges 20-21 need organisational access that is currently rare.

### Evaluation as a First-Class Problem

The metrics crisis (challenge 2) connects multiple other challenges. Without reliable evaluation, progress on robustness (3), reproducibility (6), and trust calibration (8) cannot be measured. The call of the XAI 2.0 manifesto for evaluation standardisation is the single most actionable recommendation for the field.

### Regulatory Engagement

The EU AI Act and emerging regulations in other jurisdictions create both requirements and opportunities. Regulatory engagement can motivate evaluation standards (requiring validated explanations), mandate adequate access levels (the outside-the-box access of Casper et al.), and create demand for field studies (as organisations document their XAI compliance). The risk of regulatory engagement is that it may codify premature standards, locking in methods that the field has not yet properly evaluated.

---

## Conclusion: The Road Ahead

The XAI 2.0 manifesto identifies where the field needs to go. The previous four articles in this series establish where it currently stands. The gap between them defines the research agenda.

The central challenge is the transition from method-centric to human-centred XAI. This transition requires not only new methods but new evaluation frameworks, new interdisciplinary collaborations, new organisational structures, and new regulatory engagement. It is a generational research programme, not a quick fix.

The five articles in this series have examined what explainability means ([What Does It Mean for AI to Be Explainable? Foundations of Interpretable ML](/foundations-interpretable-machine-learning)), how current methods work ([Methods and Techniques for Explaining Machine Learning Models](/methods-techniques-explaining-ml-models)), where they fall short ([Critical Perspectives and Limits of Current Explainability Methods](/critical-perspectives-limits-xai)), how they are applied in practice ([Explainability in Practice: Domains, Evaluation, and Governance](/explainability-practice-domains-evaluation-governance)), and where the field needs to go (this article). The unifying message is that explainability is neither solved nor hopeless. It is a young field whose most important questions remain open, and whose progress depends on the willingness of the field to confront its limitations honestly.

---

## Frequently Asked Questions

### What are the main categories of open challenges in the XAI 2.0 manifesto?

Longo et al. (2024){% include references/cite.html key="LONGO2024102301" %} organise 22 challenges into five categories: technical challenges including formal definitions and evaluation metrics, human-centred challenges including cognitive load and trust calibration, interdisciplinary challenges spanning HCI and philosophy, regulatory challenges concerning auditing frameworks and standardisation, and methodological challenges involving longitudinal and field studies. Technical challenges are most mature while interdisciplinary challenges require structural changes.

### What distinguishes human-centred challenges from technical challenges in XAI?

Technical challenges focus on formal properties of explanations such as completeness, robustness, and reproducibility of attribution methods. Human-centred challenges address how explanations interact with human cognition including how much detail users can process, how explanations affect trust, and whether explanations personalise to different user expertise levels. Solving technical challenges does not automatically resolve human-centred ones.

### Why does the XAI 2.0 manifesto call for interdisciplinary infrastructure?

The manifesto argues that no single discipline can address all 22 challenges because explanation is simultaneously a mathematical, psychological, and sociological phenomenon. Interdisciplinary infrastructure means shared experimental platforms, standardised evaluation protocols that work across disciplines, funding mechanisms that reward collaboration, and publication venues that accept hybrid contributions spanning computer science, cognitive science, and law.

### How can evaluation become a first-class problem in XAI research?

The manifesto argues that evaluation should shift from a post-hoc activity to a design-stage requirement. This means developing community-standard benchmarks, establishing ground-truth datasets for explanation correctness, creating reproducible evaluation protocols that span research groups, and making evaluation quality a publication criterion equivalent to methodological novelty. Currently, evaluation quality varies widely and is rarely treated as a primary contribution.

### What regulatory challenges does the XAI 2.0 manifesto identify?

Three regulatory challenges are identified: operationalising the right to explanation under GDPR and the EU AI Act into technically specific requirements, developing auditing frameworks that can verify explanation quality at scale, and creating standardisation mechanisms that allow different regulatory regimes to accept common evidence of explainability. These challenges are urgent because regulatory timelines are shortening while technical standards remain fluid.

<details markdown="1" class="appendix-callout group">
<summary>Appendix: Source Material</summary>

### Author and Source Credibility

| Source                 | Profile                    | Venue                     | Focus                 |
| ---------------------- | -------------------------- | ------------------------- | --------------------- |
| Longo et al. (2024)    | 27 leading XAI researchers | Information Fusion        | XAI 2.0 manifesto     |
| Watson (2022)          | UCL philosophy of science  | Synthese                  | Conceptual challenges |
| Ghassemi et al. (2021) | MIT/Harvard Medical        | The Lancet Digital Health | Clinical XAI critique |
| Bhatt et al. (2020)    | CMU/Cambridge/PAI          | FAT\* (FAccT)             | Deployment study      |
| Pawlicki et al. (2024) | European cybersecurity     | Neurocomputing            | Metrics critique      |

### Open Challenges Summary

| Theme             | Count | Key challenges                                                                                  |
| ----------------- | ----- | ----------------------------------------------------------------------------------------------- |
| Technical         | 6     | Formal definitions, evaluation metrics, robustness, completeness, ground truth, reproducibility |
| Human-centred     | 5     | Cognitive load, trust calibration, personalisation, mental models, longitudinal effects         |
| Interdisciplinary | 5     | HCI, cognitive science, philosophy, social science, legal                                       |
| Regulatory        | 3     | Right to explanation, auditing frameworks, standardisation                                      |
| Methodological    | 3     | Longitudinal studies, field studies, human-grounded validation                                  |

### Citability Snapshot

| Claim category       | Count | Examples                                                                                                                                     |
| -------------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Verified (consensus) | 4     | 22 challenges represent field-wide identification; human-centred paradigm needed; metrics crisis; interdisciplinary infrastructure essential |
| Inferred             | 3     | Regulatory engagement creates both opportunity and risk; transition is generational; evaluation is the most actionable priority              |
| Speculative          | 2     | Human-centred paradigm will succeed (widespread agreement but unproven); field is willing to confront limitations honestly                   |

### Full Series Reference Map

| Article | Title                            | Date       | Core papers                                                          |
| ------- | -------------------------------- | ---------- | -------------------------------------------------------------------- |
| 1       | Foundations of Interpretable ML  | 2026-06-28 | Doshi-Velez, Barredo Arrieta, Molnar, Watson (foundations), Chazette |
| 2       | Methods and Techniques           | 2026-07-02 | Samek, Lapuschkin, Li, Poeta                                         |
| 3       | Critical Perspectives and Limits | 2026-07-06 | Ghassemi, Watson (critique), Bhatt, Casper, Pawlicki                 |
| 4       | Practice, Evaluation, Governance | 2026-07-10 | Salvi, Dwivedi, Hassija, Bhatt, Casper                               |
| 5       | XAI 2.0 and Open Challenges      | 2026-07-14 | Longo, Watson, Ghassemi, Bhatt, Pawlicki                             |

</details>
