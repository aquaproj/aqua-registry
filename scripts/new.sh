#!/usr/bin/env bash

set -eu

. "$(dirname "$0")/var.sh"

bash scripts/check_diff_package.sh
pkg=$(bash scripts/get_pkg_from_branch.sh "$PACKAGE")
aqua exec -- "$container" create-pr-new-pkg "$pkg"
