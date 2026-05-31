.PHONY: help qa-setup qa-install qa-model qa-analyse qa-review qa-validate qa-validate-batch qa-batch qa-review-batch lr-review lr-review-batch qa-clean

# ──────────────────────────────────────────────────────────────
# Qualitative Data Analysis & Systematic Literature Review Pipeline
# ──────────────────────────────────────────────────────────────

QA_DIR     := scripts/qualitative_analysis
QA_VENV    := $(QA_DIR)/.venv
QA_PYTHON  := $(QA_VENV)/bin/python
QA_PIP     := $(QA_VENV)/bin/pip
QA_SPACY   := en_core_web_sm
QA_OUTPUT  := reports/qualitative_analysis

# Default PDF — override with: make qa-analyse PDF=path/to/paper.pdf
PDF        ?=
# Directory for batch processing
PDFS       ?=
# SLR output directory
SLR_OUTPUT ?= reports/slr

help: ## Show this help
	@echo ""
	@echo "QDA–SLR Consolidated Literature Review Pipeline"
	@echo "================================================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-18s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make qa-setup                            # One-time setup (venv + deps + model)"
	@echo "  make qa-analyse PDF=paper.pdf            # Run QDA pipeline on a paper"
	@echo "  make qa-review PDF=paper.pdf             # Full QDA + SLR consolidated review"
	@echo "  make qa-validate PDF=paper.pdf           # Validate QDA output quality"
	@echo "  make qa-batch PDFS=resources/papers/     # Batch QDA on all PDFs in directory"
	@echo "  make qa-review-batch PDFS=resources/papers/ # Batch QDA + SLR on all PDFs"
	@echo "  make lr-review PDF=paper.pdf             # Literature review essay (single)"
	@echo "  make lr-review-batch PDFS=resources/papers/ # Literature review essays (batch)"
	@echo ""

# ── Setup targets ────────────────────────────────────────────

qa-setup: qa-install qa-model ## Full one-time setup (venv, dependencies, spaCy model)
	@echo "✓ Setup complete. Run: make qa-analyse PDF=your_paper.pdf"

qa-install: ## Create venv and install Python dependencies
	@echo "→ Creating virtual environment at $(QA_VENV)..."
	@python3 -m venv $(QA_VENV)
	@$(QA_PIP) install --upgrade pip -q
	@echo "→ Installing dependencies..."
	@$(QA_PIP) install -r $(QA_DIR)/requirements.txt
	@echo "✓ Dependencies installed."

qa-model: ## Download spaCy language model
	@echo "→ Installing spaCy model: $(QA_SPACY)..."
	@$(QA_PIP) install $(QA_SPACY)@https://github.com/explosion/spacy-models/releases/download/$(QA_SPACY)-3.8.0/$(QA_SPACY)-3.8.0-py3-none-any.whl -q
	@echo "✓ Model ready."

qa-model-lg: ## Download larger spaCy model for better clustering
	@$(QA_PIP) install en_core_web_lg@https://github.com/explosion/spacy-models/releases/download/en_core_web_lg-3.8.0/en_core_web_lg-3.8.0-py3-none-any.whl
	@echo "✓ Large model ready. Use: make qa-analyse PDF=paper.pdf QA_MODEL=en_core_web_lg"

# ── Analysis targets ─────────────────────────────────────────

QA_MODEL   ?= $(QA_SPACY)
QA_JSON    ?=
QA_FLAGS   := --spacy-model $(QA_MODEL) --output $(QA_OUTPUT)

ifdef QA_JSON
QA_FLAGS   += --json
endif

qa-analyse: _qa-check-pdf ## Analyse a PDF (set PDF=path/to/file.pdf)
	@mkdir -p $(QA_OUTPUT)
	@$(QA_PYTHON) $(QA_DIR)/analyse_paper.py "$(PDF)" $(QA_FLAGS)

_qa-check-pdf:
ifndef PDF
	$(error PDF is required. Usage: make qa-analyse PDF=path/to/paper.pdf)
endif
	@test -f "$(PDF)" || (echo "Error: File not found: $(PDF)" && exit 1)

# ── Consolidated QDA–SLR Review ──────────────────────────────

qa-review: _qa-check-pdf qa-analyse qa-validate ## Full QDA + SLR per-paper review (set PDF=path/to/file.pdf)
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  QDA–SLR Per-Paper Review Pipeline"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@echo "Phase 1: QDA pipeline ✓ (complete)"
	@echo "Phase 2: Quality validation ✓ (complete)"
	@echo "Phase 3: Generating SLR report (from PDF)..."
	@echo ""
	$(QA_PYTHON) $(QA_DIR)/generate_slr.py --pdf "$(PDF)" --output "$(SLR_OUTPUT)"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  Pipeline complete."
	@echo "  QDA report: $(QA_OUTPUT)/"
	@echo "  SLR report: $(SLR_OUTPUT)/"
	@echo "═══════════════════════════════════════════════════════════"

# ── Quality Validation ───────────────────────────────────────

qa-validate: _qa-check-pdf ## Validate QDA output meets quality gates (set PDF=path/to/file.pdf)
	@echo "→ Validating QDA output quality gates..."
	@$(QA_PYTHON) $(QA_DIR)/validate_report.py --single "$(PDF)" "$(QA_OUTPUT)"

qa-validate-batch: ## Validate all QDA reports in output directory
	@echo "→ Validating all QDA reports in $(QA_OUTPUT)/..."
	@$(QA_PYTHON) $(QA_DIR)/validate_report.py --batch "$(QA_OUTPUT)"

# ── Batch Processing ─────────────────────────────────────────

qa-batch: ## Run QDA + validate on all PDFs in a directory (set PDFS=path/to/dir/)
ifndef PDFS
	$(error PDFS is required. Usage: make qa-batch PDFS=path/to/directory/)
endif
	@echo "→ Batch QDA processing: $(PDFS)"
	@mkdir -p $(QA_OUTPUT)
	@count=0; \
	for pdf in "$(PDFS)"/*.pdf; do \
		if [ -f "$$pdf" ]; then \
			echo ""; \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
			echo "  Processing: $$(basename "$$pdf")"; \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
			if $(QA_PYTHON) $(QA_DIR)/analyse_paper.py "$$pdf" $(QA_FLAGS); then \
				count=$$((count+1)); \
				$(QA_PYTHON) $(QA_DIR)/validate_report.py --single "$$pdf" "$(QA_OUTPUT)"; \
			fi; \
		fi; \
	done; \
	echo ""; \
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
	echo "  Batch complete: $$count papers analysed."; \
	echo "  Reports: $(QA_OUTPUT)/"; \
	echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
	echo ""; \
	echo "→ Running batch validation summary..."; \
	$(QA_PYTHON) $(QA_DIR)/validate_report.py --batch "$(QA_OUTPUT)" || \
		echo "  (Validation warnings are non-blocking for batch pipeline)"

qa-review-batch: qa-batch ## Full QDA + SLR per-paper review on all PDFs in a directory (set PDFS=path/to/dir/)
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  QDA–SLR Per-Paper Batch Review Pipeline"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@echo "Phase 1: Batch QDA ✓ (complete)"
	@echo "Phase 2: Generating per-paper SLR reports (from PDFs)..."
	@echo ""
	$(QA_PYTHON) $(QA_DIR)/generate_slr.py \
		--pdf-dir "$(PDFS)" \
		--output "$(SLR_OUTPUT)"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  Pipeline complete."
	@echo "  QDA reports: $(QA_OUTPUT)/"
	@echo "  SLR reports: $(SLR_OUTPUT)/"
	@echo "═══════════════════════════════════════════════════════════"

# ── Literature Review Pipeline (Independent of QDA) ──────────

LR_OUTPUT  ?= reports/literature_reviews

lr-review: _qa-check-pdf ## Generate a per-paper literature review essay (set PDF=path/to/file.pdf)
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  Per-Paper Literature Review"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@mkdir -p $(LR_OUTPUT)
	$(QA_PYTHON) $(QA_DIR)/generate_literature_review.py --pdf "$(PDF)" --output "$(LR_OUTPUT)"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  Review complete. Output: $(LR_OUTPUT)/"
	@echo "═══════════════════════════════════════════════════════════"

lr-review-batch: ## Generate literature reviews for all PDFs in a directory (set PDFS=path/to/dir/)
ifndef PDFS
	$(error PDFS is required. Usage: make lr-review-batch PDFS=path/to/directory/)
endif
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  Per-Paper Literature Review — Batch"
	@echo "═══════════════════════════════════════════════════════════"
	@echo ""
	@mkdir -p $(LR_OUTPUT)
	$(QA_PYTHON) $(QA_DIR)/generate_literature_review.py --pdf-dir "$(PDFS)" --output "$(LR_OUTPUT)"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════"
	@echo "  Batch complete. Output: $(LR_OUTPUT)/"
	@echo "═══════════════════════════════════════════════════════════"

# ── Maintenance ──────────────────────────────────────────────

qa-clean: ## Remove QDA virtual environment
	@rm -rf $(QA_VENV)
	@echo "✓ Virtual environment removed."
