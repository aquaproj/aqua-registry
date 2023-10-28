#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Checking if the container aqua-regigistry is running" >&2
docker ps -a \
	--filter "name=aqua-registry" \
	--filter status=running \
	--format "{{.Names}}" |
	grep -E "^aqua-registry$" >/dev/null
