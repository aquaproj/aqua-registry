#!/usr/bin/env bash

set -euo pipefail

docker build -t aquaproj/aqua-registry .

if docker ps -a --filter "name=aqua-registry" --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null; then
	if docker ps -a --filter "name=aqua-registry" --filter status=running --format "{{.Names}}" | grep -E "^aqua-registry$" >/dev/null; then
		docker start aqua-registry
	fi
else
	token="${AQUA_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"
	envs=""
	if [ -n "$token" ]; then
		envs="-e GITHUB_TOKEN=$token"
	fi
	# shellcheck disable=SC2086
	docker run -d --name aqua-registry -v "$PWD:/aqua-registry" $envs aquaproj/aqua-registry tail -f /dev/null
fi
