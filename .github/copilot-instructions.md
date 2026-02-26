# Common Style

## Add a newline at the end of file

Please add a newline at the end of file.
Note that this doesn't mean add an empty line at the end of file.

<img width="230" alt="image" src="https://github.com/user-attachments/assets/ae45e4c6-fadf-481f-9ad4-927ed296343c">

The mark ⛔ means the file misses a newline at the end of file.

<img width="345" alt="image" src="https://github.com/user-attachments/assets/f569c07b-ef02-4009-8f94-c0ed44506e11">

> No newline at end of file

If you use VSCode, we recommend setting `"files.insertFinalNewline": true`.

https://stackoverflow.com/questions/44704968/visual-studio-code-insert-newline-at-the-end-of-files

Reference: [Why should text files end with a newline?](https://stackoverflow.com/a/729795/6364492)
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
# Style Style Guide of pkgs/\*\*/pkg.yaml

## What's pkgs/\*\*/pkg.yaml for?

`pkgs/**/pkg.yaml` are test data.
`pkgs/**/pkg.yaml` are used to test if packages can be installed properly.

Note that `pkgs/**/pkg.yaml` aren't lists of available versions.
You can install any versions not listed in `pkgs/**/pkg.yaml`.

## packages must not be empty

:thumbsdown:

```yaml
packages: []
```

If `cmdx s` fails to fetch versions, packages may become empty.

## Test multiple versions

If the package has the field [version_overrides](/docs/reference/registry-config/version-overrides),
please add not only the latest version but also old versions in `pkg.yaml` to test if old versions can be installed properly.

```yaml
packages:
  - name: scaleway/scaleway-cli@v2.12.0
  - name: scaleway/scaleway-cli
    version: v2.4.0
```

## Don't use the short syntax `<package name>@<version>` for the old versions

Don't use the short syntax `<package name>@<version>` for the old version to prevent aqua-registry-updater from updating the old version.

:thumbsup:

```yaml
packages:
  - name: scaleway/scaleway-cli@v2.12.0
  - name: scaleway/scaleway-cli
    version: v2.4.0
```

:thumbsdown:

```yaml
packages:
  - name: scaleway/scaleway-cli@v2.12.0
  - name: scaleway/scaleway-cli@v2.4.0
```
# Style Guide of pkgs/\*\*/registry.yaml

## Tool Naming Convention

To avoid name conflicts, tool names must include `/` (namespace-like meaning).

- NG: `terraform`
- OK: `hashicorp/terraform`

If the tool code is managed on GitHub, match the repository name.
If multiple tools are managed in that repository, change the name for each tool.

e.g. [winebarrel/cronplan](https://github.com/winebarrel/cronplan)

- `winebarrel/cronplan/cronmatch`
- `winebarrel/cronplan/cronplan`
- `winebarrel/cronplan/cronviz`

Packages hosted outside GitHub should have naming that distinguishes them from GitHub.
`cargo` packages become [crates.io/{crate name}](https://github.com/aquaproj/aqua-registry/tree/main/pkgs/crates.io).
Platforms other than GitHub like GitLab are not actively supported, but some are supported as http type packages.
[GitLab uses `gitlab.com/<repository name>`.](https://github.com/aquaproj/aqua-registry/tree/main/pkgs/gitlab.com)

## YAML Language Server Comment is necessary at the top of pkgs/\*\*/registry.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/aquaproj/aqua/main/json-schema/registry.json
```

## Remove spaces in the template `{{ ` and ` }}`

:thumbsup:

```yaml
asset: tfcmt_{{.OS}}_{{.Arch}}.tar.gz
```

:thumbsdown:

```yaml
asset: tfcmt_{{ .OS }}_{{ .Arch }}.tar.gz
```

## Remove characters `.!` from the end of the description

:thumbsup:

```yaml
description: A command-line tool that makes git easier to use with GitHub
```

:thumbsdown:

```yaml
description: A command-line tool that makes git easier to use with GitHub.
```

## Trim spaces

:thumbsup:

```yaml
description: A command-line tool that makes git easier to use with GitHub
```

:thumbsdown:

```yaml
description: "  A command-line tool that makes git easier to use with GitHub  "
```

## Remove unneeded quotes of strings

:thumbsup:

```yaml
description: A command-line tool that makes git easier to use with GitHub
```

:thumbsdown:

```yaml
description: "A command-line tool that makes git easier to use with GitHub"
```

## Avoid `if` and `for` statement in templates

:thumbsup:

```yaml
asset: foo.{{.Format}}
format: tar.gz
overrides:
  - goos: windows
    format: zip
```

:thumbsdown:

```yaml
asset: 'foo.{{if eq .GOOS "windows"}}zip{{else}}tar.gz{{end}}'
```

## `version_overrides` Style Guide

We decided not to rely on base settings as much as possible.
This means we don't define settings such as `asset`, `format`, `windows_arm_emulation`, and so on on the base settings.
Merge with base settings makes code DRY, but it's difficult to update settings when settings of new versions are changed because the update of the base settings affects all version override.
By stopping to merge settings, we can update settings by simply adding a new version override and updating the last version_constraint.
Perhaps we would be able to automate the update in future too.

e.g.

```yaml
# Define only settings which don't depend on versions.
# e.g. repo_owner, repo_name, description.
version_constraint: "false"
version_overrides:
  - version_constraint: semver("<= 3.0.0")
    # Oldest setting
    # ...
  - version_constraint: semver("<= 4.0.0")
    # ...
  - version_constraint: semver("<= 5.0.0")
    # ...
  - version_constraint: "true"
    # Latest setting
    # ...
```

## If the `format` is `raw`, `files[].src` isn't needed

:thumbsup:

```yaml
format: raw
files:
  - name: swagger
```

:thumbsdown:

```yaml
format: raw
files:
  - name: swagger
    src: swagger_{{.OS}}_{{.Arch}} # unneeded
```

## Consideration about Rust

:warning: The author [@suzuki-shunsuke](https://github.com/suzuki-shunsuke) isn't familiar with Rust. If you have any opinion, please let us know.

- linux: use the asset for not `gnu` but `musl` if both of them are supported
  - ref: https://github.com/aquaproj/aqua-registry/pull/2153#discussion_r805116879
- windows: use the asset for not `gnu` but `msvc` if both of them are supported
  - ref: https://rust-lang.github.io/rustup/installation/windows.html

:thumbsup:

```yaml
replacements:
  linux: unknown-linux-musl
  windows: pc-windows-msvc
```

:thumbsdown:

```yaml
replacements:
  linux: unknown-linux-gnu
  windows: pc-windows-gnu
```

## Use `overrides` instead of `format_overrides`

:thumbsup:

```yaml
format: tar.gz
overrides:
  - goos: windows
    format: zip
```

:thumbsdown:

```yaml
format: tar.gz
format_overrides:
  - goos: windows
    format: zip
```

## Don't use emojis as much as possible

In some environments, emojis are corrupted. e.g. https://github.com/aquaproj/aqua/pull/1004#issuecomment-1183710603

:thumbsup:

```yaml
description: CLI and Go library for CODEOWNERS files
```

:thumbsdown:

```yaml
description: 🔒 CLI and Go library for CODEOWNERS files
```

## Omit the setting which is equivalent to the default value

When `repo_owner` and `repo_name` are set, you can omit some attributes.

:thumbsup:

```yaml
repo_owner: weaveworks
repo_name: eksctl
```

:thumbsdown:

```yaml
repo_owner: weaveworks
repo_name: eksctl
name: weaveworks/eksctl
link: https://github.com/weaveworks/eksctl
files:
  - name: eksctl
```

## Omit `.files[].src` if it is the same as `.files[].name`

:thumbsup:

```yaml
files:
  - name: pinact
```

:thumbsdown:

```yaml
files:
  - name: pinact
    src: pinact
```

## Don't add `.exe` to `.files[].name`

:thumbsup:

```yaml
files:
  - name: pinact
```

:thumbsdown:

```yaml
files:
  - name: pinact.exe
```

## Omit `.exe`

On Windows, `.exe` is appended by default. So you don't need to append `.exe`.

:thumbsup:

```yaml
files:
  - name: pinact
```

:thumbsdown:

```yaml
files:
  - name: pinact
    src: pinact.exe
```

## Use `aliases` only for keeping the compatibility

The same package should have only one name, and aliases should be used only to keep the compatibility.
`aliases` is used when the package repository is transferred usually.
`search_words` is useful to allow to search packages with additional words.

e.g.

```yaml
name: kubernetes-sigs/controller-tools/controller-gen
search_words:
  - kubebuilder
```

## Select `type` according to the following order

1. github_release
1. github_content
1. github_archive
1. http
1. go_install
1. go_build

For example, you can also use `http` type to install the package from GitHub Releases, but in that case you should use `github_release` rather than `http`.

## `cargo` package name should be `crates.io/<crate name>`

Please see [here](/docs/reference/registry-config/cargo-package#-package-name).
