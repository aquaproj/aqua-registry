package main

import rego.v1

test_deny_empty_packages if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": []},
	}]
	result == {"pkgs/owner/repo/pkg.yaml: packages is empty"}
}

test_allow_valid_packages if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [{"name": "owner/repo"}]},
	}]
	count(result) == 0
}

test_deny_name_mismatch if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [{"name": "wrong/name"}]},
	}]
	result == {"pkgs/owner/repo/pkg.yaml: package name mismatch: expected \"owner/repo\" but got \"wrong/name\""}
}

test_allow_name_with_version if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [{"name": "owner/repo@v1.0.0"}]},
	}]
	count(result) == 0
}

test_deny_short_syntax_for_old_version if {
	result := deny_old_version_short_syntax with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [
			{"name": "owner/repo@v2.0.0"},
			{"name": "owner/repo@v1.0.0"},
		]},
	}]
	result == {{
		"msg": "pkgs/owner/repo/pkg.yaml: package entry 2 uses short syntax for an old version; use separate name and version fields (https://github.com/aquaproj/aqua-registry/blob/main/docs/pkg_yaml.md#dont-use-the-short-syntax-package-nameversion-for-the-old-versions)",
		"_loc": {"file": "pkgs/owner/repo/pkg.yaml", "line": 1},
	}}
}

test_allow_short_syntax_for_latest_version if {
	result := deny_old_version_short_syntax with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [
			{"name": "owner/repo@v2.0.0"},
		]},
	}]
	count(result) == 0
}

test_allow_long_syntax_for_old_version if {
	result := deny_old_version_short_syntax with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [
			{"name": "owner/repo@v2.0.0"},
			{"name": "owner/repo", "version": "v1.0.0"},
		]},
	}]
	count(result) == 0
}

test_deny_partial_mismatch if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": [
			{"name": "owner/repo"},
			{"name": "other/tool"},
		]},
	}]
	result == {"pkgs/owner/repo/pkg.yaml: package name mismatch: expected \"owner/repo\" but got \"other/tool\""}
}
