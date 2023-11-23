#!/usr/bin/env bash

set -eu

if [ -z "${ARCH:-}" ]; then
	ARCH=$(uname -m)
	case $ARCH in
		x86_64) ARCH="amd64" ;;
		aarch64) ARCH="arm64" ;;
	esac
fi
container=aqua-registry
if [ "$OS" = windows ]; then
	container=aqua-registry-windows
fi
echo "[INFO] Connecting to the container $container ($OS/$ARCH)" >&2
docker exec -ti "$container" env AQUA_GOOS="$OS" AQUA_GOARCH="$ARCH" bash
