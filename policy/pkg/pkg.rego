package main

import rego.v1

# packages must not be empty
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/pkg.yaml")
	count(entry.contents.packages) == 0
	msg := sprintf("%s: packages is empty", [entry.path])
}

# Helper: Go sub-package names separate the module from the command path with "#",
# while the directory uses "/": "_go/sigsum.org/sigsum-go#cmd/sigsum-key" lives in
# "pkgs/_go/sigsum.org/sigsum-go/cmd/sigsum-key". Only "_go" packages use "#".
normalize_go_sub_package(name) := replace(name, "#", "/") if {
	startswith(name, "_go/")
} else := name

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
	normalize_go_sub_package(pkg_name) != expected_name
	msg := sprintf("%s: package name mismatch: expected %q but got %q", [entry.path, expected_name, pkg_name])
}
