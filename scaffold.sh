#!/usr/bin/env bash

set -eux
set -o pipefail

if [ $# -ne 1 ]; then
  echo "usage: $ bash scaffold.sh <pkgname>" >&2
  echo "e.g. $ bash scaffold.sh cli/cli" >&2
  exit 1
fi

pkg=$1

mkdir -p "pkgs/$pkg"
clivm gr "$pkg" > "pkgs/$pkg/registry.yaml"
bash generate-registry.sh
clivm g -i "$pkg"
echo "packages:" > "pkgs/$pkg/pkg.yaml"
echo "  $(clivm g "$pkg")" >> "pkgs/$pkg/pkg.yaml"
test -f clivm.yaml || cp clivm.yaml.tmpl clivm.yaml
clivm i
