#!/usr/bin/env bash

set -euxo pipefail

pkg=$1
cmd=$2
limit=$3

bash scripts/start.sh

if [ -d "pkgs/$pkg" ]; then
	rm -R "pkgs/$pkg"
fi

docker exec -ti -w /aqua-registry aqua-registry aqua policy allow
docker exec -ti -w /aqua-registry aqua-registry aqua i -l

opts=""
if [ -n "$cmd" ]; then
  opts="-cmd $cmd"
fi
if [ -n "$limit" ]; then
  opts="$opts -limit $limit"
fi

# shellcheck disable=SC2086
docker exec -ti -w /aqua-registry aqua-registry aqua-registry scaffold $opts "$pkg"

cmdx t "$pkg"
