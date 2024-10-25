#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"
if bash scripts/exist_container.sh; then
	docker stop -t 1 "$container"
	docker rm "$container"
fi

if bash scripts/exist_container.sh "$container_windows"; then
	docker stop -t 1 "$container_windows"
	docker rm "$container_windows"
fi
