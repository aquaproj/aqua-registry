#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"

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
docker exec -ti -w /workspace "$container" bash -c "rm pkg.yaml 2>/dev/null || :"
docker exec -ti -w /workspace "$container" bash -c "aqua gr $opts --out-testdata pkg.yaml \"$pkg\" > registry.yaml"
mkdir -p "pkgs/$pkg"
docker cp "$container:/workspace/pkg.yaml" "pkgs/$pkg/pkg.yaml"
docker cp "$container:/workspace/registry.yaml" "pkgs/$pkg/registry.yaml"
