package main

import rego.v1

# A package that is its own alias says nothing by it, and the registry it is converted for
# rejects it outright: alvinunreal/tmuxai, jreisinger/checkip and leoafarias/fvm each
# carried one, added beside the old name when the repository was renamed.
test_deny_self_alias if {
	result := deny with input as [{
		"path": "registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "alvinunreal",
			"repo_name": "tmuxai",
			"aliases": [
				{"name": "alvinunreal/tmuxai"},
				{"name": "BoringDystopiaDevelopment/tmuxai"},
			],
		}]},
	}]
	"registry.yaml: alvinunreal/tmuxai is its own alias" in result
}

# A name that is an alias here and a package there answers as both, and nothing decides
# which: aqua builds one map out of every name and drops the duplicate key.
test_deny_alias_that_is_a_package if {
	result := deny with input as [{
		"path": "registry.yaml",
		"contents": {"packages": [
			{"repo_owner": "cli", "repo_name": "cli", "aliases": [{"name": "github/hub"}]},
			{"repo_owner": "github", "repo_name": "hub"},
		]},
	}]
	"registry.yaml: github/hub is an alias of cli/cli and a package of its own" in result
}

# Two packages claiming one alias is the same thing without a package to point at.
test_deny_alias_claimed_twice if {
	result := deny with input as [{
		"path": "registry.yaml",
		"contents": {"packages": [
			{"repo_owner": "foo", "repo_name": "bar", "aliases": [{"name": "shared/alias"}]},
			{"repo_owner": "foo", "repo_name": "baz", "aliases": [{"name": "shared/alias"}]},
		]},
	}]
	"registry.yaml: shared/alias is an alias of more than one package: foo/bar, foo/baz" in result
}

test_deny_alias_without_a_name if {
	result := deny with input as [{
		"path": "registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "foo",
			"repo_name": "bar",
			"aliases": [{"name": ""}],
		}]},
	}]
	"registry.yaml: foo/bar has an alias with no name" in result
}

# What aliases are for: a name the registry stopped holding, pointing at the one it holds
# now.
test_allow_an_alias_of_a_name_nothing_else_has if {
	result := deny with input as [{
		"path": "registry.yaml",
		"contents": {"packages": [
			{"repo_owner": "alvinunreal", "repo_name": "tmuxai", "aliases": [{"name": "BoringDystopiaDevelopment/tmuxai"}]},
			{"repo_owner": "cli", "repo_name": "cli"},
		]},
	}]
	count(result) == 0
}

# A package's own file says nothing about the rest of the registry, so the aliases are
# checked where every package is: one alias colliding with a package in another file is
# what these rules are for.
test_allow_a_package_file if {
	result := deny with input as [{
		"path": "pkgs/alvinunreal/tmuxai/registry.yaml",
		"contents": {"packages": [{
			"repo_owner": "alvinunreal",
			"repo_name": "tmuxai",
			"aliases": [{"name": "alvinunreal/tmuxai"}],
		}]},
	}]
	count([msg | some msg in result; contains(msg, "alias")]) == 0
}
