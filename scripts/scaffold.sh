#!/usr/bin/env bash

set -euxo pipefail

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

# shellcheck disable=SC2086
docker exec -ti -w /workspace aqua-registry bash -c "rm pkg.yaml || :"
docker exec -ti -w /workspace aqua-registry bash -c "aqua gr $opts --out-testdata pkg.yaml \"$pkg\" > registry.yaml"
mkdir -p "pkgs/$pkg"
docker cp "aqua-registry:/workspace/pkg.yaml" "pkgs/$pkg/pkg.yaml"
docker cp "aqua-registry:/workspace/registry.yaml" "pkgs/$pkg/registry.yaml"
