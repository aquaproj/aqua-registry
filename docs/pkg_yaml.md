# Style Style Guide of pkgs/**/pkg.yaml

## What's pkgs/**/pkg.yaml for?

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
