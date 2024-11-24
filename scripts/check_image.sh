#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/var.sh"
container_name=${1:-$container}

container_image_id=$(docker inspect "$container_name" | aqua exec -- jq -r ".[].Image")
image_id=$(docker inspect "$image" | aqua exec -- jq -r ".[].Id")

[ "$container_image_id" = "$image_id" ]
