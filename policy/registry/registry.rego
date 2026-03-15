package main

import rego.v1

# Helper: get_name replicates PackageInfo.GetName() logic
get_name(pkg) := pkg.name if {
	pkg.name != ""
} else := concat("/", [pkg.repo_owner, pkg.repo_name]) if {
	pkg.repo_owner != ""
	pkg.repo_name != ""
} else := pkg.path if {
	pkg.type == "go_install"
	pkg.path != ""
} else := ""

# Helper: collect all files from top-level, overrides, version_overrides, and version_overrides[].overrides
all_files(pkg) := files if {
	top := object.get(pkg, "files", [])
	override_files := [f |
		ov := pkg.overrides[_]
		f := ov.files[_]
	]
	vo_files := [f |
		vo := pkg.version_overrides[_]
		f := vo.files[_]
	]
	vo_override_files := [f |
		vo := pkg.version_overrides[_]
		ov := vo.overrides[_]
		f := ov.files[_]
	]
	files := array.concat(array.concat(array.concat(top, override_files), vo_files), vo_override_files)
}

# Rule 1: packages must not be empty
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 0
	msg := sprintf("%s: packages is empty", [entry.path])
}

# Rule 2: packages must include only one package
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) > 1
	msg := sprintf("%s: packages must include only one package", [entry.path])
}

# Rule 3: package name must match directory path
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	trimmed := trim_prefix(entry.path, "pkgs/")
	expected_name := trim_suffix(trimmed, "/registry.yaml")
	get_name(pkg) != expected_name
	msg := sprintf("%s: package name mismatch: expected %q but got %q", [entry.path, expected_name, get_name(pkg)])
}

# Rule 4: top-level version_constraints must be empty or "false"
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	vc := pkg.version_constraint
	vc != ""
	vc != "false"
	msg := sprintf("%s: the top level version_constraint must be either empty or \"false\"", [entry.path])
}

# Rule 5: files[].name must not end with .exe
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	file := all_files(pkg)[_]
	endswith(file.name, ".exe")
	msg := sprintf("%s: .files[].name must not end with .exe. Remove .exe from name", [entry.path])
}

# Rule 6: files[].src must not end with .exe
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	file := all_files(pkg)[_]
	endswith(object.get(file, "src", ""), ".exe")
	msg := sprintf("%s: .files[].src must not end with .exe. Remove .exe from src", [entry.path])
}

# Rule 7: omit files[].src if same as files[].name
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	file := all_files(pkg)[_]
	file.name == file.src
	msg := sprintf("%s: omit .files[].src if it's same with .files[].name", [entry.path])
}

# Rule 8: repo_owner/repo_name consistency
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	pkg.repo_owner != ""
	object.get(pkg, "repo_name", "") == ""
	msg := sprintf("%s: repo_name must be specified if repo_owner is specified", [entry.path])
}

deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	pkg.repo_name != ""
	object.get(pkg, "repo_owner", "") == ""
	msg := sprintf("%s: repo_owner must be specified if repo_name is specified", [entry.path])
}

# Rule 9: package name without period requires repo_owner/repo_name
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	trimmed := trim_prefix(entry.path, "pkgs/")
	pkg_name := trim_suffix(trimmed, "/registry.yaml")
	not contains(pkg_name, ".")
	object.get(pkg, "repo_owner", "") == ""
	msg := sprintf("%s: repo_owner and repo_name must be specified if package name doesn't include period", [entry.path])
}

deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	trimmed := trim_prefix(entry.path, "pkgs/")
	pkg_name := trim_suffix(trimmed, "/registry.yaml")
	not contains(pkg_name, ".")
	pkg.repo_owner != ""
	pkg.repo_name != ""
	repo_full := concat("/", [pkg.repo_owner, pkg.repo_name])
	pkg_name != repo_full
	not startswith(pkg_name, concat("", [repo_full, "/"]))
	msg := sprintf("%s: package name must start with repository full name if package name doesn't include period", [entry.path])
}

# Rule 10: omit name if same as repo_owner/repo_name
deny contains msg if {
	entry := input[_]
	endswith(entry.path, "/registry.yaml")
	count(entry.contents.packages) == 1
	pkg := entry.contents.packages[0]
	pkg.repo_owner != ""
	pkg.repo_name != ""
	pkg.name == concat("/", [pkg.repo_owner, pkg.repo_name])
	msg := sprintf("%s: omit .name if it's same with repo_owner/repo_name", [entry.path])
}
