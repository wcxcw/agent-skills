#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${ROOT_DIR}/plugins/agent-skills"
CACHE_PARENT="${CODEX_HOME:-${HOME}/.codex}/plugins/cache/addy-agent-skills/agent-skills"
CACHE_DIR="${CACHE_PARENT}/1.0.0"
INSTALL_CACHE=false

if [ "${1:-}" = "--cache" ] || [ "${1:-}" = "--install-cache" ]; then
  INSTALL_CACHE=true
elif [ "${1:-}" != "" ]; then
  echo "Usage: bash scripts/sync-codex-plugin.sh [--cache]" >&2
  exit 2
fi

echo "Syncing Codex plugin mirror..." >&2

mkdir -p "${PLUGIN_DIR}"

rm -rf "${PLUGIN_DIR}/skills" "${PLUGIN_DIR}/references"
cp -R "${ROOT_DIR}/skills" "${PLUGIN_DIR}/skills"
cp -R "${ROOT_DIR}/references" "${PLUGIN_DIR}/references"

find "${PLUGIN_DIR}/skills" -name 'SKILL.md' -print0 | while IFS= read -r -d '' file; do
  perl -0pi -e 's#`references/#`../../references/#g; s#\]\(references/#](../../references/#g' "${file}"
done

if [ -f "${PLUGIN_DIR}/skills/idea-refine/SKILL.md" ]; then
  perl -0pi -e 's#/mnt/skills/user/idea-refine/scripts/idea-refine\.sh#scripts/idea-refine.sh#g' \
    "${PLUGIN_DIR}/skills/idea-refine/SKILL.md"
fi

echo "Codex plugin mirror synced at ${PLUGIN_DIR}" >&2

if [ "${INSTALL_CACHE}" = true ]; then
  echo "Installing Codex plugin cache..." >&2
  mkdir -p "${CACHE_PARENT}"
  rm -rf "${CACHE_DIR}"
  cp -R "${PLUGIN_DIR}" "${CACHE_DIR}"
  echo "Codex plugin cache installed at ${CACHE_DIR}" >&2
fi
