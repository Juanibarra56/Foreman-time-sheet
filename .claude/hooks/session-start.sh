#!/bin/bash
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

if [ -f package-lock.json ] || [ -f package.json ]; then
  if command -v npm >/dev/null 2>&1; then
    npm install --no-audit --no-fund
  fi
fi

if [ -f yarn.lock ]; then
  if command -v yarn >/dev/null 2>&1; then
    yarn install --non-interactive
  fi
fi

if [ -f pnpm-lock.yaml ]; then
  if command -v pnpm >/dev/null 2>&1; then
    pnpm install --frozen-lockfile=false
  fi
fi

if [ -f poetry.lock ] || ([ -f pyproject.toml ] && grep -q "^\[tool.poetry\]" pyproject.toml 2>/dev/null); then
  if command -v poetry >/dev/null 2>&1; then
    poetry install --no-interaction
  fi
elif [ -f uv.lock ] || ([ -f pyproject.toml ] && grep -q "^\[tool.uv\]" pyproject.toml 2>/dev/null); then
  if command -v uv >/dev/null 2>&1; then
    uv sync
  fi
elif [ -f requirements.txt ]; then
  if command -v pip >/dev/null 2>&1; then
    pip install -r requirements.txt
  fi
elif [ -f pyproject.toml ]; then
  if command -v pip >/dev/null 2>&1; then
    pip install -e . || true
  fi
fi

if [ -f Cargo.toml ] && command -v cargo >/dev/null 2>&1; then
  cargo fetch
fi

if [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  go mod download
fi

if [ -f Gemfile ] && command -v bundle >/dev/null 2>&1; then
  bundle install
fi

exit 0
