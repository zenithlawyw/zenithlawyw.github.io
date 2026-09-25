#!/usr/bin/env bash
# Regenerate PDFs from the Jekyll site using Puppeteer (headless Chrome).
# This produces PDFs with embedded fonts (~0.5-1.5 MB) instead of
# outlined vector paths (~5-10 MB) that browser print-to-PDF creates.
#
# Usage: ./shrink-pdfs.sh [--posts slug1,slug2]
#
# Prerequisites: npm install (puppeteer), Jekyll site builds.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SITE_DIR="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$SITE_DIR/docs"
PORT=4199
BASE_URL="http://localhost:${PORT}"

# Parse args
POSTS_FILTER=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --posts) POSTS_FILTER="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# Ensure puppeteer is available
if ! node -e "require('puppeteer')" 2>/dev/null; then
  echo "Installing puppeteer..."
  npm install --save-dev puppeteer 2>&1 | tail -3
fi

# Ensure Chrome is downloaded
if ! npx puppeteer browsers installed 2>/dev/null | grep -q "chrome"; then
  echo "Downloading Chrome for Puppeteer..."
  npx puppeteer browsers install chrome 2>&1 | tail -3
fi

# Start Jekyll server
echo "Starting Jekyll server on port ${PORT}..."
SERVER_PID=""
cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

cd "$DOCS_DIR"
bundle exec jekyll serve --port "$PORT" --no-watch --detach --quiet 2>/dev/null || \
  bundle exec jekyll serve --port "$PORT" --no-watch --quiet &
SERVER_PID=$!

# Wait for server
echo "Waiting for server..."
for i in $(seq 1 60); do
  if curl -s -o /dev/null "$BASE_URL" 2>/dev/null; then
    break
  fi
  sleep 2
done

if ! curl -s -o /dev/null "$BASE_URL" 2>/dev/null; then
  echo "Error: Jekyll server failed to start" >&2
  exit 1
fi
echo "Server ready."

# Run the Node script
POSTS_ARG=""
if [[ -n "$POSTS_FILTER" ]]; then
  POSTS_ARG="--posts $POSTS_FILTER"
fi

node "$SCRIPT_DIR/generate-pdfs.mjs" $POSTS_ARG

echo ""
echo "Done. PDFs are in $SCRIPT_DIR/"
