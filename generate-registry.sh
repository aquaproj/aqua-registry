#!/usr/bin/env bash

set -eu
set -o pipefail

cp registry-header.yaml registry.yaml
# shellcheck disable=SC2094
find pkgs -name registry.yaml | sort | xargs cat |
	grep -v -E "^packages:" | grep -v -E "^---$" >> registry.yaml
yaml2json < registry.yaml > registry.json
