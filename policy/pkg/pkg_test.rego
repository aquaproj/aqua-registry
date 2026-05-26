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
