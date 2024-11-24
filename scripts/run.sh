#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/var.sh"
container_name=${1:-$container}

token="${AQUA_GITHUB_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -z "$token" ]; then
	echo "[INFO] Get a GitHub Access token by gh auth token" >&2
	# Ignore error
	token=$(aqua exec -- gh auth token) || :
fi
envs=""
if [ -n "$token" ]; then
	envs="-e GITHUB_TOKEN=$token"
fi

# https://github.com/aquaproj/aqua-registry/issues/20289
opts=""
if [ "$(uname)" = Linux ] && docker version | grep -q Podman; then
	opts="--privileged"
fi

# shellcheck disable=SC2086
docker run $opts -d --name "$container_name" \
	$envs "$image" \
	tail -f /dev/null
