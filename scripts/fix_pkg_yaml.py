#!/usr/bin/env python3
"""Use long syntax for old test versions in pkg.yaml files."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


PACKAGES_PATTERN = re.compile(
    r"^(?P<indent>[ \t]*)packages:[ \t]*(?:#.*)?(?:\r?\n)?$"
)
PACKAGE_PATTERN = re.compile(
    r"^(?P<indent>[ \t]*)- name: "
    r"(?P<name>[^ \t\r\n#]+)"
    r"(?P<suffix>[ \t]*(?:#.*)?)"
    r"(?P<newline>\r?\n?)$"
)
VERSION_PATTERN = re.compile(r"^(?P<indent>[ \t]*)version:[ \t]*")
DATE_PATTERN = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}(?:[Tt ].*)?")
NUMBER_PATTERN = re.compile(
    r"[-+]?(?:"
    r"[0-9][0-9_]*(?:\.[0-9_]*)?(?:[eE][-+]?[0-9]+)?"
    r"|\.[0-9_]+(?:[eE][-+]?[0-9]+)?"
    r"|0[xX][0-9a-fA-F_]+"
    r"|0[oO][0-7_]+"
    r"|0[bB][01_]+"
    r"|\.(?:inf|nan)"
    r")",
    re.IGNORECASE,
)
PLAIN_STRING_PATTERN = re.compile(r"[A-Za-z0-9_./+~-]+")
YAML_KEYWORDS = {
    "false",
    "n",
    "no",
    "null",
    "off",
    "on",
    "true",
    "y",
    "yes",
    "~",
}


def format_yaml_string(value: str) -> str:
    if (
        not PLAIN_STRING_PATTERN.fullmatch(value)
        or value.lower() in YAML_KEYWORDS
        or DATE_PATTERN.fullmatch(value)
        or NUMBER_PATTERN.fullmatch(value)
    ):
        return json.dumps(value)
    return value


def parse_yaml_string(value: str) -> str | None:
    if len(value) < 2 or value[0] not in {'"', "'"} or value[-1] != value[0]:
        return value
    if value[0] == '"':
        try:
            parsed = json.loads(value)
        except json.JSONDecodeError:
            return None
        return parsed if isinstance(parsed, str) else None
    return value[1:-1].replace("''", "'")


def has_version_field(lines: list[str], line_index: int, package_indent: str) -> bool:
    field_indent = package_indent + "  "
    for line in lines[line_index + 1 :]:
        stripped = line.lstrip(" \t")
        if not stripped or stripped.startswith("#"):
            continue
        indent = line[: len(line) - len(stripped)]
        if len(indent) <= len(package_indent):
            return False
        match = VERSION_PATTERN.match(line)
        if match and match.group("indent") == field_indent:
            return True
    return False


def fix_pkg_yaml(source: str) -> str:
    """Return pkg.yaml with old short-syntax package entries expanded."""
    package_indent: str | None = None
    package_index = 0
    output: list[str] = []
    lines = source.splitlines(keepends=True)

    for line_index, line in enumerate(lines):
        if package_indent is None:
            match = PACKAGES_PATTERN.match(line)
            if match:
                package_indent = match.group("indent") + "  "
            output.append(line)
            continue

        match = PACKAGE_PATTERN.match(line)
        if not match or match.group("indent") != package_indent:
            output.append(line)
            continue

        name = parse_yaml_string(match.group("name"))
        if (
            package_index == 0
            or name is None
            or "@" not in name
            or has_version_field(lines, line_index, package_indent)
        ):
            package_index += 1
            output.append(line)
            continue

        package_name, version = name.rsplit("@", 1)
        if not package_name or not version:
            package_index += 1
            output.append(line)
            continue
        newline = match.group("newline")
        line_break = newline or "\n"
        output.append(
            f"{package_indent}- name: {format_yaml_string(package_name)}"
            f"{match.group('suffix')}"
            f"{line_break}"
        )
        output.append(
            f"{package_indent}  version: {format_yaml_string(version)}{newline}"
        )
        package_index += 1

    return "".join(output)


def fix_file(path: Path) -> None:
    if path.name != "pkg.yaml":
        return
    with path.open(encoding="utf-8", newline="") as file:
        source = file.read()
    fixed = fix_pkg_yaml(source)
    if fixed == source:
        return
    with path.open("w", encoding="utf-8", newline="") as file:
        file.write(fixed)


def main(args: list[str]) -> None:
    for arg in args:
        fix_file(Path(arg))


if __name__ == "__main__":
    main(sys.argv[1:])
