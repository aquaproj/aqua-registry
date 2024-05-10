#!/usr/bin/env bash

set -eu

container_name=${1:-aqua-registry}

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

if [ "$(uname)" = Linux ]; then
	opts+=" -u $(id -u -n):$(id -g -n) -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro"
fi

# shellcheck disable=SC2086
docker run $opts -d --name "$container_name" \
	-v "$PWD:/aqua-registry" $envs aquaproj/aqua-registry \
	tail -f /dev/null
