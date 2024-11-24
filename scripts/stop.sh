#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"
container_name=$container
if [ "${1:-}" = windows ]; then
	container_name=$container_windows
fi

if bash scripts/exist_container.sh "$container"; then
	docker stop -t 1 "$container"
fi
