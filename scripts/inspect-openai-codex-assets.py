#!/usr/bin/env python3
"""Inspect openai/codex release assets relevant to aqua packaging."""

from __future__ import annotations

import json
import subprocess
import sys


TARGETS = [
    "x86_64-apple-darwin",
    "aarch64-apple-darwin",
    "x86_64-unknown-linux-musl",
    "aarch64-unknown-linux-musl",
    "x86_64-pc-windows-msvc",
    "aarch64-pc-windows-msvc",
]


def gh_api(path: str) -> dict:
    output = subprocess.check_output(["gh", "api", path], text=True)
    return json.loads(output)


def releases() -> list[tuple[str, set[str]]]:
    items: list[tuple[str, set[str]]] = []
    page = 1
    while True:
        data = gh_api(f"repos/openai/codex/releases?per_page=100&page={page}")
        if not data:
            return items
        for release in data:
            tag = release["tag_name"]
            if tag.startswith("rust-v"):
                items.append((tag, {asset["name"] for asset in release["assets"]}))
        page += 1


def version_key(tag: str) -> tuple[int, int, int]:
    version = tag.removeprefix("rust-v").split("-", 1)[0]
    major, minor, patch = version.split(".")
    return int(major), int(minor), int(patch)


def npm_tag(target: str) -> str:
    return {
        "x86_64-apple-darwin": "darwin-x64",
        "aarch64-apple-darwin": "darwin-arm64",
        "x86_64-unknown-linux-musl": "linux-x64",
        "aarch64-unknown-linux-musl": "linux-arm64",
        "x86_64-pc-windows-msvc": "win32-x64",
        "aarch64-pc-windows-msvc": "win32-arm64",
    }[target]


def single_binary_asset(target: str) -> str:
    suffix = ".exe" if target.endswith("pc-windows-msvc") else ""
    return f"codex-{target}{suffix}"


def main() -> int:
    for tag, assets in sorted(releases(), key=lambda item: version_key(item[0])):
        version = tag.removeprefix("rust-v")
        package_targets = [
            target
            for target in TARGETS
            if f"codex-package-{target}.tar.gz" in assets
            or f"codex-package-{target}.tar.zst" in assets
        ]
        npm_targets = [
            target
            for target in TARGETS
            if f"codex-npm-{npm_tag(target)}-{version}.tgz" in assets
        ]
        single_targets = [
            target
            for target in TARGETS
            if single_binary_asset(target) in assets
            or f"{single_binary_asset(target)}.zst" in assets
        ]
        if package_targets or npm_targets:
            print(
                tag,
                "packages=" + ",".join(package_targets or ["-"]),
                "npm=" + ",".join(npm_targets or ["-"]),
                "single=" + ",".join(single_targets or ["-"]),
            )
    return 0


if __name__ == "__main__":
    sys.exit(main())
