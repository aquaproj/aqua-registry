# Contributing

About how to write [registry.yaml](registry.yaml), please see [Registry Configuration](https://aquaproj.github.io/docs/reference/registry-config).

## Add the packages

Please update [registry.yaml](registry.yaml) and add packages in `pkgs` for testing.

Packages are sorted in the dictionary order of the package name.

## Style Guide

Please remove spaces in the template `{{ ` and ` }}`.

:thumbsup:

```yaml
  asset: 'tfcmt_{{.OS}}_{{.Arch}}.tar.gz'
```

:thumbsdown:

```yaml
  asset: 'tfcmt_{{ .OS }}_{{ .Arch }}.tar.gz'
```

## How to test in your localhost

It takes a long time to install all packages.
So we recommend writing the configuration file `aqua.yaml` and specify only packages you add or modify.

e.g.

```yaml
registries:
- name: standard
  type: local
  path: registry.yaml

packages:
- name: accurics/terrascan@v1.12.0
```

```console
$ aqua i --test
```
