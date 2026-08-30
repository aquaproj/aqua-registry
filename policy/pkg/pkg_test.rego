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

test_allow_go_sub_package_name if {
	result := deny with input as [{
		"path": "pkgs/_go/sigsum.org/sigsum-go/cmd/sigsum-key/pkg.yaml",
		"contents": {"packages": [{"name": "_go/sigsum.org/sigsum-go#cmd/sigsum-key@v0.9.1"}]},
	}]
	count(result) == 0
}

test_deny_hash_outside_go_package if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/sub/pkg.yaml",
		"contents": {"packages": [{"name": "owner/repo#sub"}]},
	}]
	result == {"pkgs/owner/repo/sub/pkg.yaml: package name mismatch: expected \"owner/repo/sub\" but got \"owner/repo#sub\""}
}
