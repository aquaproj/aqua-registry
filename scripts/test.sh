#!/usr/bin/env bash

set -euo pipefail

pkg=$1
registry_path="pkgs/$pkg/registry.yaml"

docker cp "pkgs/$pkg/pkg.yaml" aqua-registry:/workspace/pkg.yaml
docker cp "$registry_path" aqua-registry:/workspace/registry.yaml

set +e
exists_cargo_type="$(grep --count --max-count=1 '^\s\+type: cargo$' "$registry_path")"
set -e

for os in linux darwin windows; do
	for arch in amd64 arm64; do
		if [[ "$exists_cargo_type" == "1" ]]; then
			docker exec aqua-registry env AQUA_GOOS="$os" AQUA_GOARCH="$arch" aqua remove "$pkg"
		fi
		if ! docker exec aqua-registry env AQUA_GOOS="$os" AQUA_GOARCH="$arch" aqua i; then
			echo "[ERROR] Build failed $os/$arch" >&2
			docker exec -ti aqua-registry env AQUA_GOOS="$os" AQUA_GOARCH="$arch" bash
			exit 1
		fi
	done
done

aqua exec -- aqua-registry gr
