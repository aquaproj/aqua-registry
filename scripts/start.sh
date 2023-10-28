#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Building the docker image aquaproj/aqua-registry" >&2
docker build -t aquaproj/aqua-registry .

if ! bash scripts/exist_container.sh; then
	echo "[INFO] Creaing a container aqua-registry" >&2
	bash scripts/run.sh
	exit 0
fi

if bash scripts/is_container_running.sh; then
	if bash scripts/check_image.sh; then
		echo "[INFO] Dockerfile isn't updated" >&2
		exit 0
	fi
	echo "[INFO] Dockerfile is updated, so the container aqua-registry is being recreated" >&2
	bash scripts/remove_container.sh
	bash scripts/run.sh
	exit 0
fi

if bash scripts/check_image.sh; then
	echo "[INFO] Dockerfile isn't updated" >&2
	echo "[INFO] Starting the container aqua-registry" >&2
	docker start aqua-registry
	exit 0
fi

echo "[INFO] Dockerfile is updated, so the container aqua-registry is being recreated" >&2
bash scripts/remove_container.sh
bash scripts/run.sh
