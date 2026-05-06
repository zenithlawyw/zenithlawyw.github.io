---
layout: post
title: "Data Provenance in Machine Learning: Traceability, Graph Methods, and Governance Lessons"
author: Zenith Law
description: "Graph neural networks, PROV-ML, and data lineage in machine learning. Evidence-graded review with ten practical governance lessons for ML practitioners."
permalink: /data-provenance-ml-lifecycle-traceability-graph-methods-ten-lessons
intro: "Data provenance in machine learning tracks where training data came from, how it was transformed, and which model versions resulted. Three scholarly papers evaluate this with graph neural networks, integration prototypes, and the PROV-ML standard. This review grades each approach, states evidence limits, and derives ten practical lessons for ML practitioners."
image: /assets/images/data-provenance-ml-lifecycle-traceability-graph-methods.png
hero:
  image: /assets/images/data-provenance-ml-lifecycle-traceability-graph-methods.png
keywords: "data provenance, data provenance machine learning, data lineage vs provenance, graph neural networks traceability, ML traceability, PROV-ML, W3C PROV, deep learning provenance, GNN traceability, ML reproducibility, data governance ML, provenance tools machine learning"
catchwords: "data provenance, data lineage, ml lifecycle, traceability, graph methods, reproducibility, model governance, PROV-ML, GNN traceability, W3C PROV"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - prov-2026-ref1
  - prov-2026-ref2
  - prov-2026-ref3
categories:
  - Artificial Intelligence
tags:
  - data provenance
  - machine learning
  - traceability
  - graph neural network
  - reproducibility
  - ai governance
---

## Introduction

Three recent works address the problem of tracking data transformations across the machine learning lifecycle. Each approaches provenance from a different application context and proposes a different technical strategy.

Karuna et al. report a study that applies Graph Neural Networks to financial transaction data, representing entities as nodes and transactions as edges, and comparing GNN-based traceability against logistic regression and random forest baselines {% include references/cite.html key="prov-2026-ref1" %}. Pina et al. describe a prototype for integrating provenance data captured by separate tools at different stages of the deep learning lifecycle, connecting preprocessing records with training outcomes {% include references/cite.html key="prov-2026-ref2" %}. Souza et al. propose PROV-ML, a provenance data representation that extends W3C PROV with ML Schema vocabulary, and evaluate it through ProvLake system extensions in an oil and gas application using 48 GPUs {% include references/cite.html key="prov-2026-ref3" %}.

This review examines each paper's claims, methods, and limitations, then derives scoped implications from those results. It is intentionally narrow: three papers are not treated as a representative sample of the provenance ecosystem. Where a claim rests directly on a paper's reported results, the text says so. Where the review draws inferences beyond what any single paper demonstrates, that boundary is marked. Several details could not be independently corroborated and are flagged accordingly.

This article is designed for technical and governance learning. It does not provide legal, regulatory, or procurement advice. Readers should validate applicability against their own jurisdiction, risk model, and production constraints.

> **Claim-level labeling convention used throughout this article:**
>
> - **Verified finding**: directly stated or demonstrated in the cited source.
> - **Inferred synthesis**: logical interpretation connecting findings across sources; not directly stated in any one paper.
> - **Unverified detail**: plausible based on source context but not independently confirmed from the available text.

---

## Source Inventory and Evidence Grading

### Scope and Verification Boundary

The source set is deliberately small and non-exhaustive. It supports a focused comparison, not a field-wide conclusion. In particular, this article does not benchmark these papers against widely used data lineage platforms such as MLflow, OpenLineage, Pachyderm, or DVC, and therefore does not claim comparative superiority over those ecosystems.

### Karuna et al. (2024)

This paper was published at the 2024 International Conference on IoT, Communication and Automation Technology (ICICAT), an IEEE conference {% include references/cite.html key="prov-2026-ref1" %}. The paper reports using a dataset described as containing 1,000,000 transactions from 100,000 entities at a global financial organization. The experimental design compares a Graph Convolutional Network implementation (built with PyTorch Geometric, trained on an NVIDIA Tesla V100 GPU) against logistic regression and random forest baselines.

The paper reports the following metrics:

| Model               | Accuracy | Precision | Recall | F1-Score |
| ------------------- | -------- | --------- | ------ | -------- |
| Logistic Regression | 78.4%    | 75.6%     | 77.2%  | 76.4%    |
| Random Forest       | 82.1%    | 79.5%     | 80.4%  | 79.9%    |
| GNN (GCN)           | 91.3%    | 89.7%     | 90.5%  | 90.1%    |

The paper also reports traceability completeness improving from 75.6% to 92.4% {% include references/cite.html key="prov-2026-ref1" %}.

**Evidence grade:** The numerical claims above are verified findings taken directly from the paper's reported results. These metrics are internal to the study's evaluation framework and reflect the authors' experimental setup rather than a community-accepted benchmark protocol. The paper excerpt reviewed here does not provide uncertainty statistics (for example, variance across runs or confidence intervals), and it does not make the task formulation behind "traceability completeness" fully transparent in this review context. Whether the dataset or code has been publicly released could not be confirmed (**unverified detail**).

### Pina et al. (2023)

This paper appeared in the Companion Proceedings of the ACM Web Conference 2023 (WWW '23 Companion) {% include references/cite.html key="prov-2026-ref2" %}. The work describes a prototype that integrates provenance data from preprocessing operations (captured using the approach of Chapman et al.) with training provenance captured by DNNProv. The authors present use cases derived from Data Science Stack Exchange questions and published literature.

**Evidence grade:** The contribution is architectural. The paper demonstrates integration feasibility and formulates provenance queries that join preprocessing records with training metrics. It does not report production-scale overhead measurements for the integrated pipeline, and the current version is limited to structured data preprocessing. These characterizations are verified findings drawn from the paper text. The absence of quantitative stress testing means this source primarily supports a "can integrate" claim, not a "scales under production constraints" claim.

### Souza et al. (2019)

The paper is described on its title page as an author preprint accepted at the 14th WORKS Workshop, co-located with SC 2019 {% include references/cite.html key="prov-2026-ref3" %}. The publication venue claim is taken at face value from the paper's own statement; it was not independently verified against the proceedings record (**unverified detail**). The paper introduces PROV-ML as a proposed data representation (not an industry-adopted standard) that combines W3C PROV with W3C ML Schema. It provides extensions to the ProvLake system and reports evaluation in an oil and gas seismic classification application using 48 GPUs in parallel.

The paper identifies four persona types whose provenance needs motivated the PROV-ML design: domain scientists, computational scientists and engineers, ML scientists and engineers, and provenance specialists {% include references/cite.html key="prov-2026-ref3" %}.

**Evidence grade:** The PROV-ML representation, ProvLake extensions, 48-GPU evaluation, and persona characterization are verified findings, well-supported by the paper's abstract and body text. The generalizability to domains beyond the reported oil and gas case is an open claim the paper itself does not demonstrate. The "48 GPUs" detail is treated here as a study-specific context indicator, not as standalone proof of broad operational maturity.

| Source        | Venue                 | Year | Method                           | Domain                 | Evidence Grade                                                               |
| ------------- | --------------------- | ---- | -------------------------------- | ---------------------- | ---------------------------------------------------------------------------- |
| Karuna et al. | IEEE ICICAT           | 2024 | GNN (GCN) vs baselines           | Financial traceability | Quantitative; internal evaluation; no confirmed public replication artifacts |
| Pina et al.   | ACM WWW '23 Companion | 2023 | Provenance integration prototype | DL lifecycle (general) | Architectural; feasibility demonstrated; no overhead benchmarks              |
| Souza et al.  | WORKS @ SC 2019       | 2019 | PROV-ML + ProvLake extensions    | O&G / CSE              | Practical; 48-GPU evaluation; single-domain validation                       |

---

## Thematic Analysis

The three papers touch on overlapping concerns. The following observations group related findings, with explicit boundaries on how far the evidence stretches.

### Graph-Structured Representations and Relational Provenance

Karuna et al. represent financial data as a graph and report that their GCN model achieves 91.3% accuracy on traceability classification, compared with 78.4% for logistic regression and 82.1% for random forests on their dataset {% include references/cite.html key="prov-2026-ref1" %}. This is a **verified finding** within the study's conditions. It suggests graph representations can preserve relational structure that tabular models discard, though this conclusion is bounded by a single dataset in one domain. The paper does not compare against other graph-based approaches (e.g., graph attention networks), which limits the claim that GCN is the right architecture rather than merely a sufficient one.

Souza et al. also use a graph-based model through W3C PROV, representing provenance as relationships between entities, activities, and agents {% include references/cite.html key="prov-2026-ref3" %}. They do not apply graph neural networks. The two papers share a structural preference for graphs but serve different purposes: Karuna et al. use graph structure for classification; Souza et al. use it for provenance representation. The convergence on graph primitives should not be overstated as implying functional equivalence (**inferred synthesis**).

### Preprocessing Decisions and Downstream Effects

Pina et al. demonstrate that their prototype can answer queries that join preprocessing provenance with training metrics {% include references/cite.html key="prov-2026-ref2" %}. This capability is a **verified finding**. The paper does not report experiments quantifying how much preprocessing choices affect model accuracy in controlled settings. Souza et al. describe data curation as the most complex lifecycle phase {% include references/cite.html key="prov-2026-ref3" %}. The broader inference that preprocessing decisions propagate into model quality is directionally supported by both papers' rationale, but neither provides a controlled experiment isolating this effect (**inferred synthesis**).

### Interoperability

Pina et al. frame their work as addressing the limitation that many existing solutions require a single capture tool across lifecycle stages {% include references/cite.html key="prov-2026-ref2" %}. Souza et al. reduce this barrier by instrumenting existing workflows {% include references/cite.html key="prov-2026-ref3" %}. Both reduce adoption barriers within their respective prototype scope (**verified finding** per paper). Neither claims interoperability across arbitrary tool combinations.

### Persona-Driven Requirements

Souza et al. characterize four persona types and ground their design in documented needs {% include references/cite.html key="prov-2026-ref3" %} (**verified finding**). Pina et al. derive use cases from community sources {% include references/cite.html key="prov-2026-ref2" %}. Karuna et al. ground requirements in financial auditing {% include references/cite.html key="prov-2026-ref1" %}. The inference that persona-driven design leads to better adoption is plausible but untested in any of these papers (**inferred synthesis**).

---

## Critical Assessment of Methodology and Limitations

### Karuna et al.

The reported accuracy gap (91.3% vs. 78.4% for logistic regression) is substantial within the study's evaluation. The scalability data, with processing time rising from 12 seconds at 10,000 transactions to 1,450 seconds at 1,000,000 and memory from 200 MB to 8,500 MB, provides useful practical bounds {% include references/cite.html key="prov-2026-ref1" %}. Three caveats matter for interpretation. First, the dataset is described in aggregate terms without confirmed public release; independent replication requires data and code access. Second, the baselines used (logistic regression, random forests) are standard ML classifiers rather than competing graph-based approaches, so the comparison establishes improvement over non-graph methods without positioning GCN against alternatives in its own class. Third, the reviewed text does not report run-to-run variance or confidence intervals, which limits statistical confidence in the magnitude of uplift.

Some sections of the paper read as polished restatements of standard GNN and blockchain concepts. The related works coverage is broad rather than deeply comparative.

### Pina et al.

The prototype demonstrates that provenance data from different capture tools can be joined and queried {% include references/cite.html key="prov-2026-ref2" %}. The acknowledged scope boundary is structured data preprocessing and DNN training/evaluation. Unstructured preprocessing operations (image augmentation, text tokenization) are not covered. The absence of overhead benchmarks for the integration layer means the feasibility claim concerns correctness, not efficiency. The paper is therefore best read as architectural feasibility evidence, not a production-readiness benchmark.

### Souza et al.

The 48-GPU evaluation in an oil and gas application is the strongest practical evidence in this set {% include references/cite.html key="prov-2026-ref3" %}. PROV-ML is a proposed research representation evaluated in one domain. The characterization of it as "proposed" rather than "standard" tracks the paper's own framing. Whether PROV-ML transfers to lightweight ML settings (e.g., fine-tuning a pretrained model on commodity hardware) is not demonstrated. Read as evidence of one successful deployment pattern, not field-level validation.

---

## Ten Lessons for Practice (Scoped to This Source Set)

These lessons are meant for practitioners and learners reading this blog. They are evidence-informed but intentionally scoped: three papers can support useful guidance, not universal claims.

### 1. Treat Provenance as Part of System Architecture

All three papers position provenance as a lifecycle design issue rather than a logging add-on {% include references/cite.html key="prov-2026-ref1" %}, {% include references/cite.html key="prov-2026-ref2" %}, {% include references/cite.html key="prov-2026-ref3" %}. In practice, delaying provenance design usually increases integration cost and review friction.

### 2. Use Graph Methods When Relationships Are Central to the Task

Karuna et al. report stronger performance for GCN than two tabular baselines in their study {% include references/cite.html key="prov-2026-ref1" %}. This supports graph-first experimentation for relational lineage data, but it is not evidence of universal superiority.

### 3. Bring Preprocessing Lineage Into Model Review

Pina et al. highlight the gap between training provenance and preprocessing provenance {% include references/cite.html key="prov-2026-ref2" %}, while Souza et al. stress curation complexity {% include references/cite.html key="prov-2026-ref3" %}. A practical takeaway is simple: model metrics without transformation history are often under-contextualized.

### 4. Separate Feasibility Questions From Reliability Questions

Pina et al. mostly answer "can this be integrated?" {% include references/cite.html key="prov-2026-ref2" %}. Souza et al. provide a demanding execution context {% include references/cite.html key="prov-2026-ref3" %}. Production readiness requires both dimensions, not one.

### 5. Ask for Uncertainty Reporting, Not Only Point Estimates

Karuna et al. provide point metrics and scaling behavior {% include references/cite.html key="prov-2026-ref1" %}, but this review context does not include run-to-run variance or confidence intervals. For operational decisions, request uncertainty information before treating uplift magnitudes as stable.

### 6. Adopt Shared Vocabulary Early, But Stay Honest About Maturity

PROV-ML is useful as a proposed representation in Souza et al.'s evaluated setting {% include references/cite.html key="prov-2026-ref3" %}. Teams can borrow vocabulary discipline now, while avoiding premature claims of ecosystem-level standardization.

### 7. Let Requirements Drive Tooling, Not the Other Way Around

Across the papers, provenance needs emerge from auditability, domain workflow, and user questions {% include references/cite.html key="prov-2026-ref1" %}, {% include references/cite.html key="prov-2026-ref2" %}, {% include references/cite.html key="prov-2026-ref3" %}. Tool choice should follow those requirements.

### 8. Build for Queryability During Execution, Not Only Afterward

Souza et al. show runtime query usage {% include references/cite.html key="prov-2026-ref3" %}; Pina et al. note limits of after-the-fact visibility in some approaches {% include references/cite.html key="prov-2026-ref2" %}. Earlier query access can reduce the cost of corrective action.

### 9. Benchmark Overhead in Your Own Environment

This source set does not define a universal overhead threshold. Use your latency and throughput constraints as the benchmark frame, especially when lineage capture competes with production SLAs.

### 10. Keep a Contradiction-Seeking Loop in the Reading Process

A strong synthesis is not only accumulation of supportive findings. It also looks for failure cases and negative evidence. For this topic, next-pass reading should actively target reports where provenance integration increased complexity or failed to improve governance outcomes.

---

## Open Questions and Residual Risks

**Generalization.** Each paper validates in one domain. Cross-domain transfer depends on assumptions about data structure, tools, and team composition. No cross-domain evidence exists in the reviewed literature.

**PROV-ML maturity.** PROV-ML is a proposed research representation, not an industry standard {% include references/cite.html key="prov-2026-ref3" %}. The literature does not address schema versioning as tooling evolves.

**Privacy.** None of the three works addresses the tension between comprehensive provenance capture and data privacy regulations. This is a gap observation; the papers do not claim to address privacy.

**Replication.** Public availability of datasets and code for independent replication could not be confirmed from the reviewed text for any of the three papers.

## Frequently Asked Questions

### What is data provenance in machine learning?

Data provenance in machine learning is the record of where training data originated, how it was cleaned and transformed, which model versions it produced, and which individuals or systems were responsible at each stage. Provenance answers the question "why does this model behave this way?" by tracing outputs back to input data and pipeline decisions. All three papers in this review treat provenance as a lifecycle-design requirement rather than a logging afterthought.

### What is the difference between data provenance and data lineage?

Data provenance and data lineage both trace data through a pipeline, but they differ in focus. Lineage records where data moved, which inputs fed which outputs. Provenance adds agent information: who or what performed each transformation, under what conditions, for what purpose, and with what authorization. The [W3C PROV](https://www.w3.org/TR/prov-overview/) standard formalizes this distinction using the entity-activity-agent model that Souza et al. extend in PROV-ML {% include references/cite.html key="prov-2026-ref3" %}.

### What tools are used for data provenance in machine learning?

Production teams commonly use [MLflow](https://mlflow.org/), [OpenLineage](https://openlineage.io/), [Pachyderm](https://www.pachyderm.com/), and [DVC](https://dvc.org/) for experiment tracking and lineage. The papers reviewed here test different approaches: Karuna et al. build a GNN-based traceability classifier {% include references/cite.html key="prov-2026-ref1" %}, Pina et al. integrate separate lifecycle tools using DNNProv and Chapman et al.'s preprocessing capture {% include references/cite.html key="prov-2026-ref2" %}, and Souza et al. extend ProvLake with the PROV-ML vocabulary {% include references/cite.html key="prov-2026-ref3" %}. This review assesses the three research approaches; it does not benchmark them against the production tooling ecosystem.

### How does PROV-ML extend W3C PROV for machine learning?

PROV-ML, proposed by Souza et al., extends the base [W3C PROV](https://www.w3.org/TR/prov-overview/) model with [W3C ML Schema](https://www.w3.org/TR/ml-schema/) vocabulary to capture ML-specific concepts: hyperparameters, training runs, dataset versions, and evaluation metrics. It maps four user personas (domain scientists, computational engineers, ML engineers, and provenance specialists) to provenance query patterns. The PROV-ML design was evaluated in an oil and gas seismic classification pipeline using 48 GPUs through the ProvLake system. Whether it generalizes beyond that domain is an open question the paper does not demonstrate {% include references/cite.html key="prov-2026-ref3" %}.

It claims scoped guidance from three papers. It does not claim field-wide representativeness or comparative superiority over the broader lineage tooling ecosystem.

### Is the reported 91.3% GCN figure a universal result?

No. It is a paper-reported result in one evaluation context {% include references/cite.html key="prov-2026-ref1" %}. This review does not treat it as a universal benchmark.

### Why keep discussing preprocessing provenance?

Because both relevance and complexity show up there: Pina et al. identify integration gaps at that stage {% include references/cite.html key="prov-2026-ref2" %}, and Souza et al. identify curation as difficult {% include references/cite.html key="prov-2026-ref3" %}.

### Is PROV-ML already a standard?

In this evidence set, PROV-ML is best described as a proposed representation with promising applied evidence in a specific domain context {% include references/cite.html key="prov-2026-ref3" %}.

### Should teams deploy provenance tooling immediately after reading this article?

Use this article as orientation, not as a deployment checklist. Before adoption decisions, compare against your own stack, load profile, compliance obligations, and failure modes.

### What is the best next step for readers who want to go deeper?

Run a broader review that includes MLflow, OpenLineage, Pachyderm, and DVC literature, then test candidate approaches against your production constraints and governance requirements.

## Coverage Gaps and Next-Literature Priorities

This review does not yet include comparative analysis against production tooling ecosystems commonly used for lineage and experiment tracking. Priority next-pass sources should include MLflow, OpenLineage, Pachyderm, and DVC design and evaluation literature, followed by studies that report measurable interoperability and overhead outcomes under production load.

A second priority is contradiction-seeking: identify studies where provenance integration increased operational complexity or where lineage capture failed to improve model governance outcomes. Without that adversarial read, synthesis risks confirmation bias.
