# aqua-registry

[![Build Status](https://github.com/aquaproj/aqua-registry/workflows/test/badge.svg)](https://github.com/aquaproj/aqua-registry/actions)
[![GitHub last commit](https://img.shields.io/github/last-commit/aquaproj/aqua-registry.svg)](https://github.com/aquaproj/aqua-registry)
[![License](http://img.shields.io/badge/license-mit-blue.svg?style=flat-square)](https://raw.githubusercontent.com/aquaproj/aqua-registry/main/LICENSE)

[aqua](https://github.com/aquaproj/aqua)'s Standard Registry

## How to use

[Example](https://github.com/suzuki-shunsuke/my-aqua-config/blob/main/aqua.yaml)

aqua.yaml

```yaml
registries:
- type: standard
  ref: v0.13.1 # renovate: depName=aquaproj/aqua-registry
```

## Search packages from the Standard Registry by the command `aqua g`

Please add the Standard Registry to your aqua.yaml's registries, and run `aqua g`.

```yaml
registries:
- type: standard
  ref: v0.13.1 # renovate: depName=aquaproj/aqua-registry
```

`aqua g` launches the interactive UI and you can search the package by fuzzy search.

```console
  newrelic/newrelic-cli (standard) (newrelic)                   ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  pivotal-cf/pivnet-cli (standard) (pivnet)                     │  cli/cli
  scaleway/scaleway-cli (standard) (scw)                        │
  tfmigrator/cli (standard) (tfmigrator)                        │  https://cli.github.com/
  aws/copilot-cli (standard) (copilot)                          │  GitHub’cs official command line tool
  codeclimate/test-reporter (standard)                          │
  create-go-app/cli (standard) (cgapp)                          │
  harness/drone-cli (standard) (drone)                          │
  sigstore/rekor (standard) (rekor-cli)                         │
  getsentry/sentry-cli (standard)                               │
  grafana/loki/logcli (standard)                                │
  knative/client (standard) (kn)                                │
  rancher/cli (standard) (rancher)                              │
  tektoncd/cli (standard) (tkn)                                 │
  civo/cli (standard) (civo)                                    │
  dapr/cli (standard) (dapr)                                    │
  mongodb/mongocli (standard)                                   │
  openfaas/faas-cli (standard)                                  │
> cli/cli (standard) (gh)                                       │
  50/394                                                        │
> cli                                                           └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
```

## Request for new packages

Please check [registry.yaml](https://github.com/aquaproj/aqua-registry/blob/main/registry.yaml) or search packages by `aqua g` command.
If the packages you want aren't found, please create issues or send pull requests!

By adding various packages to the standard registry, aqua becomes more useful and attractive.
We need your contribution!

## How to contribute

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## Change Log

Please see [Releases](https://github.com/aquaproj/aqua-registry/releases).

## Versioning Policy

We are Conforming [suzuki-shunsuke/versioning-policy v0.1.0](https://github.com/suzuki-shunsuke/versioning-policy/blob/v0.1.0/POLICY.md), which is compatible with [Semantic Versioning 2.0.0](https://semver.org/).

## License

[MIT](LICENSE)
