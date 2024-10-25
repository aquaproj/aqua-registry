#!/usr/bin/env bash

set -eu

# Please update these variables if you build a private registry.
container=aqua-registry
container_windows=${container}-windows
image=aquaproj/aqua-registry
upstream=https://github.com/aquaproj/aqua-registry
