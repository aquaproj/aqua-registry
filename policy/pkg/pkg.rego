package main

import rego.v1

# packages must not be empty
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/pkg.yaml")
	count(entry.contents.packages) == 0
	msg := sprintf("%s: packages is empty", [entry.path])
}

# package name must match directory-derived name
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/pkg.yaml")
	# Extract expected package name from path: "pkgs/owner/repo/pkg.yaml" → "owner/repo"
	trimmed := trim_prefix(entry.path, "pkgs/")
	expected_name := trim_suffix(trimmed, "/pkg.yaml")
	pkg := entry.contents.packages[_]
	# pkg.name may include "@version", extract name part
	name_parts := split(pkg.name, "@")
	pkg_name := name_parts[0]
	pkg_name != expected_name
	msg := sprintf("%s: package name mismatch: expected %q but got %q", [entry.path, expected_name, pkg_name])
}

# old versions must use separate name and version fields
deny_old_version_short_syntax contains result if {
	entry := input[_]
	endswith(entry.path, "/pkg.yaml")
	some package_index
	package_index > 0
	pkg := entry.contents.packages[package_index]
	contains(pkg.name, "@")
	entry_number := package_index + 1
	msg := sprintf("%s: package entry %d uses short syntax for an old version; use separate name and version fields (https://github.com/aquaproj/aqua-registry/blob/main/docs/pkg_yaml.md#dont-use-the-short-syntax-package-nameversion-for-the-old-versions)", [entry.path, entry_number])
	result := {
		"msg": msg,
		"_loc": {"file": entry.path, "line": 1},
	}
}
