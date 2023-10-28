#!/usr/bin/env bash

set -euo pipefail

container_image_id=$(docker inspect aqua-registry | aqua exec -- jq -r ".[].Image")
image_id=$(docker inspect aquaproj/aqua-registry | aqua exec -- jq -r ".[].Id")

[ "$container_image_id" = "$image_id" ]
