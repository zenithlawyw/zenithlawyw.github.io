---
layout: post
last_modified_at: 2026-06-03
title: "Post-Quantum Cryptography: Standards, Migration Pathways, and Workforce Readiness"
author: Zenith Law
description: "NIST PQC standardisation outcomes, automated code migration tooling, hybrid QKD/PQC network architectures, modular education frameworks, and workforce readiness strategies for the post-quantum transition: an evidence-graded synthesis."
permalink: /post-quantum-cryptography-standards-migration-workforce-readiness
intro: "The threat model is clear and the algorithm selections are published; what remains unresolved is how organisations actually migrate. This article examines standardisation outcomes, automated migration tooling, hybrid network architectures, and the acute workforce readiness gap that threatens to delay PQC adoption regardless of technical maturity."
related_posts:
  - title: "Post-Quantum Cryptography: Theoretical Foundations and Reconceptualisation"
    url: /post-quantum-cryptography-theoretical-foundations-reconceptualisation
  - title: "Post-Quantum Cryptography in Practice: Sector-Specific Deployment and Integration Patterns"
    url: /post-quantum-cryptography-sector-deployment-integration-patterns
  - title: "Building Agentic Orchestration: MCP, A2A, LangGraph, and LangChain Playbook"
    url: /building-agentic-orchestration-mcp-a2a-langgraph-langchain-playbook
image: /assets/images/post-quantum-cryptography-standards-migration-workforce-readiness.png
image_version: "20260602-hero-v1"
hero:
  image: /assets/images/post-quantum-cryptography-standards-migration-workforce-readiness.png
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - 10.1145/3626252.3630823
  - 10.1145/3770761.3777201
  - 10.1145/3770762.3772573
  - 10392726
  - 10.1145/3799830.3799836
  - 10747171
  - 11325571
howto_name: "How to plan a post-quantum cryptography migration for enterprise systems"
howto_description: "A structured approach to PQC migration covering inventory, tooling, hybrid architectures, workforce training, and phased rollout."
howto_total_time: "PT4H"
howto_steps:
  - name: "Inventory cryptographic dependencies"
    text: "Catalogue all asymmetric cryptographic operations in your codebase: RSA/ECC key generation, TLS handshakes, digital signatures, and certificate chains."
  - name: "Assess migration urgency using Mosca's inequality"
    text: "Calculate D+T for each data category. If D+T exceeds your estimate of Q, that category requires immediate migration attention."
  - name: "Evaluate automated migration tooling"
    text: "Test LLM-based code migration tools like ccPASTpqc for Python codebases. For production use, validate translated code through execution testing, not just BLEU scores."
  - name: "Deploy hybrid PQ/T certificates"
    text: "Use dual-signature certificates that embed both classical and PQC signatures, enabling gradual migration without breaking interoperability."
  - name: "Establish PQC workforce training"
    text: "Implement modular PQC education: awareness modules for all technical staff, proficiency modules for security teams, and hands-on operational training for cryptographic engineers."
keywords: "PQC migration, post-quantum cryptography standards, NIST PQC, crypto-agility, PQC education, PQC workforce readiness, automated code migration, ccPASTpqc, hybrid QKD PQC, TLS 1.3 PQC, Mosca theorem, CRYSTALS-Kyber, post-quantum transition planning"
catchwords: "PQC migration, NIST standardisation, workforce readiness, automated code migration, hybrid network architecture, crypto-agility, modular PQC education"
categories:
  - Cybersecurity
  - Software Engineering
tags:
  - post-quantum cryptography
  - NIST standards
  - cryptographic migration
  - workforce development
  - software engineering
---

## The Migration Problem

The algorithms exist. NIST published its first post-quantum cryptographic standards in 2024: ML-KEM (CRYSTALS-Kyber) for key encapsulation, ML-DSA (CRYSTALS-Dilithium) for digital signatures, and SLH-DSA (SPHINCS+) for hash-based signatures {% include references/cite.html key="11325571" %}. Standards exist. What does not exist, at any meaningful scale, is the organisational capability to deploy them.

This has stopped being a cryptographic problem. It is a people problem and a software engineering problem that happens to wear a cryptography hat. The [companion theoretical review](/post-quantum-cryptography-theoretical-foundations-reconceptualisation) covered the mathematical foundations. This article turns to the harder question: whether the engineering, educational, and organisational infrastructure can be built in time.

## NIST Standardisation: What It Settled and What It Left Open

### What NIST Resolved

The NIST PQC competition (2016-2024) resolved the primary algorithm selection question through an open, multi-round evaluation process:

<figure markdown="1">

| Algorithm          | Standard           | Type                    | Primary Use Case        | Key Size (bytes)           |
| :----------------- | :----------------- | :---------------------- | :---------------------- | :------------------------- |
| CRYSTALS-Kyber     | ML-KEM (FIPS 203)  | Lattice-based KEM       | Key encapsulation       | 1,184 (pub) / 2,400 (priv) |
| CRYSTALS-Dilithium | ML-DSA (FIPS 204)  | Lattice-based signature | Digital signatures      | 1,952 (pub) / 4,000 (priv) |
| SPHINCS+           | SLH-DSA (FIPS 205) | Hash-based signature    | Conservative signatures | 64 (pub) / 128 (priv)      |
| Falcon             | FN-DSA (draft)     | Lattice-based signature | Compact signatures      | 1,793 (pub) / 2,305 (priv) |

<figcaption>Table 1: NIST-standardised PQC algorithms. Key sizes shown at Security Level 3 (192-bit classical equivalent). Note: "Security Level 3" maps to different parameter sets per algorithm; direct key-size comparison across schemes should account for differing internal structures. The Falcon private key figure (2,305 bytes) is taken from specification documents and should be verified against the final FIPS 206 publication when available.</figcaption>
</figure>

### What Remains Open

Code-based KEM candidates (HQC, BIKE) remain under fourth-round evaluation. If standardised, they would provide algorithm diversity beyond the lattice family, which matters for systemic risk management {% include references/cite.html key="11325571" %}.

Post-quantum zero-knowledge proofs account for roughly 13% of recent PQC publications {% include references/cite.html key="10392726" %}, but mature constructions ready for standardisation do not yet exist.

Interoperability testing across implementations (liboqs, BouncyCastle, AWS-LC, wolfSSL) is still ad-hoc. No systematic cross-implementation validation programme exists.

### Research Mapping

Song and Kim applied LDA topic modelling to 189 PQC papers published in the year following NIST's 2022 announcement {% include references/cite.html key="10392726" %}. The distribution reveals where research effort concentrates:

<figure markdown="1">

| Research Topic                          | Share | Interpretation                        |
| :-------------------------------------- | :---- | :------------------------------------ |
| Hardware acceleration of NIST PQC       | 21%   | Implementation optimisation dominates |
| Digital signatures                      | 21%   | Signature diversity beyond Dilithium  |
| Analysis of NIST PQC candidates         | 18%   | Ongoing security scrutiny             |
| Signature and key exchange              | 16%   | Protocol integration                  |
| Zero-knowledge proofs                   | 13%   | Emerging application area             |
| Cryptographic approaches in blockchains | 11%   | Cross-domain application              |

<figcaption>Table 2: PQC research topic distribution (Song and Kim, 2023; LDA on 189 papers, Aug 2022 to Jul 2023).</figcaption>
</figure>

> **Observation:** NIST-related topics (hardware acceleration + candidate analysis) account for 39% of all PQC research activity, confirming that the standardisation process is the dominant organising force for the field.

## Automated Code Migration: ccPASTpqc

The most novel contribution in the migration space comes from Wahlang and Vidhani, who apply code language models (CLMs) to automate the translation of quantum-vulnerable Python code to PQC-safe equivalents {% include references/cite.html key="10.1145/3799830.3799836" %}.

### The Problem

Enterprise codebases are littered with cryptographic call sites. `from Crypto.PublicKey import RSA`. `nacl.public.PrivateKey()`. `ec.generate_private_key(ec.SECP256R1())`. Each one needs to be found, understood, and replaced. Manual migration at enterprise scale is slow enough to be measured in years rather than sprints, and Mosca's inequality tells us that migration time (T) is the one variable organisations can actually compress. That is ccPASTpqc's target.

### The Approach

1. **Dataset creation:** Manual construction of parallel classical → PQC Python program pairs from four libraries (PyCryptodome, PyNaCl, Cryptography, OpenSSL) and their PQC counterparts (pqcrypto, liboqs-python)
2. **Data augmentation:** 11 variant-generation techniques expanding the training set
3. **Model fine-tuning:** CodeT5 (Seq2Seq transformer) fine-tuned on the parallel corpus
4. **Novel chunking:** Pairwise AST-based chunking that preserves semantic alignment between source and target programs, overcoming context-length limitations

### Results and Limitations

<figure markdown="1">

| Metric                 | Score       | Context                                      |
| :--------------------- | :---------- | :------------------------------------------- |
| BLEU (GitHub projects) | 0.925       | High translation fidelity on real-world code |
| CodeBLEU               | Comparable  | Captures syntactic + semantic similarity     |
| Dataset size           | ~500 pairs  | Small by ML standards                        |
| Language coverage      | Python only | No C/C++, Java, Go support                   |

<figcaption>Table 3: ccPASTpqc performance metrics (Wahlang and Vidhani, 2026).</figcaption>
</figure>

**Critical caveat:** A 0.925 BLEU score tells you the output text looks like correct code. It does not tell you whether the code compiles, passes tests, or preserves the security properties of the original implementation. The translated GitHub code was never execution-tested {% include references/cite.html key="10.1145/3799830.3799836" %}. Anyone who has spent time debugging LLM-generated code knows the gap between "syntactically plausible" and "silently violates an invariant that a human developer would catch by instinct." For production migration, execution testing and security auditing of every translated function are non-negotiable.

**Practical gap:** Most production cryptographic code lives in C, C++, Java, and Go. ccPASTpqc covers Python only. This is a proof of concept, not a migration tool you can hand to your engineering team and walk away.

### What Practitioners Should Do Now

- Use ccPASTpqc-style tools for initial translation drafts, then review and test manually
- Invest in cryptographic dependency inventories before migration (you cannot migrate what you have not catalogued)
- Prioritise asymmetric key operations (symmetric encryption requires only key-size increases)

## Hybrid QKD/PQC Network Architectures

Shim et al. propose a practical network architecture combining quantum key distribution (QKD) with PQC algorithms within TLS 1.3 {% include references/cite.html key="10747171" %}. The architecture addresses a fundamental limitation of QKD: it requires dedicated quantum hardware on every network segment, which is infeasible for wide-area networks.

### Architecture Design

The hybrid approach segments the network into zones:

1. **QKD-protected zones:** Metropolitan-area links with installed quantum hardware use QKD for key distribution
2. **PQC-protected zones:** Long-haul and access network segments without quantum hardware use PQC algorithms within TLS 1.3
3. **Bridge zones:** Quantum Key Management Systems (QKMS) translate between QKD-derived keys and PQC-encapsulated keys

<figure markdown="1">

| Network Segment      | Key Distribution | Encryption  | Protocol                 |
| :------------------- | :--------------- | :---------- | :----------------------- |
| Data centre to metro | QKD (BB84)       | AES-256-GCM | QKD channel              |
| Metro to regional    | PQC (ML-KEM)     | AES-256-GCM | TLS 1.3 + PQC extensions |
| Regional to edge     | PQC (ML-KEM)     | AES-256-GCM | TLS 1.3 + PQC extensions |
| Bridge               | QKMS translation | Re-keying   | Proprietary              |

<figcaption>Table 4: Hybrid QKD/PQC network zone architecture (synthesised from Shim et al., 2024).</figcaption>
</figure>

### TLS 1.3 PQC Integration

The extensible design of TLS 1.3 supports PQC integration through two mechanisms:

- **`key_share` extension:** Carries PQC KEM ciphertexts alongside or instead of classical ECDH shares
- **`signature_algorithms` extension:** Advertises support for PQC digital signatures (ML-DSA, SLH-DSA)

This means PQC slots into the existing TLS protocol framework without protocol-level redesign. No new wire format. No renegotiation of the handshake state machine. That is a critical practical advantage over QKD, which demands entirely new physical infrastructure at every hop.

## The Workforce Readiness Gap

Three independent studies, from different countries and targeting different audiences, arrive at the same uncomfortable finding: the technical tools for PQC migration exist, but trained practitioners do not. Not at scale. The evidence comes from small programmes, and the confidence we can place in their generalisability is limited, but the consistency of direction across uncoordinated efforts is worth noting.

### Evidence from Three Educational Programmes

<figure markdown="1">

| Programme   | Institution        | Audience                | Format               | Key Finding                                                                                                                   |
| :---------- | :----------------- | :---------------------- | :------------------- | :---------------------------------------------------------------------------------------------------------------------------- |
| PQC Course  | RIT (USA)          | Graduate students       | Full semester course | Bottom-up pedagogy works; "PQC" name confuses students {% include references/cite.html key="10.1145/3626252.3630823" %}       |
| Modular PQC | RIT + U. Rochester | High school to graduate | Embeddable modules   | Lowers adoption barrier; no curriculum approval needed {% include references/cite.html key="10.1145/3770761.3777201" %}       |
| PQCIP       | Monash (Australia) | Industry professionals  | 3-module programme   | Exposing individual crypto operations improves understanding {% include references/cite.html key="10.1145/3770762.3772573" %} |

<figcaption>Table 5: PQC educational programmes assessed in this review.</figcaption>
</figure>

### Key Pedagogical Insights

**Bottom-up teaching outperforms top-down.** Start with simple worked examples; build toward complex cryptosystems. Borrelli et al. found this more effective than presenting abstract definitions first {% include references/cite.html key="10.1145/3626252.3630823" %}. One exception: graduate students with mathematical maturity benefited from top-down presentations. The implication is clear: differentiated pedagogy is necessary, not optional.

**The name "Post-Quantum Cryptography" actively misleads.** Students consistently interpreted it as "cryptography that uses quantum computers" rather than "cryptography that resists quantum computers" {% include references/cite.html key="10.1145/3626252.3630823" %}. Small nomenclature problem; enormous pedagogical consequences. Borrelli et al. suggest "Quantum-Resistant Cryptography" as a clearer alternative, and having watched students struggle with the term myself, I suspect they are right.

**Exposing individual operations matters more than you would expect.** Standard tools like GPG and OpenSSL abstract cryptographic operations behind protocol-level interfaces. Learners never see what each step does. Steinfeld et al. built a custom software interface for CRYSTALS-Kyber that exposes key generation, encapsulation, and decapsulation separately {% include references/cite.html key="10.1145/3770762.3772573" %}. The result: non-programmer cybersecurity professionals could understand operations they had previously treated as black boxes.

**Modular embedding is the scalable path forward.** Full PQC courses require curriculum approval processes that can take years. The modular approach sidesteps this entirely. Borrelli et al. define two tiers {% include references/cite.html key="10.1145/3770761.3777201" %}: awareness modules (no prerequisites, suitable for high school onward, covering why current cryptography is vulnerable) and proficiency modules (requiring existing cryptography background, covering algorithm design, implementation, and NIST standard evaluation).

### Workforce Strategy Recommendations

The evidence base here is thin. Three programmes at three institutions, with the largest cohort numbering 21 students. Generalisability beyond these specific contexts is unvalidated. That said, the directional findings are consistent enough to inform early planning, with the caveat that these are hypotheses worth testing at scale rather than proven prescriptions:

1. **Immediate:** Deploy awareness-level PQC training across IT and security teams. This requires no curriculum restructuring and can be run as half-day workshops. The bar is low: staff should understand what the quantum threat changes and what it does not.

2. **Short-term:** Establish proficiency-level training for cryptographic engineers and security architects, using hands-on tool interaction with individual operations exposed (the PQCIP model). Whether the custom-tool approach from Steinfeld et al. transfers to other institutions and audiences is an open question.

3. **Medium-term:** Embed PQC modules into existing computer science and cybersecurity degree programmes. The modular approach sidesteps curriculum approval bottlenecks, which is its primary advantage.

4. **Ongoing:** Maintain crypto-agility as an organisational competency, not just a technical property. When NIST publishes a deprecation notice or a new attack surfaces, the response time should be measured in weeks, not quarters.

## Migration Planning Framework

Synthesising the migration-related findings yields a practical framework:

### Phase 1: Inventory and Assess

- Catalogue all asymmetric cryptographic operations across the codebase
- Map data sensitivity lifetimes (D) and estimate migration time (T)
- Apply Mosca's inequality ($D + T > Q$) to prioritise categories
- Identify cryptographic libraries in use and their PQC support status

### Phase 2: Pilot and Validate

- Deploy PQC in non-critical internal systems first
- Test hybrid PQ/T certificates for backward compatibility
- Evaluate automated migration tooling (ccPASTpqc for Python; manual review for other languages)
- Benchmark PQC performance impact on latency-sensitive operations

### Phase 3: Gradual Rollout

- Enable PQC in TLS 1.3 via `key_share` and `signature_algorithms` extensions
- Deploy dual-signature certificates during transition
- Monitor for compatibility issues across client populations
- Maintain classical fallback paths

### Phase 4: Completion and Monitoring

- Remove classical-only configurations once client population supports PQC
- Establish ongoing cryptographic monitoring for algorithm deprecation announcements
- Maintain crypto-agility for future algorithm rotations

## Takeaways

NIST resolved the algorithm question. The harder problem, organisational readiness, remains largely untouched. Workforce capacity, not algorithm availability, is the binding constraint on migration timelines. Three educational programmes point in a consistent direction (modular, bottom-up, hands-on), but the evidence base is narrow: small cohorts at single institutions, one programming language, no longitudinal outcome data.

Automated migration tooling shows promise. ccPASTpqc achieves 0.925 BLEU on Python conversions, which is encouraging for draft generation but tells us nothing about functional correctness. No execution testing validates the output, and production languages (C, C++, Java, Go, Rust) lack equivalent tooling entirely. Treat it as a starting point for human review, not a substitute for it.

Hybrid QKD/PQC network integration works within the TLS 1.3 extensibility model, which removes the protocol-redesign concern. The remaining work is practical engineering: zone-based deployment, QKMS bridge infrastructure, interoperability testing with existing certificate authorities. None of this has been validated at production scale.

The migration timeline is governed by Mosca's inequality. Organisations should compute $D + T$ for each data category and treat the result as a deadline, not a planning target.

---

## Practitioner Questions on Migration and Readiness

### How long does a typical PQC migration take for an enterprise?

There is no typical case yet. Migration timelines depend on codebase size, cryptographic dependency count, and how deeply classical algorithms are embedded in the architecture. Automated tooling can accelerate the Python fraction, but manual review is still necessary for every converted function. For large enterprises with heterogeneous stacks, expect a multi-year programme. The first step, inventorying cryptographic dependencies, can start immediately and is worth doing regardless of migration timeline.

### Can TLS 1.3 support PQC without protocol changes?

Yes. TLS 1.3 was designed with extensibility in mind; the `key_share` and `signature_algorithms` extensions can carry PQC KEM ciphertexts and digital signatures within the existing handshake. No protocol redesign is required. This is one of the genuine practical advantages of PQC: the transport layer can evolve without breaking the protocol itself.

### What programming languages does automated PQC code migration cover?

As of the papers reviewed here, only Python, through ccPASTpqc. Production cryptographic code in C, C++, Java, Go, and Rust requires manual migration or purpose-built tooling that does not yet exist. Given that most security-critical cryptographic implementations live in C and C++, the tooling gap is substantial.

### Is "Post-Quantum Cryptography" the same as "quantum cryptography"?

No, and the confusion is not academic. Borrelli et al. found that students consistently misread "post-quantum" as meaning "cryptography that uses quantum computers" rather than "cryptography that resists quantum computers." PQC runs on classical hardware with algorithms designed to survive quantum attacks. Quantum cryptography (QKD) uses quantum physics for key distribution. The term "Quantum-Resistant Cryptography" has been suggested as a clearer alternative.

---

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Source Credibility, Evidence Boundaries, and Technical Reference" %}

### Appendix Table of Contents

- [Source Attribution and Review Context](#source-attribution-and-review-context)
- [A. Scope and Validity Constraints](#a-scope-and-validity-constraints)
- [B. Key Terms](#b-key-terms)
- [C. Reviewed Sources at a Glance](#c-reviewed-sources-at-a-glance)

### Source Attribution and Review Context

This article is authored by [Zenith Law](/authors/zenith-law/) and synthesises findings on PQC standards, migration, and education from six papers spanning SIGCSE, IEEE, and ACM venues. Borrelli et al. (2024) is published at SIGCSE, the premier CS education venue. Steinfeld et al. (2026) bring hands-on professional training experience from Monash University and industry partnerships. Wahlang and Vidhani (2026) present the first dedicated PQC code migration tool using language models. Song and Kim (2023) provide quantitative research mapping via topic modelling. Shim et al. (2024) present a hybrid network architecture aligned with South Korea's KISTI infrastructure.

### A. Evidence Boundary Notes

The ccPASTpqc results use BLEU and CodeBLEU, metrics that measure textual similarity rather than functional correctness; the authors did not execution-test their translated code on real projects. Educational programme evaluations rest on small cohorts at individual institutions (Borrelli: 14 and 21 students at RIT; Steinfeld: cohort size not reported), and the modular curriculum paper from Borrelli et al. (2026) is a 2-page poster with no assessment data. Generalising from these to workforce-wide strategy involves a significant inferential leap. The hybrid network architecture from Shim et al. is a protocol-level design; no performance benchmarks or scale testing accompany it. Song and Kim's topic modelling covers a single year of data using bag-of-words LDA, which captures surface-level thematic distribution but cannot assess paper quality or methodological rigour.

### B. Key Terms

<dl>
<dt><dfn>Mosca's Inequality</dfn></dt>
<dd>$D + T > Q$ where D = data sensitivity lifetime, T = migration time, Q = time until quantum threat materialises. When the inequality holds, migration should have already begun.</dd>

<dt><dfn>QKMS (Quantum Key Management System)</dfn></dt>
<dd>Infrastructure that bridges QKD-derived symmetric keys and PQC-encapsulated keys, enabling hybrid networks where some segments use quantum hardware and others use classical infrastructure with PQC.</dd>

<dt><dfn>Pairwise AST-based Chunking</dfn></dt>
<dd>A code segmentation technique that splits source and target programs at matching Abstract Syntax Tree (AST) boundaries, preserving semantic alignment between paired program fragments for Seq2Seq model training.</dd>

<dt><dfn>CodeBLEU</dfn></dt>
<dd>An extension of BLEU that incorporates AST match and data-flow match scores alongside n-gram overlap, providing a more semantically aware evaluation of code generation quality.</dd>
</dl>

### C. Reviewed Sources at a Glance

<figure markdown="1">

| Paper               | Year | Type              | Key Contribution                        | Confidence Notes                            |
| :------------------ | :--- | :---------------- | :-------------------------------------- | :------------------------------------------ |
| Borrelli et al.     | 2024 | Experience report | Full PQC course design + outcomes       | Strong venue (SIGCSE), iterative refinement |
| Borrelli et al.     | 2026 | Poster            | Modular PQC education framework         | 2-page abstract only, no assessment data    |
| Steinfeld et al.    | 2026 | Experience report | Professional PQC training + custom tool | SIGCSE venue but no quantitative outcomes   |
| Song and Kim        | 2023 | Quantitative      | Research mapping via LDA                | Single-year snapshot, bag-of-words method   |
| Wahlang and Vidhani | 2026 | Experimental      | LLM-based PQC code migration            | BLEU metrics only; no execution testing     |
| Shim et al.         | 2024 | Architecture      | Hybrid QKD/PQC network design           | Design only, no performance benchmarks      |

<figcaption>Table A1: Summary of reviewed literature for the standards, migration, and education domain.</figcaption>
</figure>

### D. SEO, GEO, and AEO Optimisation Notes

**Primary search terms:** PQC migration, NIST PQC standards, post-quantum cryptography education, automated code migration, hybrid QKD PQC network, TLS 1.3 post-quantum, Mosca inequality, crypto-agility.

**Structured data:** HowTo and FAQ schemas are implemented. Article schema includes author attribution and citation metadata.

**Cross-references:** Linked to companion PQC theoretical foundations and sector deployment articles.

</details>
