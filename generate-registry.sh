#!/usr/bin/env bash

set -eu
set -o pipefail

# Make sure sort output the same order on different environments
export LC_COLLATE=C

cp registry-header.yaml registry.yaml
# shellcheck disable=SC2094
find pkgs -name registry.yaml | sort | xargs cat |
	grep -v -E "^packages:" | grep -v -E "^---$" >> registry.yaml
