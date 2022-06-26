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
clienv gr "$pkg" > "pkgs/$pkg/registry.yaml"
bash generate-registry.sh
clienv g -i "$pkg"
echo "packages:" > "pkgs/$pkg/pkg.yaml"
echo "  $(clienv g "$pkg")" >> "pkgs/$pkg/pkg.yaml"
test -f clienv.yaml || cp clienv.yaml.tmpl clienv.yaml
clienv i
