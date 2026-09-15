#!/usr/bin/env bash
set -euo pipefail

# Code-server listens on 0.0.0.0 so it can be reached from the container host.
CODE_SERVER_BIND_ADDR="${CODE_SERVER_BIND_ADDR:-0.0.0.0:8080}"
WORKSPACE="${DEFAULT_WORKSPACE:-/home/coder/project}"

mkdir -p "$WORKSPACE"

exec code-server \
  --bind-addr "$CODE_SERVER_BIND_ADDR" \
  "$WORKSPACE"
