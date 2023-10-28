#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Checking if the container aqua-regigistry exists" >&2
docker ps -a --filter "name=aqua-registry" --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null
