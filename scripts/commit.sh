#!/usr/bin/env bash

set -eu

pkg=$1

git add registry.yaml pkgs/$pkg/pkg.yaml pkgs/$pkg/registry.yaml
git commit -m "feat($pkg): scaffold $pkg"
