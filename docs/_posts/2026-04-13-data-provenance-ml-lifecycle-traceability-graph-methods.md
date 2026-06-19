---
layout: post
last_modified_at: 2026-06-03
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

Where did the training data come from? Who transformed it, and when, and into what? Three papers converge on these questions from incompatible starting points, and that divergence is itself a finding.

Karuna et al. wire financial transactions into a graph (entities as nodes, transfers as edges) and pit GNN-based traceability against logistic regression and random forest baselines {% include references/cite.html key="prov-2026-ref1" %}. Pina et al. build a stitching layer: separate tools capture provenance at separate lifecycle stages, and their prototype forces those fragments to talk {% include references/cite.html key="prov-2026-ref2" %}. Souza et al. go formal: PROV-ML extends W3C PROV with ML Schema vocabulary, pressure-tested through ProvLake on a 48-GPU oil-and-gas pipeline {% include references/cite.html key="prov-2026-ref3" %}.

Three papers. Not a field survey. Not even close. This review is deliberately narrow, and that narrowness is the point. Claims anchored to reported results say so; inferences drawn beyond any single paper's evidence are marked at the boundary. Several details resist independent corroboration. Rather than silently absorbing them, I flag them.

This article is designed for technical and governance learning. It does not provide legal, regulatory, or procurement advice. It is not legal advice. Readers should validate applicability against their own jurisdiction, risk model, and production constraints.

## Definitions

<dl>
  <dt><dfn>Data provenance</dfn></dt>
  <dd>A record of the origin, transformations, and ownership history of a dataset, used to establish trust, support auditing, and enable reproducibility in data-driven workflows.</dd>

  <dt><dfn>ML lifecycle traceability</dfn></dt>
  <dd>The ability to track and link data inputs, preprocessing steps, training configurations, and model outputs across the full machine learning development and deployment pipeline.</dd>

  <dt><dfn>Provenance graph</dfn></dt>
  <dd>A directed graph that represents entities, activities, and agents involved in data production and transformation, typically following the W3C PROV model.</dd>

  <dt><dfn>Data lineage</dfn></dt>
  <dd>The path a data element follows from its source through successive transformations to its current form, often used interchangeably with provenance but emphasising the transformation chain.</dd>

  <dt><dfn>Reproducibility</dfn></dt>
  <dd>The capacity to obtain consistent results when an experiment or pipeline is re-executed with the same data, code, and configuration, a core requirement for scientific and operational credibility.</dd>
</dl>

---

## Thematic Analysis

The three papers circle the same territory from different altitudes. What follows groups their overlapping concerns. With hard boundaries on how far the evidence actually stretches.

### Graph-Structured Representations and Relational Provenance

Karuna et al. wire financial transaction data into a graph and report their GCN hitting 91.3% accuracy on traceability classification. A meaningful jump over logistic regression at 78.4% and random forests at 82.1% on the same dataset {% include references/cite.html key="prov-2026-ref1" %}. This is a **verified finding** within the study's conditions. It suggests graph representations can preserve relational structure that tabular models discard, though this conclusion is bounded by a single dataset in one domain. The paper does not compare against other graph-based approaches (e.g., graph attention networks), which limits the claim that GCN is the right architecture rather than merely a sufficient one.

Souza et al. also lean on graphs. But differently. Their W3C PROV model represents provenance as relationships between entities, activities, and agents {% include references/cite.html key="prov-2026-ref3" %}; no neural networks involved. Both teams chose graph primitives, yet for fundamentally different jobs: classification versus representation. Don't conflate the two. Structural similarity is not functional equivalence (**inferred synthesis**).

### Preprocessing Decisions and Downstream Effects

Can you join preprocessing provenance with training metrics in a single query? Pina et al. say yes. Their prototype does it {% include references/cite.html key="prov-2026-ref2" %}. That much is verified. But here's the gap: neither they nor anyone else in this source set runs a controlled experiment quantifying how much preprocessing choices actually bend model accuracy. Souza et al. call data curation the most complex lifecycle phase {% include references/cite.html key="prov-2026-ref3" %}. Both papers' rationale supports the intuition that preprocessing decisions propagate into model quality; neither nails it down with isolated evidence (**inferred synthesis**).

### Interoperability

Pina et al. frame their work as addressing the limitation that many existing solutions require a single capture tool across lifecycle stages {% include references/cite.html key="prov-2026-ref2" %}. Souza et al. reduce this barrier by instrumenting existing workflows {% include references/cite.html key="prov-2026-ref3" %}. Both reduce adoption barriers within their respective prototype scope (**verified finding** per paper). Neither claims interoperability across arbitrary tool combinations.

### Persona-Driven Requirements

Souza et al. characterize four persona types and ground their design in documented needs {% include references/cite.html key="prov-2026-ref3" %} (**verified finding**). Pina et al. derive use cases from community sources {% include references/cite.html key="prov-2026-ref2" %}. Karuna et al. ground requirements in financial auditing {% include references/cite.html key="prov-2026-ref1" %}. The inference that persona-driven design leads to better adoption is plausible but untested in any of these papers (**inferred synthesis**).

---

## Critical Assessment of Methodology and Limitations

### Karuna et al.

A 13-point accuracy gap over logistic regression is hard to ignore. The scalability numbers tell their own story: processing time balloons from 12 seconds at 10,000 transactions to 1,450 seconds at a million, while memory climbs from 200 MB to 8,500 MB {% include references/cite.html key="prov-2026-ref1" %}. Three caveats matter for interpretation. First, the dataset is described in aggregate terms without confirmed public release; independent replication requires data and code access. Second, the baselines used (logistic regression, random forests) are standard ML classifiers rather than competing graph-based approaches, so the comparison establishes improvement over non-graph methods without positioning GCN against alternatives in its own class. Third, the reviewed text does not report run-to-run variance or confidence intervals, which limits statistical confidence in the magnitude of uplift.

Some sections of the paper read as polished restatements of standard GNN and blockchain concepts. The related works coverage is broad rather than deeply comparative.

### Pina et al.

The prototype stitches provenance from different capture tools into a queryable whole {% include references/cite.html key="prov-2026-ref2" %}. Scope boundary: structured data preprocessing and DNN training/evaluation only. Image augmentation, text tokenization. Untouched. And overhead benchmarks? Absent entirely. So the feasibility claim is about correctness, not speed. Read it as architectural proof-of-concept; don't mistake it for a production-readiness verdict.

### Souza et al.

Forty-eight GPUs on an oil-and-gas seismic pipeline. That's the strongest practical evidence in this source set {% include references/cite.html key="prov-2026-ref3" %}. Impressive? Sure. But PROV-ML remains a proposed research representation, evaluated in exactly one domain. The paper itself calls it "proposed," not "standard." Consider what that means: whether PROV-ML transfers to a team fine-tuning a pretrained model on a single commodity GPU is entirely untested. One successful deployment pattern; not field-level validation.

---

## Lessons for Practice (Scoped to This Source Set)

What follows is practitioner-facing. Evidence-informed, yes. But deliberately scoped. Three papers yield useful guidance; they do not yield universal truths.

### 1. Treat Provenance as Part of System Architecture

Every paper in this set treats provenance as architecture, not afterthought {% include references/cite.html key="prov-2026-ref1" %}, {% include references/cite.html key="prov-2026-ref2" %}, {% include references/cite.html key="prov-2026-ref3" %}. Bolt it on later and you pay twice: once for integration, again for the review friction nobody budgeted for.

### 2. Use Graph Methods When Relationships Are Central to the Task

Karuna et al. report stronger performance for GCN than two tabular baselines in their study {% include references/cite.html key="prov-2026-ref1" %}. This supports graph-first experimentation for relational lineage data, but it is not evidence of universal superiority.

### 3. Bring Preprocessing Lineage Into Model Review

Pina et al. spotlight the chasm between training provenance and preprocessing provenance {% include references/cite.html key="prov-2026-ref2" %}; Souza et al. hammer on curation complexity {% include references/cite.html key="prov-2026-ref3" %}. The practical takeaway? Model metrics without transformation history are dangerously under-contextualized.

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

Accumulating supportive findings is easy. Too easy. A strong synthesis hunts for failure cases and negative evidence. Reports where provenance integration backfired, where lineage capture added complexity without improving governance outcomes. That's the next-pass reading priority.

---

## Open Questions and Residual Risks

**Generalization.** Each paper validates in one domain. Cross-domain transfer depends on assumptions about data structure, tools, and team composition. No cross-domain evidence exists in the reviewed literature.

**PROV-ML maturity.** PROV-ML is a proposed research representation, not an industry standard {% include references/cite.html key="prov-2026-ref3" %}. The literature does not address schema versioning as tooling evolves.

**Privacy.** None of the three works addresses the tension between comprehensive provenance capture and data privacy regulations. This is a gap observation; the papers do not claim to address privacy.

**Replication.** Public availability of datasets and code for independent replication could not be confirmed from the reviewed text for any of the three papers.

## Common Questions

### What is data provenance in the machine-learning lifecycle, beyond basic lineage?

Data provenance in machine learning is the record of where training data originated, how it was cleaned and transformed, which model versions it produced, and which individuals or systems were responsible at each stage. Provenance answers the question "why does this model behave this way?" by tracing outputs back to input data and pipeline decisions. All three papers in this review treat provenance as a lifecycle-design requirement rather than a logging afterthought.

### How is ML data provenance different from standard data lineage?

Data provenance and data lineage both trace data through a pipeline, but they differ in focus. Lineage records where data moved, which inputs fed which outputs. Provenance adds agent information: who or what performed each transformation, under what conditions, for what purpose, and with what authorization. The [W3C PROV](https://www.w3.org/TR/prov-overview/) standard formalizes this distinction using the entity-activity-agent model that Souza et al. extend in PROV-ML {% include references/cite.html key="prov-2026-ref3" %}.

### Which tooling patterns are most relevant for ML provenance implementation today for data provenance?

Production teams commonly use [MLflow](https://mlflow.org/), [OpenLineage](https://openlineage.io/), [Pachyderm](https://www.pachyderm.com/), and [DVC](https://dvc.org/) for experiment tracking and lineage. The papers reviewed here test different approaches: Karuna et al. build a GNN-based traceability classifier {% include references/cite.html key="prov-2026-ref1" %}, Pina et al. integrate separate lifecycle tools using DNNProv and Chapman et al.'s preprocessing capture {% include references/cite.html key="prov-2026-ref2" %}, and Souza et al. extend ProvLake with the PROV-ML vocabulary {% include references/cite.html key="prov-2026-ref3" %}. This review assesses the three research approaches; it does not benchmark them against the production tooling ecosystem.

### How does PROV-ML extend W3C PROV for machine-learning-specific traceability for data provenance?

PROV-ML, proposed by Souza et al., extends the base [W3C PROV](https://www.w3.org/TR/prov-overview/) model with [W3C ML Schema](https://www.w3.org/TR/ml-schema/) vocabulary to capture ML-specific concepts: hyperparameters, training runs, dataset versions, and evaluation metrics. It maps four user personas (domain scientists, computational engineers, ML engineers, and provenance specialists) to provenance query patterns. The PROV-ML design was evaluated in an oil and gas seismic classification pipeline using 48 GPUs through the ProvLake system. Whether it generalizes beyond that domain is an open question the paper does not demonstrate {% include references/cite.html key="prov-2026-ref3" %}.

It claims scoped guidance from three papers. It does not claim field-wide representativeness or comparative superiority over the broader lineage tooling ecosystem.

### Is the reported 91.3% GCN result generalizable beyond its study context for data provenance?

No. It is a paper-reported result in one evaluation context {% include references/cite.html key="prov-2026-ref1" %}. This review does not treat it as a universal benchmark.

### Why does preprocessing provenance remain a high-risk traceability gap for data provenance?

Because both relevance and complexity show up there: Pina et al. identify integration gaps at that stage {% include references/cite.html key="prov-2026-ref2" %}, and Souza et al. identify curation as difficult {% include references/cite.html key="prov-2026-ref3" %}.

### Is PROV-ML an adopted standard or an emerging representation model for data provenance?

In this evidence set, PROV-ML is best described as a proposed representation with promising applied evidence in a specific domain context {% include references/cite.html key="prov-2026-ref3" %}.

### Should teams deploy provenance tooling immediately, or run stack-specific pilots first for data provenance?

Use this article as orientation, not as a deployment checklist. Before adoption decisions, compare against your own stack, load profile, compliance obligations, and failure modes.

### What is the strongest next step for deeper ML provenance evaluation for data provenance?

Run a broader review that includes MLflow, OpenLineage, Pachyderm, and DVC literature, then test candidate approaches against your production constraints and governance requirements.

## Coverage Gaps and Next-Literature Priorities

This review does not yet include comparative analysis against production tooling ecosystems commonly used for lineage and experiment tracking. Priority next-pass sources should include MLflow, OpenLineage, Pachyderm, and DVC design and evaluation literature, followed by studies that report measurable interoperability and overhead outcomes under production load.

A second priority is contradiction-seeking: identify studies where provenance integration increased operational complexity or where lineage capture failed to improve model governance outcomes. Without that adversarial read, synthesis risks confirmation bias.

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Source Inventory and Evidence Grading" %}

### Author and Source Credibility

This article is authored by [Zenith Law](/authors/zenith-law/) and synthesises findings from peer-reviewed conference papers published at IEEE ICICAT, ACM WWW, and the WORKS workshop at SC. The sources report experimental results on graph neural network-based provenance tracking, provenance integration prototypes, and the PROV-ML standardisation effort for ML pipeline metadata.

### Appendix Table of Contents

- [Author and Source Credibility](#author-and-source-credibility)
- [Source Inventory and Evidence Grading](#source-inventory-and-evidence-grading)
- [Scope and Verification Boundary](#scope-and-verification-boundary)
- [Source-Level Assessment](#source-level-assessment)

<blockquote>
<strong>Synthesis note:</strong> This review prioritizes entity-activity-agent traceability because that structure is foundational for portable provenance interpretation.
</blockquote>

<figure markdown="1">
  <img src="/assets/images/data-provenance-ml-lifecycle-traceability-graph-methods.png" alt="Data provenance lifecycle with graph traceability links among preprocessing, training, and governance checkpoints" loading="lazy" decoding="async" width="1600" height="900" />
  <figcaption>
    Figure A1. Provenance evidence map across preprocessing, training, evaluation, and governance audit surfaces.
  </figcaption>
</figure>

### Source-Level Assessment

<dl>
  <dt><dfn>Traceability completeness</dfn></dt>
  <dd>The proportion of required lineage links that can be reconstructed for a model decision or pipeline output.</dd>

  <dt><dfn>Integration overhead</dfn></dt>
  <dd>The additional compute, storage, and operational burden introduced by provenance-capture and query infrastructure.</dd>

  <dt><dfn>Persona-driven provenance</dfn></dt>
  <dd>A provenance model tailored to distinct stakeholder information needs, such as ML engineers, domain scientists, and auditors.</dd>
</dl>

> **Claim-level labeling convention used throughout this article:**
>
> - **Verified finding**: directly stated or demonstrated in the cited source.
> - **Inferred synthesis**: logical interpretation connecting findings across sources; not directly stated in any one paper.
> - **Unverified detail**: plausible based on source context but not independently confirmed from the available text.

### Source Inventory and Evidence Grading

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

</details>
