#!/usr/bin/env bash

set -eu

pkg=$1
cmd=$2
limit=$3

opts=""
if [ -n "$cmd" ]; then
	opts="-cmd $cmd"
fi
if [ -n "$limit" ]; then
	opts="$opts -limit $limit"
fi

mkdir -p "pkgs/$pkg"
# shellcheck disable=SC2086
docker exec -ti -w /workspace aqua-registry bash -c "rm pkg.yaml 2>/dev/null || :"
docker exec -ti -w /workspace aqua-registry bash -c "echo '# yaml-language-server: \$schema=https://raw.githubusercontent.com/aquaproj/aqua/main/json-schema/registry.json' > registry.yaml"
docker exec -ti -w /workspace aqua-registry bash -c "aqua gr $opts --out-testdata pkg.yaml \"$pkg\" >> registry.yaml"
docker cp "aqua-registry:/workspace/pkg.yaml" "pkgs/$pkg/pkg.yaml"
docker cp "aqua-registry:/workspace/registry.yaml" "pkgs/$pkg/registry.yaml"
