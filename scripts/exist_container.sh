#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Checking if the container aqua-registry exists" >&2
docker ps -a --filter "name=aqua-registry" --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null
