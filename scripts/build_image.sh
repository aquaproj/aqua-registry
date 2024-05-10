#!/usr/bin/env bash

set -eu

opts=""
if [ "$(uname)" = Linux ]; then
	opts="--build-arg USERNAME=$(id -u -n) --build-arg GROUPNAME=$(id -g -n) --build-arg HOME=/home/$(id -u -n)"
fi

cp aqua-policy.yaml docker
docker build -t aquaproj/aqua-registry $opts docker
mkdir -p .build
cp docker/Dockerfile .build
