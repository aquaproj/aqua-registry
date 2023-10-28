#!/usr/bin/env bash

set -eu

token="${AQUA_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"
envs=""
if [ -n "$token" ]; then
	envs="-e GITHUB_TOKEN=$token"
fi

# shellcheck disable=SC2086
docker run -d --name aqua-registry \
	-v "$PWD:/aqua-registry" $envs aquaproj/aqua-registry \
	tail -f /dev/null
