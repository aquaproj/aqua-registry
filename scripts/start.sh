#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/var.sh"
container_name=$container
if [ "${1:-}" = windows ]; then
	container_name=$container_windows
fi

info() {
	echo "[INFO] $*" >&2
}

if ! bash scripts/is_build_image.sh; then
	info "Building the docker image $image"
	bash scripts/build_image.sh
fi

if ! bash scripts/exist_container.sh "$container_name"; then
	info "Creating a container $container_name"
	bash scripts/run.sh "$container_name"
	exit 0
fi

if bash scripts/is_container_running.sh "$container_name"; then
	if bash scripts/check_image.sh "$container_name"; then
		info "Dockerfile isn't updated"
		exit 0
	fi
	info "Dockerfile is updated, so the container $container_name is being recreated"
	bash scripts/remove_container.sh "$container_name"
	bash scripts/run.sh "$container_name"
	exit 0
fi

if bash scripts/check_image.sh "$container_name"; then
	info "Dockerfile isn't updated"
	info "Starting the container $container_name"
	docker start "$container_name"
	exit 0
fi

info "Dockerfile is updated, so the container $container_name is being recreated"
bash scripts/remove_container.sh "$container_name"
bash scripts/run.sh "$container_name"
