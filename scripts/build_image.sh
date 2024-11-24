#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"

cp aqua-policy.yaml docker
docker build -t "$image" docker
mkdir -p .build
cp docker/Dockerfile .build
