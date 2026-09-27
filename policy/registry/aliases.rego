package main

import rego.v1

# The aliases are checked against the whole registry rather than one package's file,
# because what makes an alias wrong is usually another package: a name that is an alias
# here and a package there answers as both, and nothing decides which.
#
# aqua resolves a name by looking it up in one map built from every package and every
# alias, and a duplicate key is dropped with a log line nobody reads. So a collision
# doesn't fail, it silently picks whichever the registry happened to list first.
#
# aqua-registry-g2 rejects the same four things outright, because a registry addressed by
# name can't hold a name that means two things. What is here is what keeps them from
# reaching it.

# Helper: alias_owners maps an alias to the packages claiming it, in one pass over the
# registry.
alias_owners[name] contains owner if {
	entry := input[_]
	entry.path == "registry.yaml"
	some pkg in entry.contents.packages
	some alias in pkg.aliases
	name := alias.name
	owner := get_name(pkg)
}

# Helper: package_names is every name the registry holds a package under.
package_names contains name if {
	entry := input[_]
	entry.path == "registry.yaml"
	some pkg in entry.contents.packages
	name := get_name(pkg)
}

# an alias must have a name
deny contains msg if {
	entry := input[_]
	entry.path == "registry.yaml"
	some pkg in entry.contents.packages
	some alias in pkg.aliases
	object.get(alias, "name", "") == ""
	msg := sprintf("registry.yaml: %s has an alias with no name", [get_name(pkg)])
}

# a package must not be its own alias
deny contains msg if {
	some name, owners in alias_owners
	name in owners
	msg := sprintf("registry.yaml: %s is its own alias", [name])
}

# an alias must not be a package of its own
deny contains msg if {
	some name, owners in alias_owners
	name in package_names
	not name in owners
	msg := sprintf("registry.yaml: %s is an alias of %s and a package of its own", [name, concat(", ", sort(owners))])
}

# an alias must not be claimed by more than one package
deny contains msg if {
	some name, owners in alias_owners
	count(owners) > 1
	msg := sprintf("registry.yaml: %s is an alias of more than one package: %s", [name, concat(", ", sort(owners))])
}
