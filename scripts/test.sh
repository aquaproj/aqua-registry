#!/usr/bin/env bash

set -eu

pkg=$1
container_name=aqua-registry

docker cp "pkgs/$pkg/pkg.yaml" "$container_name:/workspace/pkg.yaml"
docker cp "pkgs/$pkg/registry.yaml" "$container_name:/workspace/registry.yaml"

for os in linux darwin; do
	for arch in amd64 arm64; do
		if ! docker exec "$container_name" env AQUA_GOOS="$os" AQUA_GOARCH="$arch" aqua i; then
			echo "[ERROR] Build failed $os/$arch" >&2
			docker exec -ti "$container_name" env AQUA_GOOS="$os" AQUA_GOARCH="$arch" bash
			exit 1
		fi
	done
done

aqua exec -- aqua-registry gr
