# aqua-registry

[![Build Status](https://github.com/suzuki-shunsuke/aqua-registry/workflows/test/badge.svg)](https://github.com/suzuki-shunsuke/aqua-registry/actions)
[![GitHub last commit](https://img.shields.io/github/last-commit/suzuki-shunsuke/aqua-registry.svg)](https://github.com/suzuki-shunsuke/aqua-registry)
[![License](http://img.shields.io/badge/license-mit-blue.svg?style=flat-square)](https://raw.githubusercontent.com/suzuki-shunsuke/aqua-registry/main/LICENSE)

[aqua](https://github.com/suzuki-shunsuke/aqua)'s Standard Registry

## How to use

[Example](https://github.com/suzuki-shunsuke/my-aqua-config/blob/main/aqua.yaml)

aqua.yaml

```yaml
registries:
- type: standard
  ref: v0.10.3 # renovate: depName=suzuki-shunsuke/aqua-registry
```

## Search packages from the Standard Registry by the command `aqua g`

Please add the Standard Registry to your aqua.yaml's registries, and run `aqua g`.

```yaml
registries:
- type: standard
  ref: v0.10.3 # renovate: depName=suzuki-shunsuke/aqua-registry
```

`aqua g` launches the interactive UI and you can search the package by fuzzy search.

```
  CircleCI-Public/circleci-cli (standard)
  codeclimate/test-reporter (standard)
  int128/ghcp (standard)
  kubectl (standard)
  peco/peco (standard)
  tfmigrator/cli (standard)
> cli/cli (standard)
  41/78
> c
```

## Request for new packages

Please check [registry.yaml](https://github.com/suzuki-shunsuke/aqua-registry/blob/main/registry.yaml) or search packages by `aqua g` command.
If the packages you want aren't found, please create issues or send pull requests!

By adding various packages to the standard registry, aqua becomes more useful and attractive.
We need your contribution!

## How to contribute

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## Change Log

Please see [Releases](https://github.com/suzuki-shunsuke/aqua-registry/releases).

## Versioning Policy

We are Conforming [suzuki-shunsuke/versioning-policy v0.1.0](https://github.com/suzuki-shunsuke/versioning-policy/blob/v0.1.0/POLICY.md), which is compatible with [Semantic Versioning 2.0.0](https://semver.org/).

## License

[MIT](LICENSE)
