#!/usr/bin/env bash

set -eu

container_name=${1:-aqua-registry}

docker stop -t 3 "$container_name"
docker rm "$container_name"
