.PHONY: help bootstrap install start stop restart build clean serve seo-auto

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
	@echo "  build        - Build static site"
	@echo "  seo-auto     - Generate auto SEO/AEO/GEO vocabulary from posts"
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
	@echo "Generating automatic SEO vocabulary and post Q&A profile..."
	ruby scripts/generate_seo_auto.rb
	@echo "✓ SEO auto data updated (_data/seo_auto.yml)"

build: seo-auto
	@echo "Building Jekyll site..."
	$(JEKYLL) build
	@echo "✓ Build complete (output in _site/)"

serve: seo-auto
	@RUN_PORT=`$(FIND_FREE_PORT)`; \
	RUN_LR_PORT=`$(FIND_FREE_LIVERELOAD_PORT)`; \
	echo "Starting Jekyll dev server (foreground) on http://$(HOST):$$RUN_PORT..."; \
	$(JEKYLL) serve --host $(HOST) --port $$RUN_PORT --livereload --livereload-port $$RUN_LR_PORT

clean:
	@echo "Removing generated site..."
	rm -rf _site .jekyll-cache .jekyll-metadata
	@echo "✓ Clean complete"

.DEFAULT_GOAL := help
