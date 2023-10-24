#!/usr/bin/env bash

set -euo pipefail

pkg=$1

docker build -t aquaproj/aqua-registry .

if docker ps -a --filter "name=aqua-registry" --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null; then
	if docker ps -a --filter "name=aqua-registry" --filter status=running --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null; then
		docker start aqua-registry
	fi
else
	docker run -d --name aqua-registry aquaproj/aqua-registry tail -f /dev/null
fi

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
