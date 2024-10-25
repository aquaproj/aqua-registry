#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/var.sh"
container_name=${1:-$container}

echo "[INFO] Checking if the container $container_name is running" >&2
docker ps -a \
	--filter "name=$container_name" \
	--filter status=running \
	--format "{{.Names}}" |
	grep -E "^$container_name$" >/dev/null
