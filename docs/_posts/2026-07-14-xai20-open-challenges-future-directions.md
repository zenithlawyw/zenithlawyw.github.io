---
layout: post
last_modified_at: 2026-08-29
title: "XAI 2.0 and the Road Ahead: Open Challenges and Future Directions"
author: Zenith Law
description: "A synthesis of the open challenges facing explainable AI, from the XAI 2.0 manifesto to emerging directions in interdisciplinary research, human-centred evaluation, and regulatory alignment."
permalink: /xai20-open-challenges-future-directions
intro: "The XAI 2.0 manifesto identifies 28 open problems across nine categories, spanning new types of AI, evaluation, human-centred explanation, and societal impact. This final article in the series synthesises those problems, connects them to the findings of the previous four articles, and identifies the research directions that will define the next generation of explainability. The central message is that XAI must transition from a method-centric discipline focused on producing explanations to a human-centred discipline focused on supporting understanding."
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

The XAI 2.0 manifesto, authored by 19 leading XAI researchers and published in Information Fusion in 2024, identifies 28 open problems across nine categories {% include references/cite.html key="LONGO2024102301" %}. This final article in the series synthesises those problems, connects them to the findings of the previous four articles, and maps the research directions that will define the next generation of explainability.

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

## The 28 Open Problems in Nine Categories

The manifesto groups 28 open problems into nine categories. The categories move from technical and conceptual problems (creating explanations for new forms of AI, improving current methods, clarifying concepts) through evaluation, human-centredness and multi-dimensionality, to adaptation, mitigation and societal impact. The following synthesis groups the problems into the nine categories and connects each to the findings of the previous articles in the series.

### 1. Creating Explanations for New Types of AI

**Problem 1. Creating explanations for generative models and large language models.** Existing XAI methods were built for classification and regression. Generative models and large language models with billions or trillions of parameters pose new challenges: the polysemantic nature of their neurons, the difficulty of synthesising explanations, and unresolved questions about whether neural scaling laws can be used to infer the quality of learned concepts. Mechanistic interpretability and information geometry are proposed as starting points.

**Problem 2. Creating explanations for distributed and collaborative learning.** Federated and other distributed learning settings train models across nodes that never share raw data. Explanation methods that assume centralised access to training data need rethinking for this setting, which is increasingly common in privacy and security-critical applications.

### 2. Improving and Augmenting Current XAI Methods

**Problem 3. Augmenting and improving attribution methods.** Attribution methods, including the feature attributions examined in the earlier series articles, remain dependent on the choice and quality of the underlying method. The call is to strengthen their faithfulness, stability and interpretability rather than treat any single method as final.

**Problem 4. Augmenting and improving concept-based learning algorithms.** Concept-based explanations operate at the level of human-interpretable concepts rather than raw features. The problems concern how concepts are discovered, how their grounding is verified, and how they generalise beyond the training distribution.

**Problem 5. Removing artefacts in synthesis-based explanations.** Synthesis-based explanations (for example, prototype and counterfactual generation) can inherit artefacts, so the image or instance shown does not faithfully represent the pattern that activates the model. Removing these artefacts is required before such explanations can be trusted.

**Problem 6. Creating robust explanations.** Explanation methods should be stable under small input perturbations that do not change the prediction. There is no agreed standard for acceptable stability, and robustness varies considerably across current methods.

### 3. Clarifying the Use of Concepts in XAI

**Problem 7. Elucidating the main concepts of XAI.** The field still lacks a universally accepted formal definition of explainability. The definition of Barredo Arrieta et al. is the closest to consensus, but it is descriptive rather than formal. Without formal definitions, mathematical guarantees about explanation quality are impossible (the formal-definitions concern from earlier analysis).

**Problem 8. Clarifying the relationship between XAI and trustworthiness.** XAI is frequently assumed to produce trustworthy or responsible AI, but the relationship between explanation and trustworthiness is not straightforward. The problem asks whether explanations genuinely support trustworthy behaviour or merely signal it, echoing the trust-calibration debate from the series.

**Problem 9. Finding a useful account of understanding.** If the goal of XAI is understanding rather than explanation, the field needs a workable account of what it means for a human to understand a model. This connects directly to the cognitive-science questions raised in the earlier articles about how explanations are processed.

### 4. Evaluating XAI Methods and Explanations

**Problem 10. Facilitating human evaluation of explanations.** Reliable evaluation ultimately depends on human judgement, but human studies are costly, hard to standardise and difficult to compare across labs. The problem is to make human evaluation of explanations more tractable.

**Problem 11. Creating an evaluation framework for XAI methods.** There is still no standardised, validated evaluation framework. The metrics crisis documented by Pawlicki et al., in which nearly ninety distinct metrics exist with substantial duplication and no consensus taxonomy ([Critical Perspectives and Limits of Current Explainability Methods](/critical-perspectives-limits-xai)), remains unresolved. The manifesto calls for community-wide agreement on core evaluation constructs.

**Problem 12. Overcoming limitations of studies with humans.** Human-subject studies in XAI suffer from limited sample sizes, single-session designs and weak reporting. The problem is to overcome these limitations so that evidence about explanation effectiveness is credible.

### 5. Supporting the Human-Centredness of Explanations

**Problem 13. Creating human-understandable explanations.** Explanations must be comprehensible to the people who use them, not merely technically correct. This reframes evaluation around whether understanding improves, consistent with the human-centred shift that is the central thesis of the manifesto.

**Problem 14. Facilitating explainability with concept-based explanations.** Because humans reason in terms of concepts rather than raw features, concept-based explanations may support human understanding more effectively than low-level attributions. The problem is to make this route practical and verifiable.

**Problem 15. Addressing explanations divorced from reality.** Explanations can be internally faithful to a model while remaining detached from the real-world context in which decisions are used. The problem is to keep explanations grounded in the application they are meant to support.

**Problem 16. Uncovering causality for actionable explanations.** Actionable explanation requires causal information, not only correlation. Understanding the causal relationships behind a decision is needed if users are to identify what could be changed, a theme that connects to the causal critique of correlation-based attribution in the earlier articles.

### 6. Supporting the Multi-Dimensionality of Explainability

**Problem 17. Creating multi-faceted explanations.** A single explanation format rarely serves all purposes. Multi-faceted explanations combine attribution, counterfactual, concept and textual accounts, each suited to a different question a user might ask.

**Problem 18. Enabling interdisciplinary work in XAI.** Explanation is simultaneously a mathematical, psychological, philosophical and sociological phenomenon. The manifesto argues that no single discipline can address all 28 problems, and that sustained collaboration between ML researchers, cognitive scientists, philosophers, legal scholars and social scientists is required.

### 7. Adjusting XAI Methods and Explanations

**Problem 19. Adjusting explanations to different stakeholders.** Regulators, clinicians, patients and engineers need different explanations. Current methods produce one-size-fits-all outputs that fit none of these groups well.

**Problem 20. Adjusting explanations to different domains.** Explanation requirements differ across domains, from clinical decision-making to finance to security. Methods need to be tailored to the conventions, risks and decision contexts of each domain.

**Problem 21. Adjusting explanations to different goals.** The purpose of an explanation (justification, debugging, compliance, learning) changes what a good explanation looks like. The problem is to adapt explanation generation and evaluation to the goal at hand.

### 8. Mitigating the Negative Impact of XAI

**Problem 22. Mitigating failed support by XAI.** Explanations intended to support decisions can instead mislead, confuse or give false confidence (the inscrutability and over-trust concerns of Ghassemi et al.{% include references/cite.html key="ghassemi2021falsehope" %}). The problem is to prevent explanations from causing harm when they fail.

**Problem 23. Devising criteria for the falsifiability of explanations.** If explanation claims cannot be tested and potentially refuted, they are not scientifically credible. The problem is to develop criteria under which an explanation can be shown to be wrong.

**Problem 24. Securing explanations from abuse by malicious human agents.** Explanations can be manipulated by humans to justify or conceal harmful automated decisions. The problem is to detect and resist such abuse.

**Problem 25. Securing explanations from abuse by malicious superintelligent agents.** At the outer edge of the research agenda, the manifesto raises the possibility of highly capable systems that could exploit explanations for their own ends, and asks how explanations should be designed to remain safe in such settings.

### 9. Improving the Societal Impact of XAI

**Problem 26. Facilitating originality attribution of AI-generated data and plagiarism detection.** As generative models produce content at scale, reliable attribution of authorship and detection of AI-generated material become necessary for academic and creative integrity.

**Problem 27. Facilitating the right to be forgotten.** Regulatory rights to erasure (notably under data protection law) interact with models that may have encoded personal data in their parameters. The problem is to reconcile explainable, auditable systems with the right to be forgotten.

**Problem 28. Addressing the power imbalance between individuals and companies.** Automated decision-making concentrates power in organisations that hold the data and run the models. The manifesto argues that XAI has a role in redressing this imbalance by giving individuals meaningful insight into decisions that affect them, including through participative and human rights-based design.

## Connecting the Challenges to the Series Findings

The 28 problems are not independent. They form a coherent structure that connects directly to the findings of the previous four articles.

| Article                  | Key finding                                        | Connected XAI 2.0 problems                                                                 |
| ------------------------ | -------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| 1. Foundations           | Interpretability is a relationship, not a property | Problems 7 (formal definitions), 13 (human-understandable explanations), 9 (understanding) |
| 2. Methods               | Method choice shapes what can be known             | Problems 5 (artefacts), 16 (causality), 17 (multi-faceted), 3 (attribution)                |
| 3. Critical perspectives | Limits are conceptual, not only technical          | Problems 8 (trustworthiness), 23 (falsifiability), 22 (failed support)                     |
| 4. Practice              | Integration is the challenge                       | Problems 19-21 (adjusting to stakeholders, domains, goals), 11 (evaluation framework)      |

## Research Directions

### From Method-Centric to Human-Centred

The paradigm shift that Longo et al. advocate requires reorienting XAI research. Instead of asking "what explanation method should we develop?" the field should ask "what do humans need to understand, and how can we support that understanding?" This shifts the evaluation criterion from technical properties (axioms satisfied) to human outcomes (understanding improved).

### Interdisciplinary Infrastructure

Several challenges require infrastructure that no single discipline can build. The integration of cognitive science findings into XAI design requires sustained collaboration between ML researchers and cognitive scientists (problem 18). The development of evaluation and auditing standards requires collaboration between technical researchers, legal scholars, and regulators (problems 11 and 28). Real-world deployment studies that track explanations in context need organisational access that is currently rare (problems 22 and 27).

### Evaluation as a First-Class Problem

The evaluation gap (problem 11) connects multiple other problems. Without reliable evaluation, progress on robustness (6), human-centredness (13) and trustworthiness (8) cannot be measured. The call of the XAI 2.0 manifesto for a community evaluation framework is the single most actionable recommendation for the field.

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

Longo et al. (2024){% include references/cite.html key="LONGO2024102301" %} organise 28 open problems into nine categories: creating explanations for new types of AI, improving current XAI methods, clarifying the use of concepts, evaluating XAI methods and explanations, supporting the human-centredness of explanations, supporting the multi-dimensionality of explainability, adjusting XAI methods and explanations, mitigating the negative impact of XAI, and improving the societal impact of XAI. The categories move from technical and conceptual problems towards evaluation, human-centred and societal problems.

### What distinguishes human-centred challenges from technical challenges in XAI?

Technical challenges focus on formal properties of explanations such as completeness, robustness, and reproducibility of attribution methods. Human-centred challenges address how explanations interact with human cognition including how much detail users can process, how explanations affect trust, and whether explanations personalise to different user expertise levels. Solving technical challenges does not automatically resolve human-centred ones.

### Why does the XAI 2.0 manifesto call for interdisciplinary infrastructure?

The manifesto argues that no single discipline can address all 28 problems because explanation is simultaneously a mathematical, psychological, and sociological phenomenon. Interdisciplinary infrastructure means shared experimental platforms, standardised evaluation protocols that work across disciplines, funding mechanisms that reward collaboration, and publication venues that accept hybrid contributions spanning computer science, cognitive science, and law.

### How can evaluation become a first-class problem in XAI research?

The manifesto argues that evaluation should shift from a post-hoc activity to a design-stage requirement. This means developing community-standard benchmarks, establishing ground-truth datasets for explanation correctness, creating reproducible evaluation protocols that span research groups, and making evaluation quality a publication criterion equivalent to methodological novelty. Currently, evaluation quality varies widely and is rarely treated as a primary contribution.

### What regulatory challenges does the XAI 2.0 manifesto identify?

The regulatory dimension runs through several of the nine categories rather than forming a single cluster. The right to be forgotten (problem 27) questions how explainable and auditable systems can also honour data erasure. The evaluation framework (problem 11) is what would make explanations auditable at scale. The power imbalance between individuals and companies (problem 28) raises human rights and participative design arguments that connect XAI to regulation. These problems are urgent because regulatory timelines are shortening while technical standards remain fluid.

<details markdown="1" class="appendix-callout group">
<summary>Appendix: Source Material</summary>

### Author and Source Credibility

| Source                 | Profile                    | Venue                     | Focus                 |
| ---------------------- | -------------------------- | ------------------------- | --------------------- |
| Longo et al. (2024)    | 19 leading XAI researchers | Information Fusion        | XAI 2.0 manifesto     |
| Watson (2022)          | UCL philosophy of science  | Synthese                  | Conceptual challenges |
| Ghassemi et al. (2021) | MIT/Harvard Medical        | The Lancet Digital Health | Clinical XAI critique |
| Bhatt et al. (2020)    | CMU/Cambridge/PAI          | FAT\* (FAccT)             | Deployment study      |
| Pawlicki et al. (2024) | European cybersecurity     | Neurocomputing            | Metrics critique      |

### Open Challenges Summary

| Category                                              | Count | Problems                                                                                  |
| ----------------------------------------------------- | ----- | ----------------------------------------------------------------------------------------- |
| Creating explanations for new types of AI             | 2     | Generative models and LLMs, distributed and collaborative learning                        |
| Improving and augmenting current XAI methods          | 4     | Attribution, concept-based learning, artefacts, robust explanations                       |
| Clarifying the use of concepts in XAI                 | 3     | Main concepts, XAI and trustworthiness, account of understanding                          |
| Evaluating XAI methods and explanations               | 3     | Human evaluation, evaluation framework, human-study limitations                           |
| Supporting the human-centredness of explanations      | 4     | Human-understandable, concept-based, grounded in reality, causal                          |
| Supporting the multi-dimensionality of explainability | 2     | Multi-faceted explanations, interdisciplinary work                                        |
| Adjusting XAI methods and explanations                | 3     | Stakeholders, domains, goals                                                              |
| Mitigating the negative impact of XAI                 | 4     | Failed support, falsifiability, malicious human agents, malicious superintelligent agents |
| Improving the societal impact of XAI                  | 3     | Originality attribution, right to be forgotten, power imbalance                           |

### Citability Snapshot

| Claim category       | Count | Examples                                                                                                                            |
| -------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Verified (consensus) | 4     | 28 problems grouped into nine categories; human-centred paradigm needed; metrics crisis; interdisciplinary infrastructure essential |
| Inferred             | 3     | Regulatory engagement creates both opportunity and risk; transition is generational; evaluation is the most actionable priority     |
| Speculative          | 2     | Human-centred paradigm will succeed (widespread agreement but unproven); field is willing to confront limitations honestly          |

### Full Series Reference Map

| Article | Title                            | Date       | Core papers                                                          |
| ------- | -------------------------------- | ---------- | -------------------------------------------------------------------- |
| 1       | Foundations of Interpretable ML  | 2026-06-28 | Doshi-Velez, Barredo Arrieta, Molnar, Watson (foundations), Chazette |
| 2       | Methods and Techniques           | 2026-07-02 | Samek, Lapuschkin, Li, Poeta                                         |
| 3       | Critical Perspectives and Limits | 2026-07-06 | Ghassemi, Watson (critique), Bhatt, Casper, Pawlicki                 |
| 4       | Practice, Evaluation, Governance | 2026-07-10 | Salvi, Dwivedi, Hassija, Bhatt, Casper                               |
| 5       | XAI 2.0 and Open Challenges      | 2026-07-14 | Longo, Watson, Ghassemi, Bhatt, Pawlicki                             |

</details>
