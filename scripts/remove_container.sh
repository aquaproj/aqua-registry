#!/usr/bin/env bash

set -eu

docker stop -t 3 aqua-registry
docker rm aqua-registry
