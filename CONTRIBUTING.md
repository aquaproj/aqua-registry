# Contributing

About how to write [registry.yaml](registry.yaml), please see [Registry Configuration](https://aquaproj.github.io/docs/reference/registry-config).

## OSS Contribution Guide

Please read the following document.

- https://github.com/suzuki-shunsuke/oss-contribution-guide

## Should you create an Issue before sending a Pull Request?

Basically, you don't have to create an Issue before sending a Pull Request.
But if the pull request requires the discussion before reviewing, you have to create an Issue in advance.

For example, you don't have to create an Issue in the following cases.

- Add a package
- Fix a typo

On the other hand, for example if you want to change the directory structure in `pkgs` or the workflow adding a package,
you have to create an Issue and describe what is changed and why the change is needed.

## Requirements

- [aqua](https://aquaproj.github.io/docs/reference/install) >= [v1.14.0](https://github.com/aquaproj/aqua/releases/tag/v1.14.0)

## Set up

Checkout the repository and install [aqua-registry CLI](https://github.com/aquaproj/registry-tool).

```console
$ git checkout https://github.com/aquaproj/aqua-registry
$ cd aqua-registry
$ aqua i -l # Install aqua-registry CLI
```

## How to add packages

1. Scaffold configuration: `aqua-registry scaffold <package name>`
1. Fix generated files if the scaffold fails
1. Update registry.yaml: `aqua-registry gr`
1. Test: `aqua i` and run installed tools
1. Repeat the step 2 ~ 4 until packages are installed properly
1. Create a pull request: `aqua-registry create-pr-new-pkg <package name>...`

:warning: Don't run `scaffold` command against the same package at multiple times.

:warning: When you update `pkgs/**/registry.yaml`, you have to run `aqua-registry gr` to reflect the update to `registry.yaml` on the repository root directory.

## Style Guide

https://aquaproj.github.io/docs/reference/registry-style-guide

## Supported OS and CPU Architecture

Please consider the following OS and CPU Architecture.

- OS
  - windows
  - darwin
  - linux
- CPU Architecture
  - amd64
  - arm64

We test the registry in CI on the above environments by GitHub Actions' build matrix.

## Test multiple versions

If the package has the field [version_overrides](https://aquaproj.github.io/docs/reference/registry-config#version_constraint-version_overrides),
please add not only the latest version but also old versions in `pkg.yaml` to test if old versions can be installed properly.

e.g. [pkg.yaml](pkgs/scaleway/scaleway-cli/pkg.yaml) [registry.yaml](pkgs/scaleway/scaleway-cli/registry.yaml)

```yaml
packages:
  - name: scaleway/scaleway-cli@v2.6.2
  - name: scaleway/scaleway-cli
    version: v2.4.0
```

:warning: Don't use the short syntax `<package name>@<version>` for the old version to prevent Renovate from updating the old version.

:thumbsdown:

```yaml
packages:
  - name: scaleway/scaleway-cli@v2.6.2
  - name: scaleway/scaleway-cli@v2.6.2
```

## Change `GOOS` and `GOARCH` for testing

Please see https://aquaproj.github.io/docs/reference/change-os-arch-for-test
