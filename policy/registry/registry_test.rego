package main

import rego.v1

# packages must not be empty
test_deny_empty_packages if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": []},
	}]
	result == {"pkgs/owner/repo/registry.yaml: packages is empty"}
}

# packages must include only one package
test_deny_multiple_packages if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [
			{"repo_owner": "owner", "repo_name": "repo"},
			{"repo_owner": "owner", "repo_name": "other"},
		]},
	}]
	"pkgs/owner/repo/registry.yaml: packages must include only one package" in result
}

# package name must match directory path
test_deny_name_mismatch if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "wrong",
			"repo_name": "name",
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: package name mismatch: expected \"owner/repo\" but got \"wrong/name\"" in result
}

test_allow_matching_name if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
		}]},
	}]
	count(result) == 0
}

test_allow_explicit_name if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"name": "owner/repo",
			"repo_owner": "owner",
			"repo_name": "repo",
		}]},
	}]
	not "pkgs/owner/repo/registry.yaml: package name mismatch: expected \"owner/repo\" but got \"owner/repo\"" in result
}

test_allow_go_install_path_name if {
	result := deny with input as [{
		"path": "pkgs/example.com/foo/bar/registry.yaml",
		"contents": {"packages": [{
			"type": "go_install",
			"path": "example.com/foo/bar",
		}]},
	}]
	count(result) == 0
}

# version_constraint must be empty or "false"
test_deny_invalid_version_constraint if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"version_constraint": "true",
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: the top level version_constraint must be either empty or \"false\"" in result
}

test_allow_false_version_constraint if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"version_constraint": "false",
		}]},
	}]
	not "pkgs/owner/repo/registry.yaml: the top level version_constraint must be either empty or \"false\"" in result
}

# files[].name must not end with .exe
test_deny_file_name_exe if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"files": [{"name": "tool.exe"}],
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: .files[].name must not end with .exe. Remove .exe from name" in result
}

test_deny_file_name_exe_in_version_overrides if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"version_overrides": [{"files": [{"name": "tool.exe"}]}],
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: .files[].name must not end with .exe. Remove .exe from name" in result
}

test_deny_file_name_exe_in_overrides if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"overrides": [{"files": [{"name": "tool.exe"}]}],
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: .files[].name must not end with .exe. Remove .exe from name" in result
}

test_deny_file_name_exe_in_vo_overrides if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"version_overrides": [{"overrides": [{"files": [{"name": "tool.exe"}]}]}],
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: .files[].name must not end with .exe. Remove .exe from name" in result
}

# files[].src must not end with .exe
test_deny_file_src_exe if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"files": [{"name": "tool", "src": "tool.exe"}],
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: .files[].src must not end with .exe. Remove .exe from src" in result
}

# omit files[].src if same as files[].name
test_deny_file_src_same_as_name if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
			"repo_name": "repo",
			"files": [{"name": "tool", "src": "tool"}],
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: omit .files[].src if it's same with .files[].name" in result
}

# repo_owner/repo_name consistency
test_deny_repo_owner_without_repo_name if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "owner",
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: repo_name must be specified if repo_owner is specified" in result
}

test_deny_repo_name_without_repo_owner if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"repo_name": "repo",
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: repo_owner must be specified if repo_name is specified" in result
}

# package name without period requires repo_owner/repo_name
test_deny_no_period_without_repo if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"name": "owner/repo",
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: repo_owner and repo_name must be specified if package name doesn't include period" in result
}

test_deny_no_period_name_not_starting_with_repo if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/tool/registry.yaml",
		"contents": {"packages": [{
			"name": "owner/repo/tool",
			"repo_owner": "other",
			"repo_name": "repo",
		}]},
	}]
	"pkgs/owner/repo/tool/registry.yaml: package name must start with repository full name if package name doesn't include period" in result
}

test_allow_no_period_name_starting_with_repo if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/tool/registry.yaml",
		"contents": {"packages": [{
			"name": "owner/repo/tool",
			"repo_owner": "owner",
			"repo_name": "repo",
		}]},
	}]
	not "pkgs/owner/repo/tool/registry.yaml: package name must start with repository full name if package name doesn't include period" in result
}

# omit name if same as repo_owner/repo_name
test_deny_redundant_name if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/registry.yaml",
		"contents": {"packages": [{
			"name": "owner/repo",
			"repo_owner": "owner",
			"repo_name": "repo",
		}]},
	}]
	"pkgs/owner/repo/registry.yaml: omit .name if it's same with repo_owner/repo_name" in result
}

test_allow_different_name if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/tool/registry.yaml",
		"contents": {"packages": [{
			"name": "owner/repo/tool",
			"repo_owner": "owner",
			"repo_name": "repo",
		}]},
	}]
	not "pkgs/owner/repo/tool/registry.yaml: omit .name if it's same with repo_owner/repo_name" in result
}

# Test: non-registry.yaml files are ignored
test_ignore_non_registry_yaml if {
	result := deny with input as [{
		"path": "pkgs/owner/repo/pkg.yaml",
		"contents": {"packages": []},
	}]
	count(result) == 0
}
