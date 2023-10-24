#!/usr/bin/env bash

set -euo pipefail

docker build -t aquaproj/aqua-registry .

if docker ps -a --filter "name=aqua-registry" --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null; then
	if docker ps -a --filter "name=aqua-registry" --filter status=running --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null; then
		docker start aqua-registry
	fi
else
	docker run -d --name aqua-registry -v "$PWD:/aqua-registry" aquaproj/aqua-registry tail -f /dev/null
fi
