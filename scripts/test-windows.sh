#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/var.sh"

pkg=$1

docker cp "pkgs/$pkg/pkg.yaml" "$container_windows:/workspace/pkg.yaml"
docker cp "pkgs/$pkg/registry.yaml" "$container_windows:/workspace/registry.yaml"

for arch in amd64 arm64; do
	if ! docker exec "$container_windows" env AQUA_GOOS="windows" AQUA_GOARCH="$arch" aqua i; then
		echo "[ERROR] Build failed windows/$arch" >&2
		docker exec -ti "$container_windows" env AQUA_GOOS="windows" AQUA_GOARCH="$arch" bash
		exit 1
	fi
done
