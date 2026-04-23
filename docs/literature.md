---
layout: literature
title: "Knowledge Space: Discover Research Papers and Scholarly Literature"
nav_title: "Literature"
permalink: /literature/
image: /assets/images/knowledge-space-research-discovery.png
description: "Explore recent research papers and scholarly literature live by keyword, domain, and focus area. Fetches from OpenAlex and Crossref with configurable filters."
keywords: "research paper discovery, live literature search, how to find research papers online, academic paper aggregator, open knowledge explorer, OpenAlex works search, Crossref academic search, data science literature, LLM governance research papers, data provenance papers, preprint tracker, supply chain security research, free academic paper search"
catchwords: "discovery, literature, knowledge, research, papers, preprints, open science, collaboration, AI, engineering, governance, provenance, OpenAlex, Crossref, science"
intro: "Discover live research papers and preprints across science, engineering, and AI governance by keyword and focus domain, drawn from OpenAlex and Crossref, with no persistence of fetched literature records."
---

## Your Window Into Open Research

Knowledge Space connects you directly to recent research papers and preprints across science, engineering, AI, and governance, fetched live from trusted open academic APIs the moment you search. Choose a preconfigured focus domain, enter your own keywords, select your sources, and explore paginated results instantly. No account required. Fetched literature records are not stored in application-level persistent storage; limited browser-side session state may be used for security and rate protection.

This is a collaborative discovery layer built for practitioners, researchers, and curious minds. Coverage and metadata quality reflect each provider's indexing cadence: results from OpenAlex and Crossref naturally complement each other, offering a richer cross-sectional view of the research landscape than any single source provides alone.

Cookie and consent controls apply to this page. Literature search functionality remains available whether or not optional analytics is enabled. Analytics events for interactions are only sent after analytics consent is granted via Cookie Preferences.

Informational and educational use only, not legal advice. Legal obligations vary by jurisdiction and mandatory local statutory, consumer, and data protection rights remain unaffected. The site operator governs first-party site operations. Hosting and analytics vendors may act as processors or service providers where they process data on the operator's instructions, or as independent controllers where they determine their own purposes. External literature APIs independently control their own datasets, licensing terms, and processing activities.

Review full data-handling details in [Privacy, Cookies and Data Protection]({{ '/legal/privacy-cookies-data-protection/' | relative_url }}).

{% include views/literature-search.html %}

## Frequently Asked Questions

### How does Knowledge Space work?

Select a research focus domain or enter your own keywords, choose your sources, and click Search Literature. Knowledge Space fetches recent papers and preprints in real time from the APIs you selected, filters by your keywords and match mode, and returns paginated results ready to explore.

### Which sources does this tool search?

The tool queries two open academic APIs: OpenAlex (a broad scholarly works index covering journals and conference papers) and Crossref (a DOI registration and metadata service). Each brings distinct coverage and indexing depth, so combining them typically yields a fuller picture.

### How are keywords matched against papers?

Matching runs against each record's title and abstract. "All keywords must match" narrows results to items where every keyword appears; "Any keyword may match" broadens results to items containing at least one keyword. Switching modes is the fastest way to widen a narrow search.

### Is any data stored when I search?

Fetched literature records are not stored in application-level persistent storage. Limited browser-side session state may be used for security and rate protection during your session. Normal operational logs from hosting, edge, or analytics services may still apply independently under their own policies.

### Will search still work if I reject analytics cookies?

Yes. Search and result browsing remain available. Rejecting analytics only stops optional GA4 or GTM usage measurement events for page interactions and search activity.

### How do I change cookie preferences later?

Use the **Cookie Preferences** control in the site footer or open [Cookie Preferences]({{ '/legal/privacy-cookies-data-protection/#cookie-preferences-and-consent-management' | relative_url }}) from the legal page.

### Why do result counts vary by source?

API coverage, indexing frequency, metadata completeness, and availability differ across providers. OpenAlex and Crossref emphasize broad scholarly metadata, and publication typing may vary by source. Combining both sources usually yields broader and more resilient discovery coverage than relying on one source alone.

### Is this legal advice or a professional recommendation?

No. Knowledge Space is an informational research-discovery tool only, not legal advice or a professional recommendation. For jurisdiction-specific legal or compliance decisions, consult qualified counsel in the relevant jurisdiction. Mandatory local consumer and data protection rights remain fully unaffected.
