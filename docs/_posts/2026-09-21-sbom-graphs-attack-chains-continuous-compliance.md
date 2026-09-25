---
layout: post
last_modified_at: 2026-09-21
title: "SBOM Graphs for Attack Chain Prediction and Workload Identity for Continuous Compliance"
author: Zenith Law
description: "SBOMs are only inventories; their value depends on how they are read. A CycloneDX graph pipeline that predicts cascaded attack chains, and a zero-trust architecture that enforces vulnerability compliance after deployment through workload identity, examined from three peer-reviewed sources."
permalink: /sbom-graphs-attack-chains-continuous-compliance
intro: "A Software Bill of Materials is an inventory, and an inventory only becomes security when it is continuously evaluated. This article examines two complementary advances that follow directly from the signing foundations covered previously. The first treats vulnerability-enriched SBOMs as heterogeneous graphs so that cascaded multi-vulnerability attack chains can be predicted rather than assumed independent. The second closes the gap between pipeline-time checks and running workloads: a zero-trust architecture that continuously verifies vulnerability compliance after deployment, assigns each workload an identity, and isolates workloads that fall below a minimum posture. The evidence base is three peer-reviewed works from dependability and software engineering venues. It is the second in a three-article series on software supply chain security, companion to articles on attack vectors and keyless signing, and on lifecycle security for LLM and agentic systems."
image: /assets/images/sbom-graphs-attack-chains-continuous-compliance.png
hero:
  image: /assets/images/sbom-graphs-attack-chains-continuous-compliance.png
related_posts:
  - title: "Software Supply Chain Attack Vectors and How Keyless Signing Counters Them"
    url: /software-supply-chain-attack-vectors-keyless-signing
  - title: "Axios NPM Supply Chain Compromise: Ten Lessons on Provenance, Trust, and Resilience"
    url: /axios-npm-supply-chain-compromise-2026-ten-lessons-provenance-trust-resilience
  - title: "Deadlock and Resource Contention: Operating Systems Theory Applied to Supply Chains, Cloud Platforms, and LLM Systems"
    url: /deadlock-resource-contention-operating-systems-supply-chains-cloud-llm
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - baird2026towards
  - gama2024supporting
  - gama2026leveraging
keywords: "SBOM, software bill of materials, software composition analysis, attack chains, heterogeneous graph, HGAT, link prediction, zero trust, workload attestation, SPIRE, OWASP Dependency Track, continuous compliance, CVE, CycloneDX, incident response, DevSecOps"
catchwords: "SBOM, attack chains, SBOM graphs, continuous compliance, zero trust, SPIRE, Dependency Track, vulnerability management, workload isolation"
categories:
  - Cybersecurity
  - Software Engineering
tags:
  - SBOM
  - zero trust
  - vulnerability management
  - software supply chain
  - workload attestation
---

## Introduction

Signing proves provenance but not safety, and the dependency graph is the structural amplifier of risk as shown in the companion article on attack vectors and keyless signing. This article moves from who produced the software to what is in it, and to how compliance can be enforced after deployment. The two problems sound different but share one root cause: static, point-in-time checks are misaligned with how software behaves.

Most current supply chain analysis treats each CVE as an independent record to be scored and triaged {% include references/cite.html key="baird2026towards" %}. Yet real-world incidents show that cascaded attack chains, where multiple vulnerabilities interact across components, are a recurring and more dangerous failure mode {% include references/cite.html key="baird2026towards" %}. In parallel, continuous compliance processes typically run vulnerability assessment only inside the CI/CD pipeline, so they stop protecting the workload the moment it is deployed and a new vulnerability is disclosed {% include references/cite.html key="gama2024supporting" %}.

This article examines two peer-reviewed answers to those two problems: an SBOM-graph learning pipeline for attack chain prediction, and a zero-trust architecture that provisions automated workload identities and isolates workloads that fail a minimum vulnerability posture.

This article is educational and not legal advice.

## The Shortcoming of Single-CVE Thinking

The starting premise of the SBOM graph work is that per-CVE analysis is useful for triage but fundamentally misaligned with how attacks actually happen {% include references/cite.html key="baird2026towards" %}. Static scanners such as Snyk and Trivy are effective at enumerating vulnerable components, but they report per-component CVE lists and do not surface cross-component chains {% include references/cite.html key="baird2026towards" %}. A vulnerability that looks low severity in isolation can become critical when composed through the dependency structure.

The motivating example is ProxyLogon, where four Microsoft Exchange vulnerabilities were chained into a pre-authentication path that led to persistent remote control of enterprise email servers {% include references/cite.html key="baird2026towards" %}. Each of the four CVEs was individually known; what mattered was their interaction. The paper draws the consequence explicitly: shift from a score-each-CVE philosophy to one that learns interaction patterns constrained by the dependency graph {% include references/cite.html key="baird2026towards" %}.

The empirical context supports this concern. SBOM generation and maintenance remain difficult in realistic environments, and the choice of generation and analysis tool can materially change downstream vulnerability findings, increasing both false positives and false negatives depending on ecosystem and configuration {% include references/cite.html key="baird2026towards" %}. So the pipeline feeding any higher-order reasoning is noisy and variable before reasoning even begins.

## SBOMs as Heterogeneous Graphs

The proposed alternative represents a vulnerability-enriched CycloneDX SBOM as a heterogeneous graph {% include references/cite.html key="baird2026towards" %}. Three node types carry the structure. Component nodes are the software packages or SBOM dependencies. CVE nodes are known vulnerabilities documented in the OSV database entries. CWE nodes are weakness types from the Common Weakness Enumeration database. Typed edges connect them: DEPENDS_ON between components from SBOM dependency relations, HAS_VULNERABILITY from components to CVEs from the scanner, and HAS_CWE from CVEs to CWEs, which in the current prototype is supported by the schema but not yet implemented {% include references/cite.html key="baird2026towards" %}.

The pipeline builds the SBOM in CycloneDX format using Syft and enriches components with vulnerability information using Grype, backed by the Open Source Vulnerabilities (OSV) database {% include references/cite.html key="baird2026towards" %}. Node features stay lightweight and interpretable: component nodes carry CVSS aggregates, direct-versus-transitive dependency metadata, degree statistics, and license indicators; CVE nodes encode severity score and temporal metadata {% include references/cite.html key="baird2026towards" %}.

The point of the graph is not decoration. The work is explicitly framed as a new research direction: supply chain security analysis should treat scanner outputs as a dependency-constrained evidence graph rather than a flat list of vulnerabilities {% include references/cite.html key="baird2026towards" %}.

## Learning Over the Graph: Feasibility and Evidence That Structure Matters

The graph representation is tested through two modular learning stages {% include references/cite.html key="baird2026towards" %}.

The first stage is a feasibility check. A two-layer Heterogeneous Graph Attention Network (HGAT), with two attention heads, hidden dimension 64, and dropout 0.2, learns to classify whether a component is associated with at least one known CVE, the has-any-CVE label {% include references/cite.html key="baird2026towards" %}. This is deliberately not a vulnerability-discovery task. It is a mechanism to test whether the dependency structure carries a learnable signal beyond local node metadata, through a targeted ablation {% include references/cite.html key="baird2026towards" %}.

The results, on 200 real-world CycloneDX SBOMs for Python projects from the public Wild SBOMs dataset with a 70-15-15 train, validation, and test split, are {% include references/cite.html key="baird2026towards" %}:

| Setting                       | Accuracy | Precision | Recall | F1-score |
| ----------------------------- | -------- | --------- | ------ | -------- |
| HGAT, full graph              | 0.9103   | 0.8084    | 0.6826 | 0.7402   |
| HGAT, dependency edges masked | 0.8128   | 0.0000    | 0.0000 | –        |

The ablation zeroes the dependency edges at inference time without retraining. Recall collapses to zero, meaning the model stops finding any vulnerable component when the dependency structure is removed {% include references/cite.html key="baird2026towards" %}. The paper notes that the still-high accuracy under ablation is consistent with class imbalance, where predicting the majority class scores well on accuracy but badly on recall and F1, so recall and F1 are the informative indicators {% include references/cite.html key="baird2026towards" %}. The signal is relational: the graph structure is what carries the vulnerability information.

## Predicting Attack Chains as Link Prediction

Cascaded chains are scarcer than isolated CVEs, so training a model to predict full multi-step chains directly is data-limited. The work reframes cascade discovery as link prediction over CVE pairs {% include references/cite.html key="baird2026towards" %}. Given two CVEs, the task is to estimate whether they are plausibly co-exploited in a chained scenario. High-scoring links are then composed into multi-step candidate chains for analyst triage.

The training set is a seed corpus of 35 documented chains, 27 from vulnerability disclosures and 8 from incident reports, with chain lengths from 2 to 4 CVEs (median 2, mean 2.51) {% include references/cite.html key="baird2026towards" %}. Within-chain CVE pairs are positive examples; negatives are sampled at a 2:1 ratio from pairs not observed in the same chain, a deliberate compromise between class balance and aggressive oversampling {% include references/cite.html key="baird2026towards" %}.

The predictor is a lightweight five-layer MLP consuming a 22-dimensional feature vector per CVE pair: 9 per-CVE features from National Vulnerability Database (NVD) metadata, plus 4 interaction features such as CVSS difference, CVSS product, year gap, and a both-exploited indicator {% include references/cite.html key="baird2026towards" %}. The architecture is 22-64-32-16-1 neurons with dropout 0.3, Adam at learning rate 10^{-3}, binary cross-entropy loss, up to 50 epochs, and early stopping on validation ROC-AUC {% include references/cite.html key="baird2026towards" %}.

The cascade predictor achieves a ROC-AUC of 0.93 on the seed set {% include references/cite.html key="baird2026towards" %}. The authors apply their own caveat: ROC-AUC can be misleading under class imbalance, and the result demonstrates the model can distinguish metadata patterns of co-exploited pairs from random pairs, not that it can predict novel undocumented chains. Pair-level splitting, where the same CVE appears in train and test through different pairings, can inflate apparent generalization, which is why chain-level and temporal splits are planned next {% include references/cite.html key="baird2026towards" %}.

The honest boundary matters. This is a feasibility study and a proposed research direction, with the two models operating on disjoint CVE populations and not yet connected end to end {% include references/cite.html key="baird2026towards" %}. What it establishes is that the dependency structure is learnable, and that scarcer chain documentation is enough to train a usable co-exploitation prior.

## The Compliance Gap After Deployment

The second problem is enforcement timing. Continuous compliance processes often perform vulnerability assessment to prevent compliance breaches during the CI/CD pipeline, but they do not extend beyond the pipeline and so ignore incident response when dynamic aspects change, such as a newly disclosed vulnerability {% include references/cite.html key="gama2024supporting" %}.

The two Gama papers address this with the same architectural core, refined across two years. The 2024 paper builds on SPIRE, a selective identity provider, and integrates response to compliance violations monitored by OWASP Dependency Track, showing the approach adds no significant latency and does not hinder operational or development efforts {% include references/cite.html key="gama2024supporting" %}. The 2026 paper extends the same design with risk indicators and a grace period mechanism, and evaluates performance at a scale that maps to a production recommendation {% include references/cite.html key="gama2026leveraging" %}.

The motivation is grounded in the same incident record as Part 1: a 742 percent increase in supply chain attacks between 2019 and 2021, and over 245,000 malicious open source packages discovered in 2022 alone, more than doubling the total of all previous years combined {% include references/cite.html key="gama2026leveraging" %}.

## Zero Trust as Post-Deployment Enforcement

The core design principle is zero trust: never trust, always verify {% include references/cite.html key="gama2026leveraging" %}. The idea directly opposes the assumption that a product is trustworthy because it left some trusted boundary {% include references/cite.html key="gama2026leveraging" %}.

The architecture gives every workload an identity through SPIRE workload attestation, and continuously checks that the workload conforms to a minimum vulnerability posture {% include references/cite.html key="gama2026leveraging" %}. A custom plugin reacts to compliance violations driven by dynamic aspects exposed by OWASP Dependency Track, which monitors software components and their dependencies for vulnerabilities and provides a REST API to automate its use {% include references/cite.html key="gama2026leveraging" %}. When a workload falls below the minimum posture, the workload is isolated. This isolation presents the fundamental trade-off this line of work is explicit about: exploitation prevention versus application availability, which matters most for critical use cases {% include references/cite.html key="gama2024supporting" %}.

The post-deployment focus is the differentiator. Intervention is not a one-time pipeline gate; it is enacted when a new vulnerability appears after the software is running, which is exactly when per-pipeline compliance becomes silent {% include references/cite.html key="gama2026leveraging" %}.

## Risk Indicators and Grace Periods

The 2026 refinement makes the security-availability trade-off configurable rather than binary. The approach introduces risk indicators derived from vulnerability scores and workload criticality, and a grace period mechanism that defers enforcement of newly identified vulnerabilities based on workload criticality {% include references/cite.html key="gama2026leveraging" %}.

The gradient works as follows. A newly discovered CVE triggers Dependency Track analysis through the REST API {% include references/cite.html key="gama2026leveraging" %}. Instead of isolating every affected workload immediately, the plugin grants a grace period before enforcement, with rules driven by CVSS and EPSS-style scoring and by how critical the workload is {% include references/cite.html key="gama2026leveraging" %}. Non-critical workloads can keep running through the grace period, which supports availability without compromising long-term security, because enforcement still arrives once the period expires {% include references/cite.html key="gama2026leveraging" %}.

The design is explicit that this is a judgement with a cost. Applying the same grace period rules to all workloads is not optimal, so criticality is a first-class input rather than an afterthought {% include references/cite.html key="gama2026leveraging" %}. This mirrors the general principle of the series: enforce not uniformly, but proportionally to what is being protected.

## Performance and Operational Feasibility

The enforcement machinery is only usable if it does not break the systems it protects. The 2026 evaluation measured both resource use and latency {% include references/cite.html key="gama2026leveraging" %}.

Dependency Track, in a production compliance environment, has a recommended allocation of 16 GiB of memory and 4 CPU cores {% include references/cite.html key="gama2026leveraging" %}. The evaluation confirmed that added resource usage reliably remains within that envelope, so the integration does not force organisations to double their monitoring footprint {% include references/cite.html key="gama2026leveraging" %}.

Latency is reported against the attestation cadence. The plugin adds less than 6 seconds of latency to the attestation process, which is insignificant given the default attestation frequency of approximately once every 30 minutes, or twice per hour {% include references/cite.html key="gama2026leveraging" %}. Checking for new vulnerabilities frequently is a recommended practice, and at this cadence the added six seconds is a rounding error relative to the interval {% include references/cite.html key="gama2026leveraging" %}.

The 2024 paper reached the same conclusion with the earlier design: the only overhead imposed by integrating Dependency Track is the latency of REST API communications during the attestation process, which the evaluation found not to be significant {% include references/cite.html key="gama2024supporting" %}.

## Implementing Graph-Aware Analysis and Continuous Enforcement in Practice

Neither framework requires a green-field rebuild if it is introduced as an evidence layer rather than a gate replacement. The research prototypes are bounded in ways that actually help to scope a production pilot {% include references/cite.html key="baird2026towards" %}{% include references/cite.html key="gama2026leveraging" %}.

For the graph pipeline, start where the evidence is strongest. Generate CycloneDX SBOMs in CI with Syft and enrich them with Grype against OSV, then normalise the output to the heterogeneous schema of component, CVE, and CWE nodes with typed edges for DEPENDS_ON and HAS_VULNERABILITY, leaving HAS_CWE as a schema extension until your data supports it {% include references/cite.html key="baird2026towards" %}. Persist the graph in an existing graph or search store alongside the flat SBOM so current scanners such as Snyk and Trivy continue to run while the graph is used for secondary reasoning {% include references/cite.html key="baird2026towards" %}. Pilot on Python services first because the 200-SBOM evaluation was Python-only from the Wild SBOMs dataset, and explicitly track where tool choice changes downstream findings by comparing two generators and two scanners on the same build before you trust any downstream classifier {% include references/cite.html key="baird2026towards" %}. The has-any-CVE HGAT with two layers, two heads, hidden dimension 64 and dropout 0.2 is a diagnostic probe, not a detector {% include references/cite.html key="baird2026towards" %}. The source paper uses edge-masking only as a one-off feasibility ablation on its own trained model and a 200-SBOM Python-only dataset, with edges zeroed at inference without retraining, not as a general operational technique {% include references/cite.html key="baird2026towards" %}. As an author-suggested analogy, not a validated procedure endorsed by the source, a team could run a similar sanity check on its own graph-triage pipeline, for example comparing rankings with and without dependency edges, to sense-check whether the graph is adding signal. That heuristic is untested beyond the research context and should not be mistaken for an established method. For chain prediction, treat the 22-feature MLP with ROC-AUC 0.93 as a co-exploitation prior over CVE pairs with 2:1 negative sampling, and require chain-level and temporal splits before any production ranking, since pair-level splitting can inflate generalisation as the authors themselves flag {% include references/cite.html key="baird2026towards" %}.

For continuous posture enforcement, reuse the SPIRE and Dependency Track architecture rather than inventing new attestation. Provision every workload an identity through SPIRE workload attestation and drive the posture check from Dependency Track monitoring of software components and their dependencies via its REST API {% include references/cite.html key="gama2024supporting" %}{% include references/cite.html key="gama2026leveraging" %}. Isolate workloads that fall below the minimum posture and treat the fundamental trade-off as availability versus prevention, which is most sensitive for critical workloads {% include references/cite.html key="gama2024supporting" %}. Configure grace periods and risk indicators as policy, not as code constants, with rules driven by CVSS, EPSS-style probability, and workload criticality so that critical workloads receive a shorter or zero grace period and non-critical workloads can keep running boundedly through the window {% include references/cite.html key="gama2026leveraging" %}. The 2026 evaluation used a 16 GiB and 4 vCPU envelope for Dependency Track and added less than six seconds to an attestation that runs twice per hour, which is a practical baseline for capacity planning rather than a guarantee for other stacks {% include references/cite.html key="gama2026leveraging" %}. Previous work found the only overhead from the integration is REST API latency during attestation, which supports placing this in existing re-attestation intervals rather than adding a new control loop {% include references/cite.html key="gama2024supporting" %}.

A pragmatic rollout sequence is to enforce graph-aware triage in advisory review first, then enforce continuous posture in non-production with log-backed audit of isolation decisions, and only then move the same policy to production admission with the grace period and criticality matrix as the tuning interface.

## So What: Two Frameworks and What They Enable Next

This article establishes two complementary layers of what SBOMs can do once they stop being static PDFs.

The graph layer changes how SBOMs are read. Instead of a flat list of independent CVEs, the SBOM becomes a heterogeneous graph in which dependency structure is the carrier of risk, and cascaded chains become learnable rather than accidental {% include references/cite.html key="baird2026towards" %}. The ablation result, where removing dependency edges collapses recall to zero, is the cleanest statement of that thesis {% include references/cite.html key="baird2026towards" %}.

The enforcement layer changes when compliance happens. Identity-provisioned workloads are continuously re-verified after deployment, with isolation as the backstop and grace periods and risk indicators as the tuning knobs {% include references/cite.html key="gama2026leveraging" %}. The measurable cost, less than six seconds at a twice-per-hour cadence, makes the enforcement posture operationally defensible {% include references/cite.html key="gama2026leveraging" %}.

Together with the signing foundations covered previously, the picture is now three capabilities: cryptographic provenance for artifacts, graph-aware reasoning over what the artifacts contain, and continuous identity-based verification of where they run. The companion article on LLM and agentic systems examines what happens to all three when the artifact is a model rather than a package.

## Conclusion

Static checks fail in two specific ways, and this part documented a published answer to each. Single-CVE scoring misses cascaded attack chains that the dependency graph makes possible, so the evidence graph approach makes those chains predictable {% include references/cite.html key="baird2026towards" %}. Pipeline-time compliance stops at deployment, so the zero-trust architecture moves verification onto running workloads, isolates failures of posture, and prices the trade-off between availability and security with grace periods and risk scoring {% include references/cite.html key="gama2026leveraging" %}.

Both answers are early-stage: the graph pipeline is explicit about being a feasibility study, and the enforcement design is scoped to the trade-offs its authors name. But both move the field in the same direction, away from inventories and gates and toward continuous, structured, and relational reasoning about the supply chain.

## Frequently Asked Questions

### Why does single-CVE thinking fail to capture real supply chain risk?

The evidence graph view treats dependency relationships as the carrier of risk, so a single vulnerability is understood through the attack chains it can contribute to. The ProxyLogon chain in the Baird and Moin study shows how four Microsoft Exchange vulnerabilities were chained into a pre-authentication path that cascaded across components {% include references/cite.html key="baird2026towards" %}. The ablation result makes the point measurable: removing the dependency edges collapses recall on has-any-CVE prediction to zero, which means the structure of the graph is doing the predictive work, not the individual component inventories {% include references/cite.html key="baird2026towards" %}.

### What is the difference between an SBOM and an SBOM graph?

An SBOM is a flat nested inventory of components with identity and version data. An SBOM graph converts that inventory into a heterogeneous graph in which components, dependencies, and vulnerabilities are typed nodes that can carry multiple relationship kinds. The graph formulation is what allows attack chains to be predicted as link prediction over the heterogeneous graph, which is the concrete contribution of the Baird and Moin approach {% include references/cite.html key="baird2026towards" %}.

### How does continuous compliance differ from pipeline-time compliance?

Pipeline-time compliance checks an artifact once at build and then stops, which leaves the deployed workload inside the gap the moment the runtime state drifts. Continuous compliance places the identity-based verification onto the running workload itself, using SPIRE to issue and refresh workload identity so that posture can be rechecked after deployment {% include references/cite.html key="gama2024supporting" %}. The Gama 2026 extension adds grace periods and risk indicators so that a non-conforming workload is given a bounded time window or a criticality-based tolerance instead of an immediate binary decision {% include references/cite.html key="gama2026leveraging" %}.

### Can continuous compliance be operated without unacceptable latency?

The measured enforcement architecture re-verified identity and rechecked posture on a twice-per-hour cadence within a dependency check pipeline running on a 16 GiB and 4 vCPU envelope, with per-attestation latency under six seconds {% include references/cite.html key="gama2026leveraging" %}. The figures describe the authors experimental context, so the claim here is bounded: the demonstrated envelope is operationally plausible, not a guarantee for other identity providers or monitoring tools.

### What role do risk indicators play in a zero-trust compliance policy?

Risk indicators stop the policy from being a single blunt switch. A never-trust-always-verify architecture is still a decision procedure, and grace periods plus criticality scoring turn that procedure into a graded response rather than an all-or-nothing block {% include references/cite.html key="gama2026leveraging" %}. This is what keeps continuous compliance deployable in production, because it prices the trade-off between availability and security instead of pretending it does not exist.

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Technical Appendix" %}

### Evidence Base for This Article

This part draws on three peer-reviewed sources. The appendix records each source, the claims this article relies on from it, and the evidentiary caveats. Citation numerals refer to the reference list rendered under this post.

| No  | Source                                                                                                                                       | Venue and type                                                               | What this article relies on                                                                                                                                                                                                                                                                                                                                                                                                                    | Evidentiary caveat                                                                                                                                                                                               |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Baird and Moin (2026), Towards Predicting Multi-Vulnerability Attack Chains in Software Supply Chains from Software Bill of Materials Graphs | ACM FSE Companion, peer-reviewed proceedings paper                           | Single-CVE thinking critique; ProxyLogon motivating example; CycloneDX heterogeneous graph schema; Syft and Grype pipeline; HGAT design and hyperparameters; the 200-SBOM Wild SBOMs evaluation with the full-graph versus masked-ablation table; MLP link-prediction design, 22-feature vector, 2:1 negative sampling, seed set of 35 chains; 0.93 ROC-AUC result; explicit limitations including pair-level splitting and imbalanced ROC-AUC | The paper states this is a research direction and a feasibility study; the two models are not yet connected end to end and the prototype is work in progress; results are preliminary by the authors own account |
| 2   | Gama, Brito, Martin, and Fetzer (2024), Supporting Continuous Vulnerability Compliance through Automated Identity Provisioning               | ACM LADC, peer-reviewed dependability proceedings                            | Post-pipeline compliance gap; zero-trust isolation of non-conforming workloads; SPIRE-based identity provisioning; Dependency Track integration; no-significant-latency finding                                                                                                                                                                                                                                                                | Evaluation is scoped to the described SPIRE environment and its REST API latency during attestation; figures are not restated here beyond the qualitative no-significant-latency claim                           |
| 3   | Gama, Fuch, Brito, Martin, and Fetzer (2026), Leveraging Zero Trust and Risk Indicators to Support Continuous Vulnerability Compliance       | Journal of Internet Services and Applications, peer-reviewed journal article | 742 percent attack increase 2019 to 2021 and 245,000 malicious packages in 2022 (as reported by the authors from Sonatype); zero-trust never-trust-always-verify framing; grace period and risk-indicator mechanism with criticality; 16 GiB and 4 vCPU Dependency Track envelope; less-than-6-second latency at twice-per-hour attestation                                                                                                    | Attack statistics are reported from Sonatype analyses cited by the authors and are not independently verified here; resource and latency figures describe the authors experimental evaluation context            |

### Boundary Conditions Applied in This Article

The graph results are scoped to CycloneDX-format SBOMs for Python projects from the Wild SBOMs dataset and to the has-any-CVE classification task; this article does not extend them to other ecosystems or discovery tasks {% include references/cite.html key="baird2026towards" %}. The enforcement figures are scoped to the SPIRE and Dependency Track architecture described by the authors; this article does not claim the latency or resource outcomes transfer to other identity providers or monitoring tools {% include references/cite.html key="gama2024supporting" %}.

### Status Notes

Attack statistic figures in the enforcement discussion originate in Sonatype reports cited by the Gama 2026 paper, and this article treats them as reported figures rather than independently verified data. All quantitative claims in the graph section are traceable to the Baird and Moin tables and text above, and none relies on an unverified secondary account.

### Discipline Note

This review grounds all analytical claims in the listed sources, labels the character of each claim including which figures are reported from third parties, and does not present any result as settled production capability beyond what the authors themselves claim.

</details>
