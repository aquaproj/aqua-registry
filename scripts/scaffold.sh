#!/usr/bin/env bash

set -euxo pipefail

pkg=$1

bash scripts/start.sh

if [ -d "pkgs/$pkg" ]; then
	rm -R "pkgs/$pkg"
fi

docker exec -ti -w /aqua-registry aqua-registry aqua policy allow
docker exec -ti -w /aqua-registry aqua-registry aqua i -l
docker exec -ti -w /aqua-registry aqua-registry aqua-registry scaffold "$pkg"

cmdx t "$pkg"
