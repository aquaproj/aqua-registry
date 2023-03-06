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
$ git clone https://github.com/aquaproj/aqua-registry
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

## :bulb: Generate `version_overrides`

:warning: `aqua >= v1.34.0` and `registry-tool >= v0.1.8` is required.

https://aquaproj.github.io/docs/reference/create-private-registry/#generate-version_overrides-by---deep-option

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
  - name: scaleway/scaleway-cli@v2.11.1
  - name: scaleway/scaleway-cli
    version: v2.4.0
```

:warning: Don't use the short syntax `<package name>@<version>` for the old version to prevent Renovate from updating the old version.

:thumbsdown:

```yaml
packages:
  - name: scaleway/scaleway-cli@v2.11.1
  - name: scaleway/scaleway-cli@v2.11.1
```

## Test in your laptop with Eartly

Using [Earthly](https://docs.earthly.dev/), you can do a test against a specific platform in your laptop.
You can test quickly without pushing a commit and waiting for CI.
Compared with running `aqua i --test` in your laptop directly, you can keep your laptop clean and can test against other platform than your laptop.

Please see [Earthfile](Earthfile) too.

Please run `aqua i -l` in this repository, then Earthly is installed by aqua.

After creating and updating a package's `pkg.yaml` and `registry.yaml`, please run `earthly +test`.

```console
$ earthly [-i] +test --pkg=<package name> [--os=linux|darwin|windows] [--arch=amd64|arm64]
```

e.g.

```console
$ earthly +test --pkg=suzuki-shunsuke/github-comment --os=windows --arch=amd64
```

There are three args.

- `--pkg`: (Required): package name. e.g. `suzuki-shunsuke/tfcmt`
- `--os`: (Default: `linux`): [AQUA_GOOS](https://aquaproj.github.io/docs/reference/change-os-arch-for-test)
- `--arch`: (Default: `amd64`): [AQUA_GOARCH](https://aquaproj.github.io/docs/reference/change-os-arch-for-test)

### Debug with earthly's `-i` option

[earthly's `-i` option is useful for debug](https://docs.earthly.dev/best-practices#technique-use-earthly-i-to-debug-failures).

https://docs.earthly.dev/docs/earthly-command

You can install tools for debug in a container.

e.g.

```console
$ apk add tree
```

## Change `GOOS` and `GOARCH` for testing

Please see https://aquaproj.github.io/docs/reference/change-os-arch-for-test
