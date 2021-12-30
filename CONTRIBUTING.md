# Contributing

About how to write [registry.yaml](registry.yaml), please see [Registry Configuration](https://aquaproj.github.io/docs/reference/registry-config).

## Add the packages

Please update [registry.yaml](registry.yaml) and add packages in `pkgs` for testing.

Packages are sorted in the dictionary order of the package name.

## Style Guide

### Remove spaces in the template `{{ ` and ` }}`

:thumbsup:

```yaml
  asset: 'tfcmt_{{.OS}}_{{.Arch}}.tar.gz'
```

:thumbsdown:

```yaml
  asset: 'tfcmt_{{ .OS }}_{{ .Arch }}.tar.gz'
```

### Remove a period from the end of the description

:thumbsup:

```yaml
description: A command-line tool that makes git easier to use with GitHub
```

:thumbsdown:

```yaml
description: A command-line tool that makes git easier to use with GitHub.
```

## How to test in your localhost

```console
$ cp aqua.yaml.tmpl aqua.yaml
$ vi aqua.yaml # Add new packages
$ aqua i --test
```
