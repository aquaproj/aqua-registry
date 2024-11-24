#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"

if ! docker inspect "$image" >/dev/null; then
	# image doesn't exist
	exit 1
fi

if [ ! -f .build/Dockerfile ]; then
	exit 1
fi

diff -q docker/Dockerfile .build/Dockerfile
