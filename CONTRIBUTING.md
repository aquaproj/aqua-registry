# Contributing

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

CI is run on Linux, so it is difficult to test if the registry works well in Mac OSX.
If you use Max OSX, please check if the registry works well in your localhost.

```
$ aqua i --test
```
