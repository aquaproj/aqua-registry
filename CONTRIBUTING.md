# Contributing

About how to write [registry.yaml](registry.yaml), please see [Registry Configuration](https://github.com/suzuki-shunsuke/aqua/blob/main/docs/registry_config.md).

## Add the packages

Please update [aqua.yaml](aqua.yaml) and [registry.yaml](registry.yaml).
aqua.yaml is used to test registry.yaml in CI.

Packages are sorted in the dictionary order of the package name.

In aqua.yaml, please add the code comment to update tools with [Renovate's Regex Manager](https://docs.renovatebot.com/modules/manager/regex/).

e.g.

```yaml
- name: terraform
  registry: standard
  version: v1.0.6 # renovate: depName=hashicorp/terraform
```

## How to test in your localhost

It takes a long time to install all packages with [aqua.yaml](aqua.yaml).
So we recommend writing the configuration file `aqua-test.yaml` and specify only packages you add or modify.

e.g.

```yaml
registries:
- name: standard
  type: local
  path: registry.yaml

packages:
- name: accurics/terrascan
  registry: standard
  version: v1.10.0 # renovate: depName=accurics/terrascan
```

And install packages specifying the file by `-c` option. Note that `-c` is a global option.

```console
$ aqua -c aqua-test.yaml i --test
```

## Test on Mac OSX

CI is run on Linux, so it is difficult to test if the registry works well in Mac OSX.
If you use Max OSX, please check if the registry works well in your localhost.

```console
$ aqua -c aqua-test.yaml i --test
```
