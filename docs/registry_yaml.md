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
