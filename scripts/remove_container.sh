#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"
if [ "${1:-}" = windows ]; then
	container=$container_windows
fi

if bash scripts/exist_container.sh "$container"; then
	docker stop -t 1 "$container"
	docker rm "$container"
fi
