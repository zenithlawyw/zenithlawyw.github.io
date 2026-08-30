---
layout: post
last_modified_at: 2026-08-29
title: "Methods and Techniques for Explaining Machine Learning Models"
author: Zenith Law
description: "A systematic examination of post-hoc explanation methods and inherently interpretable models, from gradient-based attribution to concept-based explanations, with critical analysis of their theoretical foundations and practical trade-offs."
permalink: /methods-techniques-explaining-ml-models
intro: "Four papers covering the full spectrum of explanation methods: the authoritative review of post-hoc methods with axiomatic foundations by Samek et al., the demonstration of explanation methods as model validation tools by Lapuschkin et al., the taxonomy of interpretation algorithms by Li et al., and the comprehensive survey of concept-based XAI by Poeta et al. Together they reveal that the choice of explanation method is not a technical detail but a substantive decision that shapes what can be learned about model behaviour."
image: /assets/images/methods-techniques-xai.png
hero:
  image: /assets/images/methods-techniques-xai.png
keywords: "XAI methods, post-hoc explanation techniques, gradient-based attribution, integrated gradients, layer-wise relevance propagation, LRP concept-based XAI, C-XAI methods, interpretable models, LIME SHAP comparison, explanation method taxonomy, deep learning interpretability, model-agnostic explanations"
catchwords: "explanation methods, post-hoc techniques, gradient attribution, LRP, concept-based XAI, Li taxonomy, model explanation, Clever Hans detection, explanation comparison, axiomatic foundations"
references_enabled: true
references_style: ieee
references_data_file: references
references:
  - 9369420
  - lapuschkin2019cleverhans
  - li2022interpretable
  - poeta2025concept
related_posts:
  - title: "What Does It Mean for AI to Be Explainable? Foundations of Interpretable ML"
    url: /foundations-interpretable-machine-learning
  - title: "Critical Perspectives and Limits of Current Explainability Methods"
    url: /critical-perspectives-limits-xai
categories:
  - Artificial Intelligence
  - Machine Learning
tags:
  - XAI methods
  - post-hoc explanations
  - model interpretability
  - concept-based XAI
  - deep learning
  - explanation techniques
  - gradient attribution
  - LRP
---

## Introduction

The [previous article](/foundations-interpretable-machine-learning) established what interpretability means. This article examines how it is achieved. Four papers survey the methodological literature from complementary angles: Samek et al. (2021){% include references/cite.html key="9369420" %} provide the authoritative technical review with axiomatic foundations; Lapuschkin et al. (2019){% include references/cite.html key="lapuschkin2019cleverhans" %} demonstrate explanation methods as model validation tools that reveal hidden failure modes; Li et al. (2022){% include references/cite.html key="li2022interpretable" %} organise interpretation algorithms into a coherent taxonomy and distinguish interpretations from interpretability as distinct concepts; and Poeta et al. (2025){% include references/cite.html key="poeta2025concept" %} survey the emerging field of concept-based XAI, which moves beyond raw feature attributions to human-meaningful concepts.

This article is not legal advice.

## Vocabulary for Explanation Methods

<dl>
  <dt><dfn>Post-hoc explanation</dfn></dt>
  <dd>Any method applied to an already-trained model to explain its predictions, without modifying the model itself. Post-hoc methods dominate practice because they can be applied to any existing model.</dd>

  <dt><dfn>Gradient-based attribution</dfn></dt>
  <dd>Methods that use the gradient of the model output with respect to input features to assign importance scores. Includes Saliency Maps, Integrated Gradients, Gradient × Input, and SmoothGrad. These methods satisfy useful axioms (sensitivity, implementation invariance) but can suffer from gradient saturation.</dd>

  <dt><dfn>Layer-wise Relevance Propagation (LRP)</dfn></dt>
  <dd>A propagation-based explanation method that redistributes the prediction output backward through the network layers using local conservation principles, producing relevance scores for each input feature. LRP produces qualitatively sharper heatmaps than gradient methods on vision tasks.</dd>

  <dt><dfn>Concept-based XAI (C-XAI)</dfn></dt>
  <dd>A class of methods that explain model decisions not in terms of raw input features but in terms of human-interpretable concepts (e.g., "stripes," "wheels," "glass"). These methods bridge the gap between low-level feature attributions and high-level human understanding.</dd>

  <dt><dfn>Clever Hans predictor</dfn></dt>
  <dd>A model that achieves high accuracy by exploiting spurious correlations in the training data rather than learning the intended decision strategy. Named after the horse that appeared to perform arithmetic but was actually responding to subtle human cues.</dd>

  <dt><dfn>Interpretation vs. interpretability</dfn></dt>
  <dd>Following Li et al. (2022){% include references/cite.html key="li2022interpretable" %}, interpretations are the outputs of explanation algorithms (attributions, explanations). Interpretability is the ability of a model to explain or to present its behaviour in understandable terms, an intrinsic property of the model. They are related but distinct: a model can be interpreted (explanations exist) without being highly interpretable in the sense that humans can readily understand its behaviour.</dd>
</dl>

---

## The Methodological Survey

### Samek et al. (2021): Axiomatic Foundations and Comparative Evaluation

Samek et al. provide the most systematic technical review of post-hoc explanation methods for deep neural networks {% include references/cite.html key="9369420" %}. Their contribution is threefold: establishing the theoretical foundations, conducting comparative evaluation, and distilling best practices.

**Theoretical foundations.** The survey consolidates the theoretical basis of common methods. Gradient-based techniques (saliency maps, Integrated Gradients, Gradient × Input) are understood through the axioms of sensitivity and implementation invariance established for Integrated Gradients, while Shapley-value methods inherit the game-theoretic axioms of efficiency, symmetry, and the dummy-player property. These axiom systems help distinguish method families even though most methods satisfy them only partially in practice.

Sensitivity and implementation invariance are not merely theoretical niceties. Sensitivity ensures that features that demonstrably affect the output receive non-zero attribution. Implementation invariance ensures that two models computing the same function produce the same attributions, regardless of architectural differences. Both properties make explanations more trustworthy, and their violation in some practical methods is a known limitation.

**Comparative evaluation.** The paper compares methods using sensitivity analysis (how much does the explanation change when the input is perturbed?) and faithfulness metrics (how well does the explanation predict model behaviour under feature removal?). The key finding: different methods produce substantially different explanations for the same prediction, and no single method dominates across all quality metrics.

**Best practices.** Through worked examples, the paper distils four recommendations for using explanations in practice: try different parameters of the explanation techniques, since a single preset can misleadingly weaken or strengthen a conclusion; unmask Clever Hans examples so that spurious strategies are identified rather than trusted; iteratively validate and improve the model using the evidence from explanations; and look at interactions to get deeper insights into how features combine rather than stopping at individual attributions.

### Lapuschkin et al. (2019): Explanations as Validation Tools

Lapuschkin et al. demonstrated that explanation methods are not just for understanding models but for validating them {% include references/cite.html key="lapuschkin2019cleverhans" %}. Their paper introduced the Clever Hans metaphor to XAI, showing that models can achieve high accuracy by exploiting spurious correlations invisible to standard metrics.

The key demonstrations of the paper:

- **Horse classification.** A Fisher vector classifier trained on PASCAL VOC 2007 relied primarily on a source tag present in about one-fifth of the horse images, not the horses themselves. Removing the tag weakened the decision, and inserting a source tag onto a car image changed the classification from car to horse. Accuracy metrics gave no indication of this failure.

- **Atari Pinball.** A deep network that achieved excellent scores in the Atari game Pinball learned to abuse the in-game nudging mechanism: it moved the ball to a high-scoring switch and then nudged the table so the ball passed over the switch repeatedly, entirely ignoring the flippers. It was a rational strategy for the simulator but would fail on a real machine that tilts after strong movement.

- **Atari Breakout.** In the game Breakout, relevance heatmaps tracked by training epoch showed the network progressively focusing on ball control, the paddle, and finally learning to dig tunnels at the corners of the playing field, a genuinely strategic behaviour also used by human players. The heatmaps distinguished this valid strategy from the Clever Hans behaviours above.

The paper also proposed spectral relevance analysis (SpRAy), which applies spectral clustering to explanation heatmaps to identify typical and atypical recurring patterns of model behaviour. SpRAy enables semi-automated detection of Clever Hans strategies on large datasets without requiring manual inspection of individual explanations, and revealed an additional padding artifact the researchers had missed by hand.

### Li et al. (2022): Distinguishing Interpretations from Interpretability

Li et al. address a conceptual confusion that pervades the XAI literature {% include references/cite.html key="li2022interpretable" %}. They distinguish between interpretations (the outputs of explanation algorithms) and interpretability (the intrinsic property of a model). The distinction matters because a model can produce interpretable outputs (attributions, saliency maps) without being interpretable in the sense that humans can reliably predict its behaviour.

The taxonomy of the paper is organised along three orthogonal dimensions rather than a single list of categories {% include references/cite.html key="li2022interpretable" %}:

1. **Representation of interpretations:** feature importance (attributions over input or intermediate features, e.g., LIME, saliency, SHAP-style scores), model response (examples generated or selected to probe model behaviour, e.g., counterfactuals), model rationale process (substituting an interpretable surrogate to reveal the decision path), and dataset (explaining how training samples influence the model).

2. **Model type:** model-agnostic methods that treat the model as a black box; methods for differentiable models such as neural networks; and specific-model methods restricted to particular architectures (CNNs, GANs, GNNs).

3. **Relation between algorithm and model:** closed-form (a formula is derived from the target model), composition (components obtained during training), dependence (operations built on the trained model), and proxy (a separately learned surrogate model).

The paper also reviews evaluation metrics for interpretation algorithms and connects interpretability to other model properties including adversarial robustness and learning from interpretations.

### Poeta et al. (2025): Concept-Based XAI

Poeta et al. survey a paradigm shift in XAI: moving from raw feature attributions to concept-based explanations {% include references/cite.html key="poeta2025concept" %}. Raw feature attributions (SHAP values, saliency maps) indicate which pixels or tabular features drove a prediction, but they do not tell the user what those features mean. Concept-based methods (C-XAI) explain predictions in terms of human-interpretable concepts: "the model classified this image as a bird because it detected wings, a beak, and feathers."

The paper analyses C-XAI methods along 13 dimensions grouped into three families: concept and explanation characteristics (how concepts are integrated into models, whether they are annotated, their type, and the form and scope of the explanation), the applicability of the method (data type, task, and network architecture), and the resources and evaluation conducted (data release, code availability, new metrics, human evaluation). From these dimensions it derives a taxonomy of nine C-XAI categories, distinguished chiefly by whether concepts are used only to explain an existing model (post-hoc) or during training (explainable by design), the specific type of concept used, and the required explanation.

Selection guidelines take the form of a small set of questions a practitioner answers in sequence: whether the model can be modified, whether annotated concepts are available, which task the explanation must serve, and what kind of unsupervised concepts are needed. This routes the practitioner to a suitable category based on their own constraints rather than on a fixed mapping from application domain.

---

## Synthesis: Method Choice Shapes What Can Be Known

Across these four papers, a clear pattern emerges. The choice of explanation method is not a technical detail. It determines what can be learned about the behaviour of the model and, consequently, what conclusions can be drawn about its reliability.

Gradient-based methods reveal which input features the model is sensitive to but not how it combines them. Perturbation methods reveal counterfactual behaviour (what would happen if this feature changed) but at high computational cost. Concept-based methods bridge the gap to human understanding but depend on the quality of the concept definitions.

The practitioner's challenge is to match the method to the question. If the question is "which pixels matter?" gradient methods suffice. If the question is "does the model rely on spurious correlations?" Clever Hans-style validation with multiple methods is essential. If the question is "can the reasoning of the model be communicated to a domain expert?" concept-based methods are necessary.

---

## Conclusion

Explanation methods operationalise the concept of interpretability examined in [What Does It Mean for AI to Be Explainable? Foundations of Interpretable ML](/foundations-interpretable-machine-learning). Samek et al. provide the technical foundations. Lapuschkin et al. show why these foundations matter for model validation. Li et al. organise the methodological literature and clarify what explanations can and cannot tell us. Poeta et al. point toward the future of concept-level explanations.

But the existence of these methods does not guarantee their reliability. The next article examines the critical perspectives and documented limitations that every practitioner must understand.

---

## Frequently Asked Questions

### How are explanation methods categorised in the XAI literature?

The dominant taxonomy, proposed by Li et al. (2022){% include references/cite.html key="li2022interpretable" %}, is three-dimensional rather than a single list of categories. It organises interpretation algorithms by the representation of the interpretation (feature importance, model response, model rationale process, dataset), the type of model addressed (model-agnostic, differentiable, specific model), and the relation between the algorithm and the model (closed-form, composition, dependence, proxy). Each algorithm is characterised by its position on all three dimensions.

### What distinguishes backpropagation-based methods from perturbation-based methods?

Backpropagation-based methods compute attributions through a single forward-backward pass and are computationally efficient but sensitive to gradient properties such as saturation and shattering. Perturbation-based methods observe output changes when inputs are modified and are more robust but require many forward passes, creating a computational cost that scales with the number of features.

### Why does Samek et al. argue for axiomatic foundations in XAI evaluation?

Samek et al.{% include references/cite.html key="9369420" %} argue that grounding explanation methods in axioms such as sensitivity, implementation invariance, and the Shapley properties provides a principled basis for comparing methods and reasoning about their behaviour that purely empirical evaluation on a single metric would miss. Axioms help detect failures and clarify what a method can and cannot be trusted to reveal, though no single axiom system fully characterises an explanation.

### How can explanation methods serve as model validation tools?

Lapuschkin et al. (2019){% include references/cite.html key="lapuschkin2019cleverhans" %} demonstrate that explanation methods can detect Clever Hans behaviour where models exploit spurious correlations invisible to accuracy metrics. Their spectral relevance analysis (SpRAy) clusters explanation heatmaps to reveal, for example, that a horse classifier relied on a source tag present in the images and that a Pinball agent cheated by abusing the nudging mechanism, making explanation methods a diagnostic tool rather than just a transparency device.

### What is concept-based XAI and how does it differ from feature attribution?

Concept-based XAI explains model decisions in terms of human-understandable concepts rather than raw features{% include references/cite.html key="poeta2025concept" %}. While feature attribution assigns importance scores to individual input dimensions such as pixels or words, concept-based methods identify whether the model recognises higher-level abstractions such as stripes, colour patterns, or medical indicators. This aligns explanations with how humans naturally reason.

<details markdown="1" class="appendix-callout group">
<summary>Appendix: Source Material</summary>

### Author and Source Credibility

| Source                   | Author profile             | Venue                   | Citation count | Tier          |
| ------------------------ | -------------------------- | ----------------------- | -------------- | ------------- |
| Samek et al. (2021)      | Fraunhofer HHI / TU Berlin | Proceedings of the IEEE | 2000+          | Authoritative |
| Lapuschkin et al. (2019) | Fraunhofer HHI / TU Berlin | Nature Communications   | 2000+          | Authoritative |
| Li et al. (2022)         | Baidu Research             | arXiv                   | 500+           | Comprehensive |
| Poeta et al. (2025)      | Polytechnic of Turin       | ACM Computing Surveys   | New (2025)     | Comprehensive |

### Corpus Reviewed

- Samek et al. (2021): 200+ references on post-hoc explanation methods
- Lapuschkin et al. (2019): Focused empirical study with 40+ references
- Li et al. (2022): Nearly 200 references on interpretation algorithms
- Poeta et al. (2025): Over 100 references on concept-based XAI

### Citability Snapshot

| Claim category                 | Count | Examples                                                                             |
| ------------------------------ | ----- | ------------------------------------------------------------------------------------ |
| Verified (empirical)           | 5     | Gradient methods satisfy axioms; Clever Hans detected in vision/RL; methods disagree |
| Verified (taxonomic consensus) | 3     | Li taxonomy; Poeta C-XAI taxonomy; Samek method classification                       |
| Inferred                       | 2     | Multiple methods should be used for validation; C-XAI bridges human-model gap        |
| Speculative                    | 1     | C-XAI will supplant raw feature attribution for human-facing explanations            |

</details>
