#!/usr/bin/env bash

set -euo pipefail

pkg=$1

docker cp "pkgs/$pkg/pkg.yaml" aqua-registry:/workspace/pkg.yaml
docker cp "pkgs/$pkg/registry.yaml" aqua-registry:/workspace/registry.yaml

for os in linux darwin windows; do
	for arch in amd64 arm64; do
		if ! docker exec aqua-registry env AQUA_GOOS="$os" AQUA_GOARCH="$arch" aqua i; then
			echo "[ERROR] Build failed $os/$arch" >&2
      docker exec -ti aqua-registry env AQUA_GOOS="$os" AQUA_GOARCH="$arch" bash
			exit 1
		fi
	done
done

aqua exec -- aqua-registry gr
