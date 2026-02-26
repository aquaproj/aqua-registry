# Guide

## Do Not Change the Source of Existing Packages to a Fork

Even if maintenance of an existing package’s source has stalled or the repository has been archived, **do not change the package source to point to a fork**.
Instead, create a **new package** that points to the forked source.

For example, development of [99designs/aws-vault](https://github.com/99designs/aws-vault) has slowed down, and a fork, [ByteNess/aws-vault](https://github.com/ByteNess/aws-vault), was created.
[Homebrew switched to using the forked repository](https://github.com/Homebrew/homebrew-core/pull/226185), but in the aqua registry, we decided to keep the original package as-is and add a new package instead.

- https://github.com/99designs/aws-vault/issues/1269
- https://github.com/aquaproj/aqua-registry/pull/45430

This is to prevent the maintainer of a package’s source from changing without users’ knowledge.
Whether or not to switch to a fork should be a decision made by users, not by the maintainers of the aqua registry.
By adding a new package, users can explicitly choose to switch packages themselves.

## Modifying Existing Packages

When modifying existing packages, you need to modify code under `pkgs/<package name>`.
There are several modification methods:

1. Manually modify the code
2. Regenerate the code from scratch with commands
3. Auto-generate code for the latest version and manually modify based on that

Which method to use depends on the state of the original code.
Code auto-generation has been improved many times.
Therefore, there is low-quality code generated before improvements.
Such code may be better regenerated from scratch rather than manually fixed.

One characteristic to identify if code is old is how `version_constraint` and `version_overrides` are written.
In the new style, it basically looks like this:

```yaml
  version_constraint: "false" # Root version_constraint is "false"
  version_overrides:
    - version_constraint: semver("<= 0.1.0") # Version constraints use <, <= not >, >= (basically <=)
      # ...
    # ...
    - version_constraint: "true" # End with "true" for latest version configuration
      # ...
```

In the old style, `version_overrides` is often not defined.
In this case, it's likely better to regenerate from scratch.
However, as mentioned earlier, auto-generation doesn't support package types other than `github_release` or `cargo`, so manual modification will be necessary.

Also, [aliases](https://aquaproj.github.io/docs/reference/registry-config/aliases) and [files](https://aquaproj.github.io/docs/reference/registry-config/files) cannot be auto-generated, so you need to modify the auto-generated code referring to the original code.

`3. Auto-generate code for the latest version and manually modify based on that` is effective when the package no longer installs with the latest version but you want to reuse existing code (don't want to regenerate from scratch).
Running the following command generates code for the latest version:

```sh
aqua gr -l 1 "<package name>"
```

Fix this and add it to the end of `version_overrides` in the original code and modify version_constraint.
