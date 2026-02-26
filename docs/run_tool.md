# How to execute a package in your machine during development

There are several ways

1. Execute a package in linux containers via `cmdx con`
1. Import `pkgs/<package>/pkg.yaml` in [aqua.yaml](https://github.com/aquaproj/aqua-registry/blob/main/aqua.yaml)
1. Add [aqua-all.yaml](https://github.com/aquaproj/aqua-registry/blob/main/aqua-all.yaml) in `$AQUA_GLOBAL_CONFIG`

## 1. Execute a package in linux containers via `cmdx con`

```console
$ cmdx con
+ bash scripts/connect.sh
[INFO] Connecting to the container aqua-registry (linux/arm64)
```

Then you can execute a package in the container.

## 2. Import `pkgs/<package>/pkg.yaml` in aqua.yaml

```yaml
packages:
  # ...
  - import: pkgs/<package>/pkg.yaml
```

Please don't commit this change.

You need to run `aqua policy allow` to use the local registry.

```sh
aqua policy allow
```

Then you can execute the package.

## 3. Add aqua-all.yaml in `$AQUA_GLOBAL_CONFIG`

```sh
export AQUA_GLOBAL_CONFIG=$PWD/aqua-all.yaml:$AQUA_GLOBAL_CONFIG
```

You need to run `aqua policy allow` to use the local registry.

```sh
aqua policy allow
```

Then you can execute all packages.
