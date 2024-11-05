#!/usr/bin/env bash

set -eu

d=$(date +%Y-%m-%d -d "4 day ago")

shas=$(gh -R aquaproj/aqua-registry pr list \
    -A "app/aquaproj-aqua-registry" \
    -S "created:>=$d" \
    --json headRefOid \
    -q '.[].headRefOiddate +%Y:%m:%d -d "1 day ago"')

for sha in $shas; do
    echo "sha: $sha" >&2
    runids=$(gh -R aquaproj/aqua-registry run list \
        -c "$sha" \
        -s failure \
        --json databaseId \
        -q '.[].databaseId')
    for runid in $runids; do
        echo "runid: $runid" >&2
        gh -R aquaproj/aqua-registry run rerun "$runid" --failed
    done
done
