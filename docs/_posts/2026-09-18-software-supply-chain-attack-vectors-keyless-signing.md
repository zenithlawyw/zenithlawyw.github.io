---
layout: post
last_modified_at: 2026-09-18
title: "Software Supply Chain Attack Vectors and How Keyless Signing Counters Them"
author: Zenith Law
description: "How attackers reach software through its supply chain, and how keyless signing counters those vectors in practice. A US National Science Foundation research agenda maps three attack vectors, and a large-scale transparency log shows how Sigstore replaces persistent keys with ephemeral, OIDC-bound certificates."
permalink: /software-supply-chain-attack-vectors-keyless-signing
intro: "Software is now assembled from layers of reusable abstractions, and each layer is an attack surface. This article maps the three major attack vectors identified in a US National Science Foundation research agenda built from practitioner summits, then examines the signing foundations that counter them through the design and real-world operation of Sigstore, a keyless signing system that replaced persistent signing keys with ephemeral, OIDC-bound certificates and a public transparency log. The evidence base is two peer-reviewed works: a journal research agenda and a security conference paper reporting measurements from a live signing ecosystem. It is the first in a three-article series on software supply chain security, with companion articles covering SBOM graphs and continuous compliance, and lifecycle security for LLM and agentic systems."
image: /assets/images/software-supply-chain-attack-vectors-keyless-signing.png
hero:
  image: /assets/images/software-supply-chain-attack-vectors-keyless-signing.png
related_posts:
  - title: "Axios NPM Supply Chain Compromise: Ten Lessons on Provenance, Trust, and Resilience"
    url: /axios-npm-supply-chain-compromise-2026-ten-lessons-provenance-trust-resilience
  - title: "Deadlock and Resource Contention: Operating Systems Theory Applied to Supply Chains, Cloud Platforms, and LLM Systems"
    url: /deadlock-resource-contention-operating-systems-supply-chains-cloud-llm
  - title: "Stablecoin Custody, Settlement, and the Transaction Lifecycle: An Evidence-Grounded Review"
    url: /stablecoin-custody-settlement-transaction-lifecycle-evidence-review
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - williams2025research
  - newman2022sigstore
keywords: "software supply chain security, software supply chain attack vectors, SBOM, signing foundations, keyless signing, Sigstore, Rekor, Fulcio, OIDC, transparency log, code signing, dependency confusion, open source security, SolarWinds, log4j, xz utils, S3C2"
catchwords: "software supply chain, attack vectors, keyless signing, Sigstore, transparency log, SBOM, OIDC, dependency injection, build infrastructure, social engineering"
categories:
  - Cybersecurity
  - Software Engineering
tags:
  - software supply chain
  - code signing
  - transparency log
  - open source security
  - SBOM
---

## Introduction

The modern world relies on software built from layers of reusable abstractions: libraries, frameworks, cloud infrastructure, and AI modules. That assembly chain is now a deliberate attack surface. One research agenda reports that an analysis of 1,067 commercial code bases across 17 industries found open source software in 96 percent of them, with open source comprising 77 percent of the code {% include references/cite.html key="williams2025research" %}. The same work records that Sonatype logged 512,847 malicious open source packages in 2024, a 156 percent year-over-year increase {% include references/cite.html key="williams2025research" %}. Well-known incidents such as SolarWinds, log4j, and xz utils affected thousands of customers and hundreds of businesses and government agencies worldwide {% include references/cite.html key="williams2025research" %}.

This article answers two questions. First, how do attackers reach software through its supply chain? Second, what signing foundations exist to counter those vectors at scale? It is grounded in two peer-reviewed works: a journal article setting out supply chain attack vectors and a research agenda assembled from practitioner outreach {% include references/cite.html key="williams2025research" %}, and a security conference paper reporting the design and operational measurements of Sigstore, a keyless signing system {% include references/cite.html key="newman2022sigstore" %}.

This article is educational and not legal advice.

## The Three Attack Vectors

The research agenda identifies three major attack vectors, each targeting a different part of the software supply chain {% include references/cite.html key="williams2025research" %}.

The first is injection through code dependencies. Attackers place vulnerabilities or malware into open source and third-party components, containers, and AI models. log4j began as an accidentally injected vulnerability, then became an exploited one once disclosed, with attackers executing arbitrary code, stealing data, installing ransomware, and taking control of networks {% include references/cite.html key="williams2025research" %}. Malicious components are also injected deliberately into npm, PyPI, and Maven ecosystems. A widely cited example is the "protestware" modification of the npm package node-ipc in 2022, where malicious code was intended to overwrite arbitrary files based on the geographic location of the user IP address {% include references/cite.html key="williams2025research" %}.

The second vector is build infrastructure. Attackers infect the tooling and automation that convert source code into a production application. With SolarWinds, the build process was compromised so that malicious code was injected into the end product and then signed and distributed to commercial companies and critical US government organizations {% include references/cite.html key="williams2025research" %}.

The third vector targets humans. Developers and maintainers are described by the agenda as the "weak link" in the supply chain, accessed through social engineering {% include references/cite.html key="williams2025research" %}. The research agenda also flags the future risk of advanced phishing and spear-phishing using large language models {% include references/cite.html key="williams2025research" %}.

## How the Research Agenda Was Built

The attack-vector account is not an unsupported narrative. It comes from research grounded in deliberate practitioner outreach and from review of research efforts {% include references/cite.html key="williams2025research" %}.

The agenda emerged from the US National Science Foundation-funded Secure Software Supply Chain Center (S3C2), founded in 2022, with researchers at North Carolina State University, Carnegie Mellon University, and the University of Maryland, and a close collaborator at Paderborn University {% include references/cite.html key="williams2025research" %}. A central engagement mechanism is the Secure Software Supply Chain Summit, run three times annually under the Chatham House Rule, which allows participants to use the information discussed but not the identity or affiliation of the speaker {% include references/cite.html key="williams2025research" %}. Between 2021 and 2024 the program conducted eight in-person and three virtual summits, involving 131 practitioners from 42 industrial organizations and 15 US government agencies {% include references/cite.html key="williams2025research" %}. Throughout the article, the knowledge obtained from these summits is referenced as Practitioner Challenges {% include references/cite.html key="williams2025research" %}.

This matters for how the vector analysis should be read. The attack vector framework is grounded in what practitioners actually report facing, not only in incident retrospectives. When the agenda states a particular challenge, the statement carries the weight of that outreach base.

## Dependencies at Scale and the Dilemma They Create

Modern products commonly have tens to hundreds of direct and transitive code dependencies, each of which can carry vulnerabilities, and the dependency graph crosses platform boundaries, for example linking Maven and PyPI packages to C and C++ code {% include references/cite.html key="williams2025research" %}. Remediation is labor intensive and requires dedicated personnel {% include references/cite.html key="williams2025research" %}.

The challenge has a structural element. The agenda records that malicious dependencies have become increasingly common through typo-squatting, dependency confusion, and project take-over attacks {% include references/cite.html key="williams2025research" %}. Each of these exploits the gap between what a developer believes they are importing and what they actually receive. Typo-squatting plays on misspelled package names. Dependency confusion exploits private package names that are also published publicly. Project take-over transfers maintenance of a popular package to a malicious actor.

This tension between the benefits of reuse, which are real and documented, and the risk carried in every reused component, frames the two defenses examined across this series: knowing what is in your software, which the research agenda addresses through SBOM practice, and cryptographic trust in who produced it, which this part examines through signing foundations {% include references/cite.html key="williams2025research" %}.

## Why Signing Is the Integrity Backstop

If a component can be replaced or tampered with at any stage, then a mechanism is needed to bind a software artifact to a verifiable identity. That mechanism is signing. The research agenda integrates signing into its account of security frameworks and technologies along with SLSA provenance levels and SBOM practice {% include references/cite.html key="williams2025research" %}.

The historical obstacle to signing was not technical capability but usability and key management. Traditional code signing requires signers to create, store, protect, and rotate a long-lived private key. The consequence is visible in adoption figures. A 2020 analysis of RubyGems found that only 1.6 percent of the latest package versions were signed, and a 2016 analysis of PyPI found that only 4 percent of projects even listed a signature and only 0.07 percent of users downloaded those signatures for verification {% include references/cite.html key="newman2022sigstore" %}.

Sigstore was designed to remove that barrier. Its stated motivation is to bring the security guarantees of signing to a wide user base by eliminating the key management burden that caused earlier systems to fail adoption {% include references/cite.html key="newman2022sigstore" %}.

## The Sigstore Design: Keyless Signing with a Transparency Log

Sigstore combines three building blocks adapted from web public key infrastructure and transparency systems: short-lived identity certificates, a public append-only transparency log, and OIDC-based federation {% include references/cite.html key="newman2022sigstore" %}.

The signing flow works as follows {% include references/cite.html key="newman2022sigstore" %}. A signer authenticates to an OIDC identity provider, for example a GitHub account or GitHub Actions workload. The client generates an ephemeral signing key pair. Fulcio, which functions as a certificate authority, issues a short-lived certificate that binds the public key to the OIDC identity, typically an email or a workload identity. The signer signs the artifact with the ephemeral key, then submits the signature and certificate to Rekor, a transparency log, which appends an entry and returns a signed timestamp. Because the key is ephemeral, there is no persistent private key for an attacker to steal, and the certificate lifetime is decoupled from the artifact lifetime {% include references/cite.html key="newman2022sigstore" %}.

Verification works against the log. A verifier fetches the entry, checks the certificate, and verifies the signature and the log inclusion proof {% include references/cite.html key="newman2022sigstore" %}. Multiple parties run monitors that check the log for consistency, so no single participant needs to be fully trusted {% include references/cite.html key="newman2022sigstore" %}. The root of trust is distributed using The Update Framework (TUF), the same mechanism used for software repository integrity, giving efficient key rotation and freshness {% include references/cite.html key="newman2022sigstore" %}. The system deliberately avoids an expensive consensus mechanism and instead publishes entries to the log in a way that mirrors certificate transparency for web certificates {% include references/cite.html key="newman2022sigstore" %}.

This design carries several security goals: bind signatures to OIDC identities, provide a globally consistent view of the signing ecosystem, provide an audit trail so that compromises are detectable, bind software packages to individual maintainer identities, and provide freshness to resist replay and freeze attacks {% include references/cite.html key="newman2022sigstore" %}.

## Sigstore in the Wild: What Operation Showed

The security conference paper paired the design with measurements from the live public instance {% include references/cite.html key="newman2022sigstore" %}. These figures are time-bound but remain a valuable baseline for how such a system behaves under real load.

By April 11, 2022, the public Rekor log held 1,969,836 entries, and the system had recorded more than 2.2 million signatures over Internet infrastructure {% include references/cite.html key="newman2022sigstore" %}. Over 99 percent of log entries were of three types covering signatures on arbitrary blobs, hashed blobs, and in-toto attestations {% include references/cite.html key="newman2022sigstore" %}. Signature formats were dominated by X.509 at 82.8 percent, followed by minisign at 11.2 percent and PGP at 6.0 percent {% include references/cite.html key="newman2022sigstore" %}.

Issuer data is revealing about who adopted the system. GitHub Actions accounted for 80.2 percent of Fulcio signatures, Google for 17.5 percent, Kubernetes for 1.5 percent, with GitHub OAuth and other issuers making up the rest {% include references/cite.html key="newman2022sigstore" %}. This concentration tells a specific story: keyless signing first found its natural home in automated build pipelines, not in individual developer workflows.

A load test in August 2021 tested the ceiling. On August 18, 2021, Rekor received over 347,000 entries, with per-hour usage peaking at 17,755 requests and per-minute usage peaking at 437 requests, while remaining healthy {% include references/cite.html key="newman2022sigstore" %}. For latency, the bulk of signing time was spent updating TUF metadata, with remote calls to Fulcio and Rekor each taking well under a second on a typical developer workstation {% include references/cite.html key="newman2022sigstore" %}.

## Lessons from Running Signing at Scale

The deployment surfaced lessons that go beyond the key management story {% include references/cite.html key="newman2022sigstore" %}.

The first lesson is that removing key management does not remove the identity problem. Users still have to determine which identities are trusted to sign a particular artifact. A signature proves that an identified party signed the artifact; it does not prove that the party is trustworthy. The paper warns against the assumption that an artifact is secure because it is signed at all, rather than because it is signed by a specific, trusted party {% include references/cite.html key="newman2022sigstore" %}.

The second lesson is that human-readable identities carry their own attack surface. Any workflow in which a human eyeballs an identity to decide whether to trust it is vulnerable to typosquatting or type confusion attacks {% include references/cite.html key="newman2022sigstore" %}. The guidance in the paper is explicit: users must look beyond the email string and consider the issuer field and other certificate fields {% include references/cite.html key="newman2022sigstore" %}.

These two lessons map directly onto the human attack vector identified in the research agenda {% include references/cite.html key="williams2025research" %}. Signing infrastructure improves the integrity of artifacts, but it moves, rather than eliminates, the trust decision onto identities that humans and automated policies must verify correctly.

## Putting Keyless Signing into Practice in the Enterprise

The Sigstore measurements describe a public instance, but the design maps directly onto enterprise delivery pipelines because the trust model is workload-centric rather than key-centric {% include references/cite.html key="newman2022sigstore" %}. The usual failure mode for signing programmes is not cryptography, it is where signing sits in the workflow and who is trusted to verify it.

Start with placement. Sign at build, not at publication. The ephemeral key flow assumes the signer authenticates to an OIDC provider at signing time, so the natural insertion point is the CI job or build controller that already holds a workload identity, for example GitHub Actions, GitLab CI, or a Kubernetes service account federated to your identity provider {% include references/cite.html key="newman2022sigstore" %}. Sign container images, language packages, and attestation predicates such as SLSA provenance and CycloneDX SBOMs at that point, then publish the Rekor inclusion proof alongside the artifact. Verification then belongs in admission, not only in developer tooling: a Kubernetes admission controller, a package manager policy, or a deploy gate that fetches the Rekor entry, checks the Fulcio certificate chain, and validates the inclusion proof before the artifact is admitted {% include references/cite.html key="newman2022sigstore" %}.

Next, decide the identity policy before you scale the cryptography. The operational lesson that identity is the fragile link means the enterprise must enumerate which OIDC issuers and which identities are authorised for each artifact type, and enforce issuer verification in the verifier, not just the email string {% include references/cite.html key="newman2022sigstore" %}. A practical starting set is to trust only the build-system issuer for production artifacts, for example the GitHub Actions issuer for a given organisation, and to require that workload identity matches a repository or pipeline allow-list. Human signing should be scoped to break-glass and release-manager flows, with short-lived certificates that reflect the same allow-list.

Plan for the transparency log as operational infrastructure. Rekor is append-only and monitored for consistency, and TUF distributes the root of trust for efficient rotation {% include references/cite.html key="newman2022sigstore" %}. In enterprise use this translates to running a Rekor monitor or subscribing to a log feed, retaining inclusion proofs in artifact metadata, and exercising TUF metadata refresh and root rotation in a non-production environment before you need it under incident conditions. Sigstore clients spend the bulk of signing time updating TUF metadata on a typical workstation, with Fulcio and Rekor calls well under a second, so the steady-state cost is in freshness management rather than per-sign latency {% include references/cite.html key="newman2022sigstore" %}.

A phased rollout avoids boiling the whole estate at once. Phase one signs container images in a single critical service and enforces verification in its non-production admission path. Phase two extends signing to SBOMs and SLSA attestations for that service, so policy can reason about what is inside the image, not only who built it. Phase three broadens the issuer allow-list and the admission policy to additional services, with log monitoring and proof retention as acceptance criteria for each increment.

Common pitfalls to explicitly mitigate are typosquatting on human-readable identities, trusting any signature without issuer checks, and assuming signing proves safety of the signer {% include references/cite.html key="newman2022sigstore" %}. Mitigations are allow-listed issuers, certificate-field validation beyond email, and combining signing with the graph-aware and continuous-posture controls covered in the companion articles rather than treating it as a standalone guarantee.

## So What: Two Foundations and What Comes Next

This article establishes two foundations that the companion pieces build on.

First, the attack surface is structural. Reuse at scale, which created 96 percent open source penetration, is the same factor that created a complex, hard-to-remediate dependency graph and multiple attacker entry points: components, build infrastructure, and humans {% include references/cite.html key="williams2025research" %}. No single control closes all three.

Second, signing is a solved problem in the cryptographic sense but an open problem in the adoption and policy sense. Sigstore demonstrated that keyless signing can run at millions-of-signatures scale, in automated workflows, with a transparency log that any party can audit {% include references/cite.html key="newman2022sigstore" %}. What it also demonstrated is that trust in identities, not cryptography, is the remaining fragile link {% include references/cite.html key="newman2022sigstore" %}.

The companion articles extend the same lifecycle view. One moves from who produced the software to what is in it: SBOM graphs, vulnerability correlation, and systems that enforce compliance continuously rather than at release time. The other examines how these problems intensify when the component is an AI model or an agentic system. Together the three articles treat software provenance as a lifecycle problem, not a build-time checkbox.

## Conclusion

Software supply chain security is a lifecycle discipline organized around three attack vectors and two integrity foundations. The research agenda identifies component injection, build infrastructure compromise, and human targeting as the vectors, grounded in practitioner summits and a forward-looking research program {% include references/cite.html key="williams2025research" %}. Sigstore provides the foundation for artifact integrity through keyless signing, ephemeral keys, OIDC identity binding, and a public transparency log, with operational evidence that the approach scales {% include references/cite.html key="newman2022sigstore" %}.

The boundary of what signing alone can deliver is equally clear. Signing proves provenance and detects tampering; it does not establish the safety of the signer. That limitation, and the structural amplification of the dependency problem, is precisely what the remaining parts of this series address.

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Technical Appendix" %}

### Evidence Base for This Article

This part of the series draws on two peer-reviewed sources. The appendix records each source, its type, its evidentiary character, and its caveats. Citation numerals refer to the reference list rendered under this post, and full bibliographic details appear in that list.

| No  | Source                                                                            | Venue and type                                                                                      | What this article relies on                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Evidentiary caveat                                                                                                                                                                                                                        |
| --- | --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Williams et al. (2025), Research Directions in Software Supply Chain Security     | ACM Transactions on Software Engineering and Methodology, journal article                           | Three attack vectors; open source penetration (96 percent of code bases containing OSS, 77 percent of code); Sonatype 2024 malicious package figures (512,847, 156 percent increase); incident examples (SolarWinds, log4j, xz utils, node-ipc); S3C2 summit methodology and participant counts; dependency problem framing; SBOM and SLSA framing; LLM-mediated phishing risk                                                                                                                                                                                                                               | Figures for open source penetration and malicious packages are reported by the agenda from industry analyses (Synopsys, Sonatype); the article itself provides practitioner- and research-grounded synthesis rather than new measurements |
| 2   | Newman, Meyers, and Torres-Arias (2022), Sigstore: Software Signing for Everybody | ACM SIGSAC Conference on Computer and Communications Security (CCS), peer-reviewed conference paper | Sigstore architecture (Fulcio, Rekor, ephemeral keys, OIDC, TUF); signing and verification flows; security goals; adoption figures (1.6 percent RubyGems as of 2020; 4 percent PyPI listings and 0.07 percent download verification as of 2016); live-instance measurements (1,969,836 Rekor entries and over 2.2 million signatures as of April 11, 2022; entry type and issuer mix; signature formats; August 2021 load test with 347,000 entries on August 18 and 17,755 per-hour and 437 per-minute peaks); latency breakdown; lessons learned on identity trust, typosquatting, and issuer verification | Measurements are time-bound to the study window (through April 2022) and reflect one public instance; later growth changes magnitude but this part does not rely on any figure after that window                                          |

### Boundary Conditions Applied in This Article

The vector framework is scoped to the three vectors identified in the research agenda {% include references/cite.html key="williams2025research" %}: component dependency injection, build infrastructure compromise, and human-centric attacks. Other categorisations exist, and this series does not claim that the three-vector account is the only taxonomy. The signing discussion is scoped to the Sigstore design and its published measurements {% include references/cite.html key="newman2022sigstore" %}; it does not survey competing signing systems, and the quantitative claims here do not extend beyond the study window the paper reports.

### Status Notes

All quantitative claims in this article are traceable to the two sources listed above, and none relies on a web page or an unverified secondary account. Where a figure originates inside another work that the source itself cites, such as the Synopsys and Sonatype reports cited inside the research agenda, this article treats the figure as reported by the source author and does not assert independent verification against the underlying industry report.

### Discipline Note

This review grounds all analytical claims in the listed sources and labels the character of each claim, including which figures are reported from third parties. No content in this article is generated synthetic data and no claim is made beyond the reference section.

</details>
