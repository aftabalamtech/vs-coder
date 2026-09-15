#!/usr/bin/env bash
set -euo pipefail

CODE_SERVER_BIND_ADDR="${CODE_SERVER_BIND_ADDR:-0.0.0.0:8080}"
WORKSPACE="${DEFAULT_WORKSPACE:-/home/coder/project}"

# Keep the official code-server container entrypoint in the startup path.
# It initializes fixuid, ENTRYPOINTD hooks, dumb-init, and finally launches
# code-server. Authentication is intentionally left to code-server so that
# PASSWORD/HASHED_PASSWORD retain their native precedence and behavior.
mkdir -p "$WORKSPACE"

exec /usr/bin/entrypoint.sh \
  --bind-addr "$CODE_SERVER_BIND_ADDR" \
  --auth password \
  "$WORKSPACE"
