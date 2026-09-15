#!/usr/bin/env bash
set -euo pipefail

CODE_SERVER_BIND_ADDR="${CODE_SERVER_BIND_ADDR:-0.0.0.0:8080}"
WORKSPACE="${DEFAULT_WORKSPACE:-/home/coder/project}"
CONFIG_DIR="${CODE_SERVER_CONFIG_DIR:-${HOME}/.config/code-server}"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"

mkdir -p "$WORKSPACE" "$CONFIG_DIR"

# The upstream code-server image normally starts through its own entrypoint.
# This repository uses a custom entrypoint, so authentication must be written
# to code-server's config explicitly instead of relying on image-specific env
# processing.
if [[ -n "${HASHED_PASSWORD:-}" ]]; then
  AUTH_KEY="hashed-password"
  AUTH_VALUE="$HASHED_PASSWORD"
elif [[ -n "${PASSWORD:-}" ]]; then
  AUTH_KEY="password"
  AUTH_VALUE="$PASSWORD"
else
  echo "ERROR: Set PASSWORD or HASHED_PASSWORD in the container environment." >&2
  exit 1
fi

# Passwords must be single-line values. Escape single quotes for YAML.
if [[ "$AUTH_VALUE" == *$'\n'* || "$AUTH_VALUE" == *$'\r'* ]]; then
  echo "ERROR: PASSWORD/HASHED_PASSWORD must not contain newline characters." >&2
  exit 1
fi
AUTH_VALUE_YAML="${AUTH_VALUE//\'/\'\'}"

umask 077
cat > "${CONFIG_FILE}.tmp" <<EOF
bind-addr: ${CODE_SERVER_BIND_ADDR}
auth: password
${AUTH_KEY}: '${AUTH_VALUE_YAML}'
cert: false
EOF
mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

exec code-server \
  --config "$CONFIG_FILE" \
  --bind-addr "$CODE_SERVER_BIND_ADDR" \
  "$WORKSPACE"
