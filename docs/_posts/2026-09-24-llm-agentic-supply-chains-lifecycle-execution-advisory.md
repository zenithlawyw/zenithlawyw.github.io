---
layout: post
last_modified_at: 2026-09-24
title: "Securing LLM and Agentic AI Supply Chains: Lifecycle Frameworks and Execution-Bound Advisory"
author: Zenith Law
description: "Production LLM systems are supply chains whose artifacts include datasets, training pipelines, checkpoints, and inference interfaces. A five-layer lifecycle framework with hybrid post-quantum signing, and an AIBOM-driven advisory pipeline that classifies exploitability from runtime telemetry rather than static presence, examined from two peer-reviewed works."
permalink: /llm-agentic-supply-chains-lifecycle-execution-advisory
intro: "The security of a production LLM system is a supply chain problem, but the artifacts are not just code. They are datasets, training pipelines, checkpoints, model registries, inference interfaces, and application integrations, each with its own threat class that classical signing alone cannot cover. This article examines two peer-reviewed frameworks that extend supply chain security into this lifecycle: a five-layer security model for LLM software supply chains with hybrid post-quantum artifact signing, and an AIBOM-driven, execution-bound advisory pipeline for agentic AI that classifies exploitability from runtime telemetry rather than static presence. It is the third in a three-article series on software supply chain security, companion to articles on attack vectors and keyless signing, and on SBOM graphs and continuous compliance."
image: /assets/images/llm-agentic-supply-chains-lifecycle-execution-advisory.png
hero:
  image: /assets/images/llm-agentic-supply-chains-lifecycle-execution-advisory.png
related_posts:
  - title: "Software Supply Chain Attack Vectors and How Keyless Signing Counters Them"
    url: /software-supply-chain-attack-vectors-keyless-signing
  - title: "SBOM Graphs for Attack Chain Prediction and Workload Identity for Continuous Compliance"
    url: /sbom-graphs-attack-chains-continuous-compliance
  - title: "Building Agentic Orchestration: An MCP, A2A, LangGraph, and LangChain Playbook"
    url: /building-agentic-orchestration-mcp-a2a-langgraph-langchain-playbook
  - title: "MCP vs A2A: Practical Protocol Boundaries in Agentic Systems"
    url: /mcp-vs-a2a-practical-protocol-boundaries-agentic-systems
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - silva2026securing
  - radanliev2026execution
keywords: "LLM supply chain, AIBOM, artifact signing, post-quantum cryptography, ML-DSA, hybrid signatures, CSAF, VEX, MCP, A2A, AGNTCY, data poisoning, model extraction, prompt injection, execution-bound exploitability, runtime telemetry, agentic AI"
catchwords: "LLM supply chain, AIBOM, hybrid signatures, ML-DSA, CSAF-VEX, execution-bound exploitability, MCP, A2A, AGNTCY, data poisoning, agentic AI"
categories:
  - Cybersecurity
  - Artificial Intelligence
  - Software Engineering
tags:
  - LLM supply chain
  - AIBOM
  - post-quantum cryptography
  - CSAF-VEX
  - agentic AI
  - model lifecycle
---

## Introduction

Cryptographic provenance for artifacts, graph-aware reasoning over what artifacts contain, and continuous identity-based verification of where they run are the three foundations established in the companion articles. A production LLM system stresses all three at once because its supply chain is not code alone.

An LLM system depends on curated datasets, preprocessing pipelines, fine-tuning workflows, checkpoints, registries, model-serving APIs, retrieval systems, and orchestration interfaces {% include references/cite.html key="silva2026securing" %}. The code is only one node in that chain. This part examines two peer-reviewed works that extend supply chain security into this lifecycle: a five-layer security framework for LLM supply chains with hybrid post-quantum artifact signing {% include references/cite.html key="silva2026securing" %}, and an execution-bound advisory pipeline that classifies exploitability for agentic AI from runtime telemetry {% include references/cite.html key="radanliev2026execution" %}.

The thesis of both papers is the same in different registers: presence is not exploitability. A component being present and signed does not mean it is safe, and a vulnerable artifact listed in a bill of materials does not mean it is exploitable in a specific running system.

This article is educational and not legal advice.

## Why Classical Supply Chain Tooling Is Not Enough for Models

The layered framework paper starts from a precise boundary claim. Established mechanisms such as Sigstore, in-toto, SLSA, and TUF provide strong guarantees for artifact integrity and provenance, but they were designed for conventional software artifacts and do not fully capture AI-specific lifecycle threats such as data poisoning, training pipeline compromise, and retrieval-augmented prompt manipulation {% include references/cite.html key="silva2026securing" %}.

The failure is structural, not incidental. Unlike traditional packages, an LLM system is not produced from source code alone. Sigstore does not natively address dataset provenance, fine-tuning semantics, inference abuse, or prompt injection {% include references/cite.html key="silva2026securing" %}. In-toto provides a strong provenance model for expressing which steps were performed, by whom, and in what order, which is highly relevant to the training layer, but it remains a general framework {% include references/cite.html key="silva2026securing" %}. The guarantee stops at the artifact boundary, and in an LLM lifecycle the threats begin before artifacts exist and continue after they are deployed.

There is also a cryptographic horizon. Most artifact signing infrastructure relies on classical algorithms such as RSA or ECDSA. These are secure today, but they may be threatened by future large-scale quantum computers, which is why NIST standardised ML-DSA as a post-quantum signature scheme {% include references/cite.html key="silva2026securing" %}.

## The Five-Layer Lifecycle Framework

The response is a layered security framework that models LLM security as a lifecycle control problem spanning five layers: Data, Training, Model, Inference, and Application {% include references/cite.html key="silva2026securing" %}. For each layer, the framework identifies representative assets, threat classes, and defensive controls {% include references/cite.html key="silva2026securing" %}.

The threat taxonomy organises five classes across the layers {% include references/cite.html key="silva2026securing" %}:

| Class | Layer focus | Representative threats                             |
| ----- | ----------- | -------------------------------------------------- |
| T1    | Data        | Poisoning, contamination, backdoors                |
| T2    | Training    | Training pipeline compromise, dependency tampering |
| T3    | Model       | Artifact substitution, rollback, theft             |
| T4    | Inference   | Extraction, inversion, denial of service           |
| T5    | Application | Prompt injection, leakage, tool abuse              |

The Data layer covers collection, ingestion, curation, labeling, transformation, and metadata management, and is a primary target for poisoning and contamination because LLMs are highly sensitive to training signals {% include references/cite.html key="silva2026securing" %}. Controls at this layer include lineage tracking, dataset validation, source reputation management, reproducible preprocessing, and provenance attestations {% include references/cite.html key="silva2026securing" %}. The Application layer inherits the general theme with agentic detail, where retrieval-augmented and tool-calling systems add prompt injection, leakage, and tool abuse {% include references/cite.html key="silva2026securing" %}.

The framework is explicit that it is not a replacement for existing supply chain technologies but an organisation of them into a lifecycle-aware architecture {% include references/cite.html key="silva2026securing" %}.

## A Poisoning Scenario Across the Layers

The central argument of the framework is best demonstrated by the representative poisoning scenario it constructs, which shows how an attack propagates across all five layers {% include references/cite.html key="silva2026securing" %}.

Step 1 is a Data layer compromise. The attacker introduces poisoned samples containing hidden triggers into a publicly sourced dataset used for fine-tuning, designed to activate specific model behaviours when certain prompts appear during inference {% include references/cite.html key="silva2026securing" %}. Step 2 is Training layer propagation. The poisoned dataset is ingested into a training pipeline without sufficient validation, so the training process embeds the malicious behaviour into the model parameters {% include references/cite.html key="silva2026securing" %}.

Step 3 is Model layer persistence. The trained model is exported as a checkpoint and distributed through a model registry. Even if artifact signing ensures the artifact has not been modified after export, the embedded backdoor remains intact because the malicious logic was introduced earlier in the lifecycle {% include references/cite.html key="silva2026securing" %}. Step 4 is Inference layer exposure: the compromised model is deployed behind an inference API, behaves correctly under normal prompts, and triggers hidden behaviour on crafted inputs {% include references/cite.html key="silva2026securing" %}. Step 5 is Application layer exploitation, where the triggered behaviour leads to unsafe outputs, data leakage, or malicious tool invocation in retrieval-augmented or agent-based systems {% include references/cite.html key="silva2026securing" %}.

The point is direct: artifact integrity mechanisms alone cannot prevent lifecycle-origin attacks {% include references/cite.html key="silva2026securing" %}. A signature proves a checkpoint is untampered after export; it says nothing about whether the parameters were malicious before export.

## Hybrid Post-Quantum Signing as a Layer-Specific Control

Within this framework, hybrid post-quantum signing is positioned at the Model layer, at the artifact distribution stage. In a hybrid scheme, a model artifact is signed with both a classical digital signature, such as ECDSA, and a post-quantum signature, such as ML-DSA {% include references/cite.html key="silva2026securing" %}. Verification policies can then require both signatures or define phased acceptance rules depending on ecosystem maturity {% include references/cite.html key="silva2026securing" %}.

The design carries two advantages. It maintains compatibility with current verification tooling and trust stores, so the transition does not demand a fork of the whole ecosystem. And it introduces long-term resilience against future quantum attacks, which matters for long-lived artifacts, archived checkpoints, and models used in regulated or critical systems {% include references/cite.html key="silva2026securing" %}.

The authors frame hybrid signing as most operationally relevant to long-lived artifacts and regulated settings, not as a universal defense {% include references/cite.html key="silva2026securing" %}. The framework is equally explicit about the boundary of signing itself. It complements, but does not replace, the layered lifecycle controls, because signing addresses persistence and distribution, not the earlier poisoning, pipeline, and runtime threat classes.

## Moving from Presence to Execution-Bound Exploitability

Where the five-layer framework organises a lifecycle, the AIBOM-driven advisory paper attacks a different deficiency in the same space: advisory reasoning. Current SBOM and AIBOM tooling answers the presence question, whether a vulnerable component exists. The proposed framework redefines the question as whether a vulnerability is actually exploitable in a specific execution context {% include references/cite.html key="radanliev2026execution" %}.

The contribution extends Software Bills of Materials to AI-specific artifacts with an Artificial Intelligence Bill of Materials (AIBOM), which acknowledges that AI systems require extended scope to include models and datasets {% include references/cite.html key="radanliev2026execution" %}. The limitation the paper addresses is that AIBOM and SBOM workflows remain largely static, correlating declared components with vulnerability databases, and do not bind runtime context, execution telemetry, and advisory generation into one coherent lifecycle {% include references/cite.html key="radanliev2026execution" %}.

That gap produces three concrete failures the paper names: inflated remediation cycles, inconsistent exploitability claims, and limited reproducibility of security assessments {% include references/cite.html key="radanliev2026execution" %}.

## The Three Conditions and the Tri-Protocol Architecture

Exploitability is classified by evaluating three conditions simultaneously {% include references/cite.html key="radanliev2026execution" %}:

1. Whether the vulnerable component exists in the declared artifacts.
2. Activation. Whether the component is actually used during execution, from runtime telemetry.
3. Feasibility. Whether the environment allows the exploit to occur, from policy constraints.

Only when all three conditions are satisfied is a vulnerability classified as exploitable. This is the shift from presence-based to execution-bound reasoning {% include references/cite.html key="radanliev2026execution" %}.

The architecture is composed of three coordinated layers partnered with three protocols {% include references/cite.html key="radanliev2026execution" %}: deterministic environment and artifact capture through the Model Context Protocol (MCP); structured runtime observation and agent coordination through the Agent2Agent (A2A) protocol; and governance, signing, and traceability enforcement through the AGNTCY orchestration layer.

MCP facilitates pre-execution capture of analytic context, dependency metadata, and model artifacts {% include references/cite.html key="radanliev2026execution" %}. A2A enables secure delegation of actions between agents within bounded trust scopes {% include references/cite.html key="radanliev2026execution" %}. AGNTCY coordinates registration, governance, and policy anchoring, and with dynamic provenance from the other layers produces the cryptographically verifiable advisory records {% include references/cite.html key="radanliev2026execution" %}.

The pipeline proceeds as a six-stage process: deterministic environment capture through MCP, runtime telemetry collection through A2A, vulnerability correlation, execution-bound exploitability inference, CSAF-VEX advisory generation through AGNTCY, and reproducibility validation {% include references/cite.html key="radanliev2026execution" %}. The input has three classes: static artifact inventories including dependency lists, model hashes, prompt commit identifiers, tool endpoint definitions, and vector tables; and runtime telemetry from A2A sidecar agents such as system call events, dynamic library loads, outbound connection records, tool invocation traces, and observed privilege levels {% include references/cite.html key="radanliev2026execution" %}.

## What the Evaluation Measured

The evaluation used approximately 10,000 component entries across synthetic agentic AI workloads ranging from 50 to 5,000 components, incorporating OSV, GitHub Advisory, KEV, and EPSS datasets {% include references/cite.html key="radanliev2026execution" %}.

The headline results are bounded but specific. The combined AIBOM-and-telemetry pipeline achieved an F1-score of 0.93, with precision 0.96 and recall 0.92, and reduced false positives by up to 42 percent relative to static SBOM-CVE matching without runtime validation {% include references/cite.html key="radanliev2026execution" %}. Extending the bill of materials to AI-specific artifacts altered exploitability outcomes in 31 percent of AI-specific artifact cases {% include references/cite.html key="radanliev2026execution" %}.

The execution-bound reasoning also changed prioritisation. A hybrid risk tiering rule combining observed activation with EPSS probability and KEV presence reduced the set of high-priority alerts to a focused subset of approximately 18 percent of matched vulnerabilities, and an expert triage panel found the high-priority items materially more actionable than low-priority ones in 86 percent of sampled cases {% include references/cite.html key="radanliev2026execution" %}.

Two design disciplines keep these numbers honest. Every advisory record includes an MCP envelope hash, a deterministic justification built from feature conditions and activation evidence, and a signature anchored to the Sigstore transparency log, with justification text generated through deterministic templating rather than probabilistic natural language, preserving auditability {% include references/cite.html key="radanliev2026execution" %}. And the sealed execution envelope enables exact replay, where re-execution of the envelope reproduces the same advisory output, which makes the reported reproducibility property testable rather than asserted {% include references/cite.html key="radanliev2026execution" %}.

## Boundary Conditions Both Papers Acknowledge

Neither paper oversells its scope. The five-layer framework is paired with a prototype-oriented evaluation describing how controls can be instantiated in a reproducible pipeline and quantifying the practical overhead of hybrid signing, rather than a claim of production maturity {% include references/cite.html key="silva2026securing" %}. The advisory pipeline reports results under controlled experimental conditions on synthetic workloads, and its authors identify that supervised predictions are measured for consistency with deterministic rules rather than against an independent ground truth, explicitly avoiding conflating classification performance with unverifiable external labels {% include references/cite.html key="radanliev2026execution" %}.

Two real-world complications anchor the honest reading. First, poisoning illustrates why signing and presence are necessary but not sufficient, because the malicious logic can be embedded before any artifact exists {% include references/cite.html key="silva2026securing" %}. Second, runtime telemetry can itself be incomplete or noisy, which is precisely why the pipeline evaluates a deterministic rule-based baseline and a supervised variant, and why false-positive reduction rather than raw accuracy is the operational headline metric {% include references/cite.html key="radanliev2026execution" %}.

## Putting Lifecycle Controls and Execution-Bound Advisory into Production

Both frameworks are prototype-oriented, which makes them suitable for incremental adoption rather than wholesale replacement of existing artifact integrity, SLSA, and TUF controls {% include references/cite.html key="silva2026securing" %}{% include references/cite.html key="radanliev2026execution" %}.

For the five-layer lifecycle, map each layer to an enterprise control you already operate and fill the gap rather than creating a parallel programme {% include references/cite.html key="silva2026securing" %}. Data layer controls attach to dataset governance: lineage tracking, source reputation, validation and reproducible preprocessing, with provenance attestations recorded alongside the dataset rather than only on the derived model {% include references/cite.html key="silva2026securing" %}. Training layer controls map to pipeline hardening where in-toto can express which steps were performed, by whom, and in what order, scoped to the training workflow {% include references/cite.html key="silva2026securing" %}. Model layer controls are where hybrid post-quantum signing sits: sign model artifacts at distribution with both ECDSA and ML-DSA, and define a verification policy that requires both signatures or a phased acceptance rule depending on registry and verifier maturity {% include references/cite.html key="silva2026securing" %}. Prioritise long-lived artifacts, archived checkpoints, and models used in regulated or critical settings for hybrid signing first, since those are where quantum resilience and verifiability over time matter most, and keep the scheme compatible with current trust stores so the transition does not fork the ecosystem {% include references/cite.html key="silva2026securing" %}. Inference layer controls belong in the serving gateway with extraction and inversion monitoring, and Application layer controls belong in the retrieval and tool-calling perimeter where prompt injection, leakage, and tool abuse arise {% include references/cite.html key="silva2026securing" %}.

For execution-bound advisory, implement the six-stage pipeline as an evidence chain that can be audited, not as a black-box classifier {% include references/cite.html key="radanliev2026execution" %}. Capture deterministic environment and artifact context through MCP before execution, including dependency lists, model hashes, prompt commit identifiers, tool endpoint definitions, and vector tables; collect runtime telemetry through A2A sidecars such as system call events, dynamic library loads, outbound connections, tool invocation traces, and privilege levels; correlate against OSV, GitHub Advisory, KEV, and EPSS; apply execution-bound inference that requires existence, activation, and feasibility together before a vulnerability is classified as exploitable; generate CSAF-VEX advisories through AGNTCY; and retain the sealed execution envelope for replay {% include references/cite.html key="radanliev2026execution" %}. Every advisory should retain its MCP envelope hash, deterministic justification built from feature conditions and activation evidence, and Sigstore-anchored signature, with justification text produced by deterministic templating rather than probabilistic language generation so that audit does not depend on model output stability {% include references/cite.html key="radanliev2026execution" %}. The pipeline achieved F1 0.93 with 42 percent false-positive reduction over static matching in synthetic evaluation across approximately 10,000 component entries, altered outcomes in 31 percent of AI-specific artifact cases, and narrowed high-priority alerts to about 18 percent of matches with 86 percent expert-rated actionability, which are useful pilot targets but remain controlled-condition results to be remeasured on enterprise data {% include references/cite.html key="radanliev2026execution" %}. Start with AIBOM inventory for models and datasets, add execution telemetry for the highest-risk agentic tools first, and expand coverage as the 42 percent false-positive reduction and the 18 percent high-priority subset are validated against operational triage load.

## So What: The Lifecycle Extends the Foundations

This article completes the series argument by extending the three foundations to the hardest case.

The provenance foundation extends to hybrid post-quantum signing at the model distribution stage, so that long-lived artefacts stay verifiable against both current and future cryptographic risk {% include references/cite.html key="silva2026securing" %}. The reasoning foundation extends from SBOM graphs to AIBOM-driven execution-bound inference, so that exploitability reflects observed behaviour rather than declared presence {% include references/cite.html key="radanliev2026execution" %}. The continuous verification foundation extends from workload posture to running agentic behaviour, where activation and feasibility become first-class inputs alongside existence {% include references/cite.html key="radanliev2026execution" %}.

The unifying lesson of the three-part series is that supply chain security fails when a system is treated as a point-in-time artifact. Signing the artifact, inventorying its contents, and checking the running workload are each necessary. The LLM lifecycle makes the same lesson unmissable, because the threat enters at the data stage, persists through training, survives signing, and only becomes visible at inference {% include references/cite.html key="silva2026securing" %}.

## Conclusion

AI and agentic systems do not create a different kind of supply chain risk; they concentrate it. The five-layer framework shows that lifecycle-origin attacks such as poisoning traverse the data, training, model, inference, and application layers, and that artifact integrity alone cannot stop them, which motivates lifecycle-aware controls and hybrid post-quantum signing for long-lived model artifacts {% include references/cite.html key="silva2026securing" %}. The execution-bound pipeline shows that exploitability can be decided from runtime evidence, with measurable reductions in false positives and reproducible, signed advisory output {% include references/cite.html key="radanliev2026execution" %}.

Both works are early-stage frameworks with explicitly bounded evaluations, and both point the same direction: in software supply chain security, the artifact is not the unit of analysis. The lifecycle is.

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Technical Appendix" %}

### Evidence Base for This Article

This part draws on two peer-reviewed sources. The appendix records each source, the claims this article relies on, and the evidentiary caveats. Citation numerals refer to the reference list rendered under this post.

| No  | Source                                                                                                                                                      | Venue and type                                                                                            | What this article relies on                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Evidentiary caveat                                                                                                                                                                                                                                                          |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Silva and Duarte (2026), Securing LLM Software Supply Chains: A Layered Lifecycle Framework with Hybrid Post-Quantum Artifact Signing                       | 2026 IEEE 12th International Conference on Intelligent Data and Security (IDS), peer-reviewed proceedings | Five-layer lifecycle model (Data, Training, Model, Inference, Application); TI-T5 threat taxonomy; poisoning propagation scenario across layers; hybrid ECDSA + ML-DSA signing design and phased verification; limits of Sigstore, in-toto, SLSA, TUF for AI-specific threats; ML-DSA as NIST FIPS 204 standard                                                                                                                                                                                                                                                                                 | Framework is conceptual with a prototype-oriented evaluation; signing overhead figures are estimates rather than field measurements; ML-DSA and Dilithium terminology appears in source, treated here as the NIST-standardised scheme                                       |
| 2   | Radanliev, Santos, Maple, Shamsujjoha, and Atefi (2026), Execution-Bound Advisory Automation for Agentic AI: A Reproducible AIBOM-Driven CSAF-VEX Framework | Frontiers in Artificial Intelligence, peer-reviewed journal article                                       | Presence-to-execution-bound shift; three exploitability conditions (existence, activation, feasibility); MCP, A2A, AGNTCY tri-protocol architecture; six-stage pipeline; three input data classes; evaluation on approximately 10,000 component entries across synthetic 50-5,000 component workloads with F1 0.93, precision 0.96, recall 0.92, up to 42 percent false-positive reduction, 31 percent AI-specific artifact outcome changes; EPSS/KEV tiering with 18 percent high-priority subset and 86 percent expert-actionable rating; deterministic templating and sealed-envelope replay | Results are under controlled experimental conditions on synthetic workloads; supervised predictions are evaluated for consistency with deterministic rules, not against independent ground truth; figures are as reported and not independently verified outside the source |

### Boundary Conditions Applied in This Article

The five-layer framework is presented as a security model with a prototype evaluation, not as a certified production design {% include references/cite.html key="silva2026securing" %}. The advisory pipeline results do not extend beyond the controlled experimental conditions the source describes {% include references/cite.html key="radanliev2026execution" %}. Quantitative claims are reported as the authors state them and are not presented as independently verified findings.

### Status Notes

Both 2026 sources are peer-reviewed. ML-DSA references are treated as the NIST-standardised post-quantum signature scheme as described in the source. No quantitative claim in this article relies on a web page or an unverified secondary account.

### Discipline Note

This review grounds all analytical claims in the two listed sources and labels the character of each claim, including the evaluation boundaries each author states. It does not present either framework as a settled production capability, and it does not claim any result beyond what the underlying source reports.

</details>
