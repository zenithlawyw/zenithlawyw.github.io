---
layout: post
last_modified_at: 2026-06-03
title: "Post-Quantum Cryptography: Theoretical Foundations and Reconceptualisation"
author: Zenith Law
description: "A systematic exploratory review of post-quantum cryptographic primitives (lattice-based, code-based, hash-based, and hybrid QC/PQC constructions) examining the mathematical foundations, hardware acceleration strategies, and reconceptualisation of security models for the quantum era."
permalink: /post-quantum-cryptography-theoretical-foundations-reconceptualisation
intro: "Quantum computers threaten to dismantle the public-key infrastructure that underpins digital commerce, governance, and communication. This article examines the theoretical foundations of post-quantum cryptography, from lattice and code-based constructions to hybrid quantum/classical defence models, and identifies the reconceptualisation of security models that the quantum transition demands."
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

RSA, ECDH, DSA. All three depend on problems that a fault-tolerant quantum computer solves in polynomial time. Shor's algorithm does not gradually weaken these schemes or shave bits off their security margins; it annihilates them outright {% include references/cite.html key="10543513" %}. The result is categorical collapse to plaintext-equivalent exposure.

When does this actually happen? Nobody agrees. A decade, perhaps several, and the estimates keep shifting. But focusing on when quantum computers arrive misframes the problem entirely, because "harvest now, decrypt later" inverts the chronology. Adversaries are already collecting encrypted traffic and storing it for future decryption {% include references/cite.html key="11325571" %}. State secrets with 50-year classification windows, genomic records that remain sensitive for a patient's lifetime, infrastructure blueprints for systems that will operate for decades: for these categories of data, the migration deadline has quietly passed while the industry was still debating timelines.

> **Mosca's Inequality:** If the time to migrate (T) plus the data sensitivity lifetime (D) exceeds the time until quantum capability arrives (Q), then the data is already at risk. $D + T > Q$ implies immediate action is required {% include references/cite.html key="10543513" %}.

### Symmetric Cryptography: A Relative Safe Harbour

Grover's algorithm provides a quadratic speedup for unstructured search, which in the brute-force model halves the effective bit-security of symmetric keys. AES-256, under this model, retains roughly 128 bits of security against a quantum adversary. That is still computationally infeasible. The precise cost depends on assumptions about Grover oracle depth, error correction overhead on actual quantum hardware, and parallelisation constraints, all of which remain open research questions {% include references/cite.html key="10543513" %}. But the practical conclusion is clear enough: worry about your public-key infrastructure first. Symmetric encryption is not the critical vulnerability here.

<figure markdown="1">

| Algorithm Family | Classical Security             | Quantum Vulnerability                        | Mitigation             |
| :--------------- | :----------------------------- | :------------------------------------------- | :--------------------- |
| RSA / DSA        | Integer factorisation hardness | Shor's algorithm (broken in polynomial time) | Replace with PQC       |
| ECC / ECDH       | Discrete logarithm hardness    | Shor's algorithm (broken in polynomial time) | Replace with PQC       |
| AES-256          | Brute-force resistance         | Grover: ~128-bit effective (idealised model) | Double key sizes       |
| SHA-256          | Collision resistance           | Grover provides quadratic speedup            | Increase output length |

<figcaption>Table 1: Quantum vulnerability of major cryptographic families and their respective mitigation strategies.</figcaption>
</figure>

## The Four PQC Algorithm Families

Post-quantum cryptography replaces the mathematical problems that Shor's algorithm breaks with alternatives believed to resist both classical and quantum attack. Four algorithm families have emerged as serious contenders, though their maturity varies enormously {% include references/cite.html key="10543513" %} {% include references/cite.html key="11325571" %}.

### Lattice-Based Cryptography

<dl>
<dt><dfn>Lattice problem</dfn></dt>
<dd>Finding the shortest or closest vector in a high-dimensional lattice. The Learning With Errors (LWE) and Module-LWE variants underpin CRYSTALS-Kyber (key encapsulation) and CRYSTALS-Dilithium (digital signatures).</dd>
</dl>

Among PQC families, lattice-based schemes come closest to drop-in replacements for classical public-key cryptography. They support encryption, key exchange, and digital signatures with key sizes and operation speeds that, while larger than RSA/ECC equivalents, remain practical on commodity hardware. NIST selected CRYSTALS-Kyber for key encapsulation and CRYSTALS-Dilithium as one of three standardised signature algorithms {% include references/cite.html key="11325571" %}.

The key size increase is real but manageable: a Kyber-768 public key weighs in at 1,184 bytes compared to 64 bytes for ECDH P-256. Whether that matters depends on the deployment context. For a TLS handshake on a modern server, the difference is negligible. For a constrained IoT sensor transmitting over a low-bandwidth radio link, it might not be. The deeper concern is that lattice security proofs rely on worst-case to average-case reductions whose tightness is still debated. The schemes work, the implementations are fast, but the theoretical guarantees are not as airtight as we might like.

### Code-Based Cryptography

<dl>
<dt><dfn>Code-based scheme</dfn></dt>
<dd>Built on the hardness of decoding random linear error-correcting codes. The McEliece cryptosystem (1978) is the oldest PQC candidate, and newer variants like HQC and BIKE use structured codes for improved efficiency.</dd>
</dl>

Code-based schemes have the longest track record in PQC. McEliece has survived over 45 years of cryptanalytic scrutiny, which is more than can be said for any lattice-based construction. The penalty is key size: a McEliece public key occupies roughly 1 MB, which makes it impractical for most communication protocols {% include references/cite.html key="10543513" %}. Newer code-based designs (HQC, BIKE) use structured codes to shrink keys substantially, but they trade the well-studied random-code hardness assumption for algebraic structure that could, in theory, be exploited.

He et al. tackle the hardware side of this problem {% include references/cite.html key="10.1145/3703837" %}. Their two sparse polynomial multiplication accelerators for HQC and BIKE achieve 56.84% and 80.25% lower area-delay product (ADP) than previous designs, which matters if code-based PQC is ever going to run on anything smaller than a server rack.
He et al. tackle the hardware side of this problem {% include references/cite.html key="10.1145/3703837" %}. Their two sparse polynomial multiplication accelerators for HQC and BIKE achieve 56.84% and 80.25% lower area-delay product (ADP) than previous designs, which matters if code-based PQC is ever going to run on anything smaller than a server rack.

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

Hash-based signatures sit at the conservative end of the PQC spectrum. Their security reduces entirely to hash function properties (collision resistance, pre-image resistance), which are well understood and survive Grover's speedup when output lengths are doubled. NIST selected SPHINCS+ (now SLH-DSA) as one of three standardised signature algorithms {% include references/cite.html key="11325571" %}.

The trade-off is not subtle. SPHINCS+-256s signatures can reach 49 KB, and signing is slower than lattice alternatives. For applications where signature size and signing speed are secondary to the strength of the underlying security assumption (think root-of-trust certificate signing, firmware attestation), that trade-off is worth making. For high-throughput TLS connections, probably not.

### Multivariate Cryptography

<dl>
<dt><dfn>Multivariate scheme</dfn></dt>
<dd>Based on the hardness of solving systems of multivariate polynomial equations over finite fields. Rainbow was a NIST finalist before being broken by a classical attack in 2022.</dd>
</dl>

The Rainbow break deserves attention because of what it reveals about the maturity of PQC as a field. Rainbow was a NIST Round 3 finalist, meaning it had survived multiple rounds of public evaluation by the international cryptographic community. Then Ward Beullens published an attack that recovered Rainbow secret keys "over the weekend on a laptop" {% include references/cite.html key="10.1145/3575664" %} {% include references/cite.html key="11325571" %}. Not with a quantum computer. With classical cryptanalysis. The Rainbow team acknowledged the attack and proposed moving to larger parameters, but the damage was done; NIST eliminated the scheme before final selection.

SIKE (Supersingular Isogeny Key Encapsulation) collapsed even more dramatically. Castryck and Decru broke it "in about one hour on a single core" {% include references/cite.html key="11325571" %} by exploiting torsion-point information in the SIDH protocol, building on a theorem by Kani from 1997. The technical mechanism (a genus-2 Richelot isogeny construction) is less important than the implication: a mathematical observation from over two decades earlier, sitting in the literature unnoticed, contained the seed of a complete break.

What should practitioners take from this? PQC algorithms are young, and the mathematical problems they rely on have received far less adversarial scrutiny than the integer factorisation problem of RSA. Building systems that can swap algorithms without a full redesign is not a nice-to-have. It is a survival requirement.

## Hardware Acceleration for Code-Based PQC

The practical viability of code-based PQC depends heavily on efficient hardware implementation. He et al. identify sparse polynomial multiplication as the computational bottleneck for HQC and BIKE {% include references/cite.html key="10.1145/3703837" %}. NIST selected HQC for standardisation in March 2025; BIKE was not selected.

Their contribution is twofold:

1. **Parallel Segment-based Accumulation (PSA):** Decomposes sparse polynomial multiplication into segment-level operations that can be parallelised across FPGA resources. The memory-based implementation achieves high throughput using block RAM for intermediate storage.

2. **Permutating-with-Power (PWP):** A memory-free alternative that eliminates block RAM dependency entirely, enabling deployment on FPGAs where RAM resources are reserved for other functions. Despite the constraint, PWP achieves even better ADP than PSA.

Both designs are generic across all HQC and BIKE security levels (128, 192, 256-bit equivalent), providing a reusable hardware primitive for the code-based PQC family.

### Practical Significance

If NIST standardises HQC or BIKE (both remain under evaluation as of mid-2026), accelerators like these become the implementation foundation for embedded systems, IoT gateways, and network appliances. Software-only PQC performance on resource-constrained hardware is often insufficient, and the gap between what software can deliver and what constrained environments demand is exactly where FPGA acceleration earns its complexity cost.

## Hybrid QC/PQC: Defence in Depth, or Wishful Layering?

## Hybrid QC/PQC: Defence in Depth, or Wishful Layering?

Kavitha et al. propose combining quantum key distribution (QKD) with PQC encryption as a defence-in-depth strategy {% include references/cite.html key="11011628" %}. The logic is appealing: QKD provides information-theoretic security grounded in physics, while PQC provides computational security on classical infrastructure. An attacker who needs to break _both_ faces a higher bar than either defence alone.
Kavitha et al. propose combining quantum key distribution (QKD) with PQC encryption as a defence-in-depth strategy {% include references/cite.html key="11011628" %}. The logic is appealing: QKD provides information-theoretic security grounded in physics, while PQC provides computational security on classical infrastructure. An attacker who needs to break _both_ faces a higher bar than either defence alone.

A caveat is warranted here. The Kavitha et al. proposal is conceptual. No prototype was built, no simulation was run, no performance data was collected. The architecture is plausible but entirely unvalidated, and no formal security model exists to prove that the combination actually provides strictly greater security than either component in isolation. The argument that "two layers must be better than one" sounds intuitive, but intuition is not proof.
A caveat is warranted here. The Kavitha et al. proposal is conceptual. No prototype was built, no simulation was run, no performance data was collected. The architecture is plausible but entirely unvalidated, and no formal security model exists to prove that the combination actually provides strictly greater security than either component in isolation. The argument that "two layers must be better than one" sounds intuitive, but intuition is not proof.

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

### Where Hybrid Might Make Sense

Despite the thin evidence base, the use cases with the strongest rationale are narrow and specific:

- **Government and military communications** where "harvest now, decrypt later" threats are existential and budgets can absorb quantum hardware costs
- **Financial infrastructure** where transaction integrity carries multi-decade legal significance
- **Critical national infrastructure** (power grids, telecommunications backbone) where compromise triggers cascading physical consequences

For typical enterprise applications, PQC alone is sufficient and far more practical. The hybrid approach adds engineering complexity, cost, and operational fragility that is difficult to justify unless the threat model genuinely demands physics-based key distribution.

## Reconceptualising Security Models

The quantum transition does not just swap one set of algorithms for another. It forces a rethinking of how security is defined, how it is measured, and how long any given defence can be trusted.

### Crypto-Agility as a Design Primitive

Classical cryptographic deployment operated on an assumption that now looks dangerously optimistic: algorithms would last decades. RSA-2048 was expected to remain secure until 2030 at a minimum. PQC algorithms have survived, at most, a few years of serious scrutiny. SIKE and Rainbow demonstrate that multi-year expert evaluation can still miss fatal weaknesses {% include references/cite.html key="10.1145/3575664" %}.

So algorithm replacement needs to become ordinary. Not an emergency. Not a migration project. A routine maintenance operation, like rotating certificates or patching dependencies. TLS 1.3 already supports algorithm negotiation with PQC extensions; hybrid certificates (PQ/T) allow dual-signing during transition periods; key encapsulation can be abstracted behind interfaces that support swapping. The engineering patterns exist. The organisational discipline to treat cryptographic primitives as replaceable modules, rather than load-bearing permanent infrastructure, does not.

### Layered Defence and System-Level Thinking

The old assumption that "one good algorithm is enough" does not hold when confidence in any single algorithm is lower than it was for RSA. Layered defence becomes rational: PQC for computational resistance, QKD where physics-based guarantees are justified by the threat model and budget, forward secrecy to contain the blast radius when a key is compromised, aggressive key rotation to limit exposure windows.

But here is the part that gets less attention than it should. The theoretical security of an algorithm means nothing if the implementation leaks timing information through a side channel, or the key management system stores secrets in a world-readable file, or the migration process itself introduces a compatibility gap that silently downgrades connections to classical algorithms. PQC algorithm research has outpaced deployment engineering by a wide margin {% include references/cite.html key="11325571" %}. The gap is understandable in a field this young. It is also the gap that will determine whether the transition succeeds or stalls at pilot stage.

## Research Gaps and Open Questions

Four areas stand out where the theoretical foundations remain incomplete or contested:

- **Tight security reductions for lattice-based schemes:** The worst-case to average-case reductions that underpin Kyber and Dilithium security proofs have gaps in tightness that affect concrete security parameter selection
- **Formal hybrid security models:** No rigorous framework exists for proving that hybrid QC/PQC systems provide security strictly greater than either component alone {% include references/cite.html key="11011628" %}
- **Quantum-resistant zero-knowledge proofs:** Identified by topic modelling as an emerging research area, but still lacking mature constructions suitable for standardisation {% include references/cite.html key="11325571" %}
- **Side-channel resistance:** Hardware implementations like HSPA focus on functional performance but do not address timing, power analysis, or electromagnetic emanation attacks

## Takeaways

The quantum threat to public-key cryptography is not a matter of degree. Shor's algorithm does not weaken RSA; it eliminates it. Migration means replacement, not optimisation, and the timeline for starting that replacement is governed by Mosca's inequality, not by when a sufficiently large quantum computer is built.

For most deployments, lattice-based schemes (Kyber, Dilithium) are the pragmatic starting point: best performance on commodity hardware, broadest library support, and NIST's endorsement. But pragmatic is not the same as permanent. SIKE and Rainbow both survived years of expert evaluation before classical (not quantum) attacks destroyed them. Lattice cryptography has received less adversarial attention than integer factorisation. Treat the current algorithm portfolio as provisional.

Code-based PQC is maturing faster than it might appear from a pure key-size perspective. The HSPA accelerators from He et al. demonstrate 57 to 80% ADP improvement on FPGA, which opens a pathway for HQC and BIKE in constrained environments where lattice schemes might not be the only viable option.

The hybrid QC/PQC concept from Kavitha et al. is intellectually attractive but practically unvalidated. No prototype exists; no formal security model proves the combination exceeds either component alone. For high-value targets where "harvest now, decrypt later" is an existential concern, the concept deserves further investigation, but treating a conceptual paper as deployment guidance would be premature.

One architectural decision matters more than any algorithm selection: crypto-agility. The ability to swap primitives without redesigning the system is what protects against the surprises that a young cryptographic field will inevitably produce.

---

## Questions on Algorithmic Foundations and Hardware

### What makes post-quantum cryptography different from quantum cryptography?

They solve different problems with different tools. Post-quantum cryptography uses classical algorithms, running on ordinary hardware, designed to resist attacks from quantum computers. Quantum cryptography (typically QKD) uses the physical properties of photons to distribute keys, which requires specialised quantum hardware and fibre-optic channels. PQC is about upgrading the maths; QKD is about changing the physics. Most organisations will deploy PQC. Very few will deploy QKD.

### Why were SIKE and Rainbow broken, and what does that tell us?

SIKE fell to a classical mathematical attack that exploited torsion-point information in the SIDH protocol, building on a theorem published by Kani in 1997. Rainbow was broken by Beullens' key-recovery attack, also entirely classical. Both had survived multiple rounds of NIST evaluation. The lesson is not that NIST's process failed; it is that PQC algorithms sit on mathematical foundations that have received far less adversarial attention than RSA or ECC. Expect more surprises. Design for algorithm replacement.

### Is AES-256 safe against quantum computers?

For all practical purposes, yes. Grover's algorithm halves the effective key length in the idealised brute-force model, reducing AES-256 to roughly 128-bit equivalent security against a quantum adversary. That level of resistance remains computationally infeasible with any foreseeable resources. The real cost of running Grover on actual quantum hardware (circuit depth, error correction, parallelisation limits) may push the effective security even higher. The genuine vulnerability in most systems is asymmetric cryptography, not AES.

### How does hardware acceleration change PQC deployment decisions?

Code-based PQC schemes like HQC and BIKE depend on sparse polynomial multiplication that is expensive in software. The FPGA accelerators from He et al. reduce the area-delay product by 57 to 80%, which makes these schemes viable candidates for embedded and IoT contexts where software-only performance would be prohibitive. Without that kind of hardware support, the practical PQC palette shrinks to lattice-based schemes almost by default.

---

## Technical Appendix

<details markdown="1" class="appendix-callout group">
{% include appendix-summary.html title="Evidence Boundaries, Source Credibility, and Technical Reference" %}

### Appendix Table of Contents

- [Provenance and Credibility of Cited Work](#provenance-and-credibility-of-cited-work)
- [A. Boundary Conditions on the Evidence](#a-boundary-conditions-on-the-evidence)
- [B. Glossary of Technical Terms](#b-glossary-of-technical-terms)
- [C. Source-by-Source Assessment](#c-source-by-source-assessment)

### Provenance and Credibility of Cited Work

This article is authored by [Zenith Law](/authors/zenith-law/) and synthesises findings from five peer-reviewed sources on post-quantum cryptographic primitives. The papers span IEEE conference proceedings, ACM transactions, and Communications of the ACM. He et al. (2024) provide peer-reviewed experimental results with FPGA benchmarks. Monroe (2023) draws on expert interviews with leading cryptographers including Bruce Schneier. Tiwari et al. (2024) and Sharma et al. (2025) provide survey-level coverage. Kavitha et al. (2025) present a conceptual hybrid framework without experimental validation.

**Retraction note:** Zhang (2019) on "Black Hole Keypad Compression" was retracted by IEEE Access ("accepted in error and will not be published in its final form"). Its claims contradict Shannon's foundational proof on one-time pad key length requirements and are excluded from this synthesis.

### A. Boundary Conditions on the Evidence

The hardware acceleration results from He et al. are FPGA-specific with no ASIC validation, and the performance figures apply to sparse polynomial multiplication in isolation rather than full cryptosystem operation. The hybrid QC/PQC analysis from Kavitha et al. is conceptual only; no prototype, simulation, or benchmark was produced, which limits its value to architectural inspiration rather than engineering guidance. Algorithm vulnerability assessments reflect the cryptanalytic state of the art at the time of the cited publications; subsequent attacks could invalidate any claim. NIST standardisation status reflects published standards as of mid-2026; the fourth-round evaluations of HQC and BIKE may alter the available algorithm portfolio.

### B. Glossary of Technical Terms

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
<dd>The architectural property enabling cryptographic algorithms to be replaced without redesigning or redeploying the system. Essential for PQC migration given the immaturity of the field.</dd>
</dl>

### C. Source-by-Source Assessment

<figure markdown="1">

| Paper          | Year | Type         | Key Contribution                 | Rigour and Limitations                                       |
| :------------- | :--- | :----------- | :------------------------------- | :----------------------------------------------------------- |
| He et al.      | 2024 | Experimental | FPGA accelerators for HQC/BIKE   | Peer-reviewed with FPGA benchmarks (ACM)                     |
| Kavitha et al. | 2025 | Conceptual   | Hybrid QC/PQC framework          | No prototype, simulation, or performance data                |
| Tiwari et al.  | 2024 | Survey       | Quantum threat tutorial          | IEEE conference; survey coverage, not original results       |
| Sharma et al.  | 2025 | Conceptual   | NIST PQC + QNN framework         | Weak methodological rigour                                   |
| Monroe         | 2023 | Journalistic | NIST process + expert interviews | CACM feature; expert sourcing but not peer-reviewed research |

<figcaption>Table A1: Summary of reviewed literature for the theoretical foundations domain.</figcaption>
</figure>

### D. SEO, GEO, and AEO Optimisation Notes

**Primary search terms:** post-quantum cryptography, lattice-based cryptography, CRYSTALS-Kyber, CRYSTALS-Dilithium, Shor's algorithm, crypto-agility, NIST PQC standards.

**Structured data:** HowTo and FAQ schemas are implemented. Article schema includes author attribution and citation metadata.

**Cross-references:** Linked to the companion PQC migration and sector deployment articles, and to the representation learning article for shared mathematical context.

</details>
