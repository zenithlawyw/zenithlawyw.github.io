.PHONY: help bootstrap install start stop restart prebuild build publish clean serve seo-auto glossary-auto glossary-promote taxonomy-auto references-auto validate-faq validate-reference-dates validate-hero-images validate-editorial-depth

# Variables
BUNDLE := bundle exec
JEKYLL := $(BUNDLE) jekyll
PORT := 4000
HOST := localhost
PID_FILE := .jekyll.pid
LIVERELOAD_PORT ?= 35730

# Find an available HTTP port starting from PORT.
define FIND_FREE_PORT
PORT_CANDIDATE=$(PORT); \
while lsof -iTCP:$$PORT_CANDIDATE -sTCP:LISTEN >/dev/null 2>&1; do \
	PORT_CANDIDATE=$$((PORT_CANDIDATE + 1)); \
done; \
echo $$PORT_CANDIDATE
endef

define FIND_FREE_LIVERELOAD_PORT
PORT_CANDIDATE=$(LIVERELOAD_PORT); \
while lsof -iTCP:$$PORT_CANDIDATE -sTCP:LISTEN >/dev/null 2>&1; do \
	PORT_CANDIDATE=$$((PORT_CANDIDATE + 1)); \
done; \
echo $$PORT_CANDIDATE
endef

help:
	@echo "Jekyll Development Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  bootstrap    - Install dependencies (bundle install)"
	@echo "  install      - Alias for bootstrap"
	@echo "  start        - Start Jekyll dev server"
	@echo "  stop         - Stop Jekyll dev server"
	@echo "  restart      - Restart Jekyll dev server"
	@echo "  prebuild     - Run content generation scripts before build/publish"
	@echo "  build        - Build static site"
	@echo "  publish      - Run full publish pipeline (prebuild + production build)"
	@echo "  seo-auto     - Generate auto SEO/AEO/GEO vocabulary and FAQ extraction"
	@echo "  glossary-auto - Generate auto glossary terminology candidates"
	@echo "  glossary-promote - Promote approved auto glossary terms into glossary_terms.yml"
	@echo "  validate-faq  - Validate non-empty FAQ extraction for posts"
	@echo "  validate-hero-images - Validate unique hero image usage and badge compliance"
	@echo "  validate-editorial-depth POST=<post-path> - Validate editorial depth and human-voice policy"
	@echo "  validate-reference-dates - Validate reference accessed dates do not exceed post publication dates"
	@echo "  taxonomy-auto - Run all automated taxonomy extractors"
	@echo "  references-auto - Generate references data from BibTeX"
	@echo "  serve        - Start server and watch for changes (foreground)"
	@echo "  clean        - Remove generated _site directory"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Usage: make <target>"

bootstrap install:
	@echo "Installing Ruby dependencies..."
	bundle install
	@echo "✓ Bootstrap complete"

start:
	@if [ -f $(PID_FILE) ]; then \
		echo "✗ Server already running (PID: $$(cat $(PID_FILE)))"; \
		exit 1; \
	fi
	@RUN_PORT=`$(FIND_FREE_PORT)`; \
	RUN_LR_PORT=`$(FIND_FREE_LIVERELOAD_PORT)`; \
	echo "Starting Jekyll dev server on http://$(HOST):$$RUN_PORT..."; \
	$(JEKYLL) serve --host $(HOST) --port $$RUN_PORT --livereload --livereload-port $$RUN_LR_PORT > .jekyll.log 2>&1 & \
	echo $$! > $(PID_FILE)
	@echo "✓ Server started (PID: $$(cat $(PID_FILE)))"
	@sleep 2 && RUN_PORT=`$(FIND_FREE_PORT)` && echo "View site at: http://$(HOST):$$((RUN_PORT - 1))"

stop:
	@if [ -f $(PID_FILE) ]; then \
		PID=$$(cat $(PID_FILE)); \
		echo "Stopping Jekyll server (PID: $$PID)..."; \
		kill $$PID 2>/dev/null || true; \
		rm -f $(PID_FILE); \
		echo "✓ Server stopped"; \
	else \
		echo "✗ No running server found"; \
	fi

restart: stop start
	@echo "✓ Server restarted"

seo-auto:
	@echo "Generating automatic SEO/AEO/GEO vocabulary and FAQ extraction..."
	ruby scripts/generate_seo_auto.rb
	@echo "✓ SEO auto data updated (_data/seo_auto.yml)"

glossary-auto:
	@echo "Generating automatic glossary terminology candidates..."
	ruby scripts/generate_glossary_auto.rb
	@echo "✓ Glossary auto data updated (_data/glossary_auto.yml)"

glossary-promote:
	@echo "Promoting approved glossary candidates into canonical glossary terms..."
	ruby scripts/promote_glossary_approved.rb
	@echo "✓ Glossary approved-term promotion complete"

taxonomy-auto: seo-auto glossary-auto glossary-promote
	@echo "✓ Taxonomy extractors complete"

references-auto:
	@echo "Generating references data from BibTeX..."
	ruby scripts/generate_references_from_bibtex.rb
	@echo "✓ References generated (_data/references_generated.yml)"

validate-faq:
	@echo "Validating extracted FAQ questions for posts..."
	ruby scripts/validate_seo_questions.rb
	@echo "✓ FAQ validation passed"

validate-reference-dates:
	@echo "Validating reference accessed dates against publication dates..."
	ruby scripts/validate_reference_access_dates.rb
	@echo "✓ Reference date integrity validation passed"

validate-hero-images:
	@echo "Validating hero image uniqueness and branding compliance..."
	python3 scripts/validate_hero_images.py
	@echo "✓ Hero image validation passed"

validate-editorial-depth:
	@if [ -z "$(POST)" ]; then \
		echo "✗ Missing POST path. Usage: make -C docs validate-editorial-depth POST=_posts/<file>.md"; \
		exit 1; \
	fi
	@echo "Validating editorial depth and human-voice policy for $(POST)..."
	ruby scripts/validate_editorial_depth.rb "$(POST)"
	@echo "✓ Editorial depth validation passed"

prebuild: taxonomy-auto references-auto validate-faq validate-hero-images validate-reference-dates
	@echo "✓ Prebuild scripts complete"

build: prebuild
	@echo "Building Jekyll site..."
	$(JEKYLL) build
	@echo "✓ Build complete (output in _site/)"

publish: prebuild
	@echo "Publishing build (production settings)..."
	JEKYLL_ENV=production $(JEKYLL) build
	@echo "✓ Publish build complete (output in _site/)"

serve: prebuild
	@RUN_PORT=`$(FIND_FREE_PORT)`; \
	RUN_LR_PORT=`$(FIND_FREE_LIVERELOAD_PORT)`; \
	echo "Starting Jekyll dev server (foreground) on http://$(HOST):$$RUN_PORT..."; \
	$(JEKYLL) serve --host $(HOST) --port $$RUN_PORT --livereload --livereload-port $$RUN_LR_PORT

clean:
	@echo "Removing generated site..."
	rm -rf _site .jekyll-cache .jekyll-metadata
	@echo "✓ Clean complete"

.DEFAULT_GOAL := help
