---
layout: post
title: "Post-Quantum Cryptography: Theoretical Foundations and Reconceptualisation"
author: Zenith Law
description: "A systematic exploratory review of post-quantum cryptographic primitives (lattice-based, code-based, hash-based, and hybrid QC/PQC constructions) examining the mathematical foundations, hardware acceleration strategies, and reconceptualisation of security models for the quantum era."
permalink: /post-quantum-cryptography-theoretical-foundations-reconceptualisation
intro: "Quantum computers threaten to dismantle the public-key infrastructure that underpins digital commerce, governance, and communication. This article synthesises findings from the reviewed literature on the theoretical foundations of post-quantum cryptography, from lattice and code-based constructions to hybrid quantum/classical defence models, and identifies the reconceptualisation of security models that the quantum transition demands."
related_posts:
  - title: "Post-Quantum Cryptography: Standards, Migration Pathways, and Workforce Readiness"
    url: /post-quantum-cryptography-standards-migration-workforce-readiness
  - title: "Post-Quantum Cryptography in Practice: Sector-Specific Deployment and Integration Patterns"
    url: /post-quantum-cryptography-sector-deployment-integration-patterns
  - title: "Representation Learning, Hilbert Spaces, and Quantum Semantics"
    url: /representation-learning-hilbert-spaces-quantum-semantics-domain-adaptation-clustering
image: /assets/images/post-quantum-cryptography-theoretical-foundations-reconceptualisation.png
image_version: "20260529-hero-v1"
hero:
  image: /assets/images/post-quantum-cryptography-theoretical-foundations-reconceptualisation.png
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - 10.1145/3703837
  - 11011628
  - 10543513
  - 11325571
  - 10.1145/3575664
howto_name: "How to evaluate post-quantum cryptographic primitives for system design"
howto_description: "A structured approach to understanding lattice-based, code-based, and hash-based PQC families, their security assumptions, and practical selection criteria."
howto_total_time: "PT2H"
howto_steps:
  - name: "Understand the quantum threat model"
    text: "Learn how Shor's algorithm breaks RSA and ECC in polynomial time, and how Grover's algorithm weakens symmetric ciphers by halving effective key length."
  - name: "Survey the four PQC algorithm families"
    text: "Compare lattice-based, code-based, hash-based, and multivariate schemes on security assumptions, key sizes, and performance."
  - name: "Evaluate hardware acceleration requirements"
    text: "Assess whether your deployment targets require FPGA or ASIC acceleration, particularly for code-based schemes like HQC and BIKE."
  - name: "Consider hybrid QC/PQC architectures"
    text: "Evaluate whether combining quantum key distribution with PQC encryption provides defence-in-depth for your threat model."
  - name: "Plan for crypto-agility"
    text: "Design systems to swap cryptographic algorithms without infrastructure overhaul, given that even NIST-evaluated candidates have been broken."
keywords: "post-quantum cryptography, lattice-based cryptography, code-based cryptography, hash-based signatures, CRYSTALS-Kyber, CRYSTALS-Dilithium, NIST PQC, quantum threat, Shor algorithm, Grover algorithm, crypto-agility, hybrid quantum cryptography, sparse polynomial multiplication, FPGA PQC"
catchwords: "post-quantum cryptography, lattice-based schemes, code-based PQC, hardware acceleration, hybrid QC/PQC, quantum threat model, crypto-agility, NIST standardisation"
categories:
  - Cybersecurity
  - Applied Mathematics
tags:
  - post-quantum cryptography
  - lattice-based cryptography
  - quantum computing
  - cryptographic primitives
  - NIST standards
---

## The Quantum Threat to Public-Key Cryptography

The security of RSA, elliptic curve Diffie-Hellman, and DSA rests on the computational hardness of integer factorisation and the discrete logarithm problem. Shor's algorithm, running on a fault-tolerant quantum computer, reduces both problems to polynomial time {% include references/cite.html key="10543513" %}. This is not a gradual erosion of security margins; it is a categorical break. A sufficiently capable quantum computer renders these schemes as insecure as plaintext transmission.

The timeline remains contested. Estimates for cryptographically relevant quantum computers range from a decade to several decades, but the "harvest now, decrypt later" threat model makes the arrival date less important than it initially appears. Adversaries collecting encrypted traffic today can store it and decrypt it when quantum capability materialises {% include references/cite.html key="11325571" %}. For data with sensitivity lifetimes measured in decades (state secrets, medical records, infrastructure designs), the migration deadline is already past.

> **Mosca's Inequality:** If the time to migrate (T) plus the data sensitivity lifetime (D) exceeds the time until quantum capability arrives (Q), then the data is already at risk. $D + T > Q$ implies immediate action is required {% include references/cite.html key="10543513" %}.

### Symmetric Cryptography: A Relative Safe Harbour

Grover's algorithm provides a quadratic speedup for brute-force search, effectively halving symmetric key lengths. AES-256 becomes AES-128 in effective strength against a quantum adversary, still beyond practical attack {% include references/cite.html key="10543513" %}. The asymmetric key infrastructure, not symmetric encryption, is the critical vulnerability.

<figure markdown="1">

| Algorithm Family | Classical Security             | Quantum Vulnerability                         | Mitigation             |
| :--------------- | :----------------------------- | :-------------------------------------------- | :--------------------- |
| RSA / DSA        | Integer factorisation hardness | Shor's algorithm (broken in polynomial time)  | Replace with PQC       |
| ECC / ECDH       | Discrete logarithm hardness    | Shor's algorithm (broken in polynomial time)  | Replace with PQC       |
| AES-256          | Brute-force resistance         | Grover halves effective key length to 128-bit | Double key sizes       |
| SHA-256          | Collision resistance           | Grover provides quadratic speedup             | Increase output length |

<figcaption>Table 1: Quantum vulnerability of major cryptographic families and their respective mitigation strategies.</figcaption>
</figure>

## The Four PQC Algorithm Families

Post-quantum cryptography replaces the mathematical problems broken by Shor's algorithm with problems believed to resist both classical and quantum attack. Four families dominate the landscape {% include references/cite.html key="10543513" %} {% include references/cite.html key="11325571" %}:

### Lattice-Based Cryptography

<dl>
<dt><dfn>Lattice problem</dfn></dt>
<dd>Finding the shortest or closest vector in a high-dimensional lattice. The Learning With Errors (LWE) and Module-LWE variants underpin CRYSTALS-Kyber (key encapsulation) and CRYSTALS-Dilithium (digital signatures).</dd>
</dl>

Lattice-based schemes offer relatively compact key sizes and fast operations, making them the most practical PQC family for general deployment. NIST selected CRYSTALS-Kyber for key encapsulation and CRYSTALS-Dilithium as one of three signature algorithms {% include references/cite.html key="11325571" %}.

**Strengths:** Versatile: supports encryption, key exchange, and signatures. Well-studied mathematical foundation. Reasonable performance on commodity hardware.

**Weaknesses:** Key sizes larger than RSA/ECC equivalents (Kyber-768 public key: 1,184 bytes vs. ECDH P-256: 64 bytes). Security proofs rely on worst-case to average-case reductions whose tightness is still debated.

### Code-Based Cryptography

<dl>
<dt><dfn>Code-based scheme</dfn></dt>
<dd>Built on the hardness of decoding random linear error-correcting codes. The McEliece cryptosystem (1978) is the oldest PQC candidate, and newer variants like HQC and BIKE use structured codes for improved efficiency.</dd>
</dl>

Code-based schemes have the longest track record of resisting cryptanalysis. McEliece has survived over 45 years of scrutiny. However, their practical deployment is constrained by extremely large key sizes (McEliece public key: ~1 MB) {% include references/cite.html key="10543513" %}.

He et al. address the hardware acceleration challenge for code-based PQC with two novel sparse polynomial multiplication accelerators for HQC and BIKE {% include references/cite.html key="10.1145/3703837" %}. Their designs achieve 56.84% and 80.25% lower area-delay product (ADP) than the state of the art, demonstrating that hardware optimisation can make code-based schemes practical even in resource-constrained environments.

<figure markdown="1">

| Design             | Target    | ADP Improvement  | Memory Requirement | FPGA Platform      |
| :----------------- | :-------- | :--------------- | :----------------- | :----------------- |
| PSA (memory-based) | HQC, BIKE | 56.84% lower ADP | Block RAM          | Xilinx UltraScale+ |
| PWP (memory-free)  | HQC, BIKE | 80.25% lower ADP | None               | Xilinx UltraScale+ |

<figcaption>Table 2: HSPA sparse polynomial multiplication accelerator performance (He et al., 2024).</figcaption>
</figure>

### Hash-Based Signatures

<dl>
<dt><dfn>Hash-based signature</dfn></dt>
<dd>Digital signatures constructed from hash function properties alone. SPHINCS+ (now SLH-DSA) relies only on the collision resistance and pre-image resistance of hash functions, making it the most conservative security assumption in PQC.</dd>
</dl>

Hash-based signatures are considered the safest PQC family because their security reduces entirely to hash function properties, which are well-understood and quantum-resistant (with doubled output length). NIST selected SPHINCS+ as one of three standardised signature algorithms {% include references/cite.html key="11325571" %}.

**Trade-off:** Large signature sizes (up to 49 KB for SPHINCS+-256s) and slower signing compared to lattice-based alternatives. Best suited for scenarios where signature size is less critical than conservative security assumptions.

### Multivariate Cryptography

<dl>
<dt><dfn>Multivariate scheme</dfn></dt>
<dd>Based on the hardness of solving systems of multivariate polynomial equations over finite fields. Rainbow was a NIST finalist before being broken by a classical attack in 2022.</dd>
</dl>

The Rainbow break is a cautionary tale for the entire PQC field. Ward Beullens demonstrated a classical attack that recovered Rainbow secret keys "over the weekend on a laptop" {% include references/cite.html key="10.1145/3575664.11325571" %}. This was not a quantum attack; classical cryptanalysis invalidated a NIST finalist. Similarly, SIKE (Supersingular Isogeny Key Encapsulation) was broken "in about one hour on a single core" {% include references/cite.html key="11325571" %}.

> **Lesson:** PQC algorithms are young. The mathematical problems they rely on have received far less scrutiny than RSA's integer factorisation. Crypto-agility (the ability to swap algorithms without system redesign) is not optional; it is a survival requirement.

## Hardware Acceleration for Code-Based PQC

The practical viability of code-based PQC depends heavily on efficient hardware implementation. He et al. identify sparse polynomial multiplication as the computational bottleneck for HQC and BIKE, both NIST fourth-round candidates {% include references/cite.html key="10.1145/3703837" %}.

Their contribution is twofold:

1. **Parallel Segment-based Accumulation (PSA):** Decomposes sparse polynomial multiplication into segment-level operations that can be parallelised across FPGA resources. The memory-based implementation achieves high throughput using block RAM for intermediate storage.

2. **Permutating-with-Power (PWP):** A memory-free alternative that eliminates block RAM dependency entirely, enabling deployment on FPGAs where RAM resources are reserved for other functions. Despite the constraint, PWP achieves even better ADP than PSA.

Both designs are generic across all HQC and BIKE security levels (128, 192, 256-bit equivalent), providing a reusable hardware primitive for the code-based PQC family.

### Practical Significance

If NIST standardises HQC or BIKE (both remain under evaluation), these hardware accelerators provide the implementation foundation for deployment in embedded systems, IoT gateways, and network appliances where software-only PQC performance may be insufficient.

## Hybrid QC/PQC: Belt-and-Suspenders Security

Kavitha et al. propose combining quantum key distribution (QKD) with PQC encryption as a defence-in-depth strategy {% include references/cite.html key="11011628" %}. The rationale is straightforward:

- **QKD** provides information-theoretic security for key distribution (provably unbreakable, assuming correct implementation of quantum mechanics) but requires expensive quantum hardware and is distance-limited.
- **PQC** provides computational security (breakable in principle if the underlying mathematical problem is solved) but runs on classical infrastructure with no distance constraints.

Combining both means an attacker must break _both_ physical laws _and_ solve hard mathematical problems, a significantly higher bar than either defence alone.

<figure markdown="1">

| Property            | QKD Alone                    | PQC Alone                           | Hybrid QC/PQC       |
| :------------------ | :--------------------------- | :---------------------------------- | :------------------ |
| Security basis      | Laws of physics              | Computational hardness              | Both                |
| Infrastructure      | Quantum hardware, fibre      | Classical networks                  | Mixed               |
| Distance constraint | ~100 km (without repeaters)  | None                                | PQC extends reach   |
| Scalability         | Limited                      | High                                | High (PQC backbone) |
| Cost                | High                         | Low                                 | Moderate            |
| Future-proofing     | Immune to algorithmic breaks | Vulnerable to mathematical advances | Double protection   |

<figcaption>Table 3: Comparison of QKD, PQC, and hybrid QC/PQC security architectures (synthesised from Kavitha et al., 2025).</figcaption>
</figure>

### Where Hybrid Makes Sense

Hybrid QC/PQC is most justified for:

- **Government and military communications** where "harvest now, decrypt later" threats are existential
- **Financial infrastructure** where transaction integrity has multi-decade legal significance
- **Critical national infrastructure** (power grids, telecommunications) where compromise has cascading physical consequences

For typical enterprise applications, PQC alone is sufficient and far more practical.

## Reconceptualising Security Models

The quantum transition forces a reconceptualisation of how security is defined, measured, and maintained:

### From Static to Agile Cryptography

Classical cryptographic deployment assumed algorithms would last decades. RSA-2048 was expected to remain secure until at least 2030. PQC algorithms, by contrast, have survived at most a few years of scrutiny. The SIKE and Rainbow breaks demonstrate that even expert-vetted, multi-year evaluation processes can miss fatal weaknesses {% include references/cite.html key="10.1145/3575664" %}.

Systems must be designed for algorithm replacement as a routine maintenance operation, not an emergency migration:

- **Protocol-level agility:** TLS 1.3 already supports algorithm negotiation; PQC extensions exist
- **Certificate agility:** Hybrid certificates (PQ/T) allow dual-signing during transition periods
- **Key management agility:** Key encapsulation mechanisms should be abstracted behind interfaces that support algorithm swapping

### From Single-Layer to Defence-in-Depth

The classical model of "one good algorithm is enough" gives way to layered defences:

1. PQC for computational resistance
2. QKD for physics-based resistance (where feasible)
3. Forward secrecy to limit the blast radius of key compromise
4. Key rotation to bound the exposure window

### From Algorithm Security to System Security

An algorithm's theoretical security means little if the implementation leaks timing information, the key management system is vulnerable, or the migration process introduces compatibility gaps. The reviewed literature consistently shows that PQC algorithm research far outpaces deployment engineering, a gap that practitioners must close {% include references/cite.html key="11325571" %}.

## Research Gaps and Open Questions

The reviewed literature reveals several areas where theoretical foundations remain incomplete:

- **Tight security reductions for lattice-based schemes:** The worst-case to average-case reductions that underpin Kyber and Dilithium security proofs have gaps in tightness that affect concrete security parameter selection
- **Formal hybrid security models:** No rigorous framework exists for proving that hybrid QC/PQC systems provide security strictly greater than either component alone {% include references/cite.html key="11011628" %}
- **Quantum-resistant zero-knowledge proofs:** Identified by topic modelling as an emerging research area, but still lacking mature constructions suitable for standardisation {% include references/cite.html key="11325571" %}
- **Side-channel resistance:** Hardware implementations like HSPA focus on functional performance but do not address timing, power analysis, or electromagnetic emanation attacks

## Takeaways

1. **The quantum threat to public-key cryptography is categorical, not gradual.** Shor's algorithm does not weaken RSA; it eliminates it. Migration is not optimisation; it is replacement.

2. **Lattice-based schemes (Kyber, Dilithium) are the pragmatic default** for most deployments, but crypto-agility is essential given the field's youth and the history of unexpected breaks.

3. **Code-based PQC is viable with hardware acceleration.** The HSPA accelerators demonstrate that FPGA implementations can achieve practical performance for HQC and BIKE, expanding the viable PQC algorithm portfolio.

4. **Hybrid QC/PQC provides genuine defence-in-depth** for high-value targets, but the engineering complexity and cost restrict it to critical applications.

5. **Crypto-agility is the single most important architectural decision.** The ability to swap algorithms without system redesign protects against the inevitable surprises that a young cryptographic field will produce.

---

## Frequently Asked Questions

### What makes post-quantum cryptography different from quantum cryptography?

Post-quantum cryptography uses classical algorithms designed to resist quantum attacks, running on conventional hardware. Quantum cryptography (QKD) uses quantum mechanical properties of photons for key distribution, requiring specialised quantum hardware. PQC replaces vulnerable algorithms; QKD provides a fundamentally different security mechanism based on physics rather than computational hardness.

### Why were SIKE and Rainbow broken, and what does that mean for other PQC algorithms?

SIKE was broken by a classical mathematical attack exploiting the structure of supersingular isogeny graphs. Rainbow was broken by a key-recovery attack using classical computation. Both were NIST-evaluated candidates that survived years of scrutiny before fatal weaknesses were found. This demonstrates that PQC algorithms are significantly less battle-tested than RSA/ECC and reinforces the need for crypto-agility in any deployment.

### Is AES-256 safe against quantum computers?

Yes, for practical purposes. Grover's algorithm halves the effective key length, reducing AES-256 to 128-bit equivalent security against a quantum adversary. AES-128 equivalent strength remains far beyond practical brute-force attack. The vulnerability is in asymmetric (public-key) cryptography, not symmetric encryption.

### What is crypto-agility and why is it critical for PQC migration?

Crypto-agility is the architectural property that allows cryptographic algorithms to be replaced without redesigning the system. Given that PQC algorithms have survived only a few years of scrutiny (compared to decades for RSA), algorithm-level surprises are expected. Systems without crypto-agility face emergency migration under time pressure, exactly the scenario Mosca's inequality warns against.

### How does hardware acceleration affect PQC deployment decisions?

Code-based PQC schemes (HQC, BIKE) require sparse polynomial multiplication that is computationally expensive in software. FPGA-based accelerators like HSPA reduce area-delay product by 57-80%, making these schemes viable for embedded and IoT deployments. Without hardware acceleration, code-based schemes may be impractical for resource-constrained environments.

---

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Evidence Boundaries, Source Credibility, and Technical Reference" %}

### Appendix Table of Contents

- [Author and Source Credibility](#author-and-source-credibility)
- [A. Evidence Boundary Notes](#a-evidence-boundary-notes)
- [B. Technical Term Definitions](#b-technical-term-definitions)
- [C. Literature Analysis Summary](#c-literature-analysis-summary)
- [D. SEO, GEO, and AEO Optimisation Notes](#d-seo-geo-and-aeo-optimisation-notes)

### Author and Source Credibility

This article is authored by [Zenith Law](/authors/zenith-law/) and synthesises findings from the reviewed literature on post-quantum cryptographic primitives. The papers span IEEE conference proceedings, ACM transactions, and Communications of the ACM. He et al. (2024) provide peer-reviewed experimental results with FPGA benchmarks. Monroe (2023) draws on expert interviews with leading cryptographers including Bruce Schneier. Tiwari et al. (2024) and Sharma et al. (2025) provide survey-level coverage. Kavitha et al. (2025) present a conceptual hybrid framework without experimental validation.

**Retraction note:** Zhang (2019) on "Black Hole Keypad Compression" was retracted by IEEE Access ("accepted in error and will not be published in its final form"). Its claims contradict Shannon's foundational proof on one-time pad key length requirements and are excluded from this synthesis.

### A. Evidence Boundary Notes

- **Hardware acceleration results** (He et al.) are FPGA-specific; no ASIC validation exists. Performance numbers are for sparse polynomial multiplication in isolation, not full cryptosystem operation.
- **Hybrid QC/PQC analysis** (Kavitha et al.) is conceptual only; no prototype, simulation, or performance benchmarks were produced.
- **Algorithm vulnerability assessments** are based on the cryptanalytic state of the art at time of publication. New attacks may invalidate any assessment.
- **NIST standardisation status** reflects the published standards as of the literature review period; ongoing fourth-round evaluations may change the landscape.

### B. Technical Term Definitions

<dl>
<dt><dfn>Key Encapsulation Mechanism (KEM)</dfn></dt>
<dd>A public-key mechanism that allows a sender to establish a shared symmetric key with a recipient. CRYSTALS-Kyber (ML-KEM) is the NIST-standardised PQC KEM.</dd>

<dt><dfn>Learning With Errors (LWE)</dfn></dt>
<dd>A computational problem involving noisy linear equations over finite fields. Its hardness underpins lattice-based PQC schemes including Kyber and Dilithium.</dd>

<dt><dfn>Area-Delay Product (ADP)</dfn></dt>
<dd>A hardware efficiency metric combining silicon area (resource usage) with latency (delay). Lower ADP indicates a more efficient design.</dd>

<dt><dfn>Harvest Now, Decrypt Later (HNDL)</dfn></dt>
<dd>An adversarial strategy of collecting encrypted data today for decryption when quantum computers become available. Makes migration urgency independent of quantum computer timeline.</dd>

<dt><dfn>Crypto-agility</dfn></dt>
<dd>The architectural property enabling cryptographic algorithms to be replaced without redesigning or redeploying the system. Essential for PQC migration given the field's immaturity.</dd>
</dl>

### C. Literature Analysis Summary

<figure markdown="1">

| Paper          | Year | Type         | Key Contribution                 | Evidence Quality         |
| :------------- | :--- | :----------- | :------------------------------- | :----------------------- |
| He et al.      | 2024 | Experimental | FPGA accelerators for HQC/BIKE   | High (ACM, benchmarked)  |
| Kavitha et al. | 2025 | Conceptual   | Hybrid QC/PQC framework          | Low (no implementation)  |
| Tiwari et al.  | 2024 | Survey       | Quantum threat tutorial          | Medium (IEEE conference) |
| Sharma et al.  | 2025 | Conceptual   | NIST PQC + QNN framework         | Low (weak rigour)        |
| Monroe         | 2023 | Journalistic | NIST process + expert interviews | Medium (CACM)            |

<figcaption>Table A1: Summary of reviewed literature for the theoretical foundations domain.</figcaption>
</figure>

### D. SEO, GEO, and AEO Optimisation Notes

**Target keywords:** post-quantum cryptography foundations, lattice-based cryptography, code-based PQC hardware acceleration, CRYSTALS-Kyber, CRYSTALS-Dilithium, quantum threat RSA, Shor's algorithm cryptography, crypto-agility, hybrid quantum post-quantum, NIST PQC standards.

**Structured data:** HowTo schema implemented for PQC primitive evaluation workflow. FAQ schema covers the five most common search queries related to post-quantum cryptographic theory. Article schema with author attribution and citation metadata.

**Internal linking:** Cross-linked to companion PQC migration and deployment articles, and to the representation learning / Hilbert spaces article for mathematical foundations context.

</details>
