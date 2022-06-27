# clivm-registry

[![Build Status](https://github.com/clivm/clivm-registry/workflows/test/badge.svg)](https://github.com/clivm/clivm-registry/actions) [![GitHub last commit](https://img.shields.io/github/last-commit/clivm/clivm-registry.svg)](https://github.com/clivm/clivm-registry) [![License](http://img.shields.io/badge/license-mit-blue.svg?style=flat-square)](https://raw.githubusercontent.com/clivm/clivm-registry/main/LICENSE)

[clivm](https://github.com/clivm/clivm)'s Standard Registry

## How to use

[Example](https://github.com/suzuki-shunsuke/my-clivm-config/blob/main/clivm.yaml)

clivm.yaml

```yaml
registries:
  - type: standard
    ref: v3.3.0 # renovate: depName=clivm/clivm-registry
```

## Search packages from the Standard Registry by the command `clivm g`

Please add the Standard Registry to your clivm.yaml's registries, and run `clivm g`.

```yaml
registries:
  - type: standard
    ref: v3.3.0 # renovate: depName=clivm/clivm-registry
```

`clivm g` launches the interactive UI and you can search the package by fuzzy search.

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

Please check [registry.yaml](https://github.com/clivm/clivm-registry/blob/main/registry.yaml) or search packages by `clivm g` command.
If the packages you want aren't found, please create issues or send pull requests!

By adding various packages to the standard registry, clivm becomes more useful and attractive.
We need your contribution!

## How to contribute

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## :bulb: Tips: Get all packages in your laptop

You can get over 400 packages in your laptop! By Lazy Install, packages aren't installed until they are really needed.

1. Check out this repository
1. Add [clivm-all.yaml](clivm-all.yaml) to the environment variable `CLIVM_GLOBAL_CONFIG`
1. Run `clivm i -l -a`

```console
$ git clone https://github.com/clivm/clivm-registry
$ export CLIVM_GLOBAL_CONFIG="$PWD/clivm-registry/clivm-all.yaml:$CLIVM_GLOBAL_CONFIG"
$ clivm i -l -a
```

Set up cron to checkout the repository and run `clivm i -l -a` periodically, you can update packages automatically.

If you want to change some packages' version, please override them by the other configuration file.

```console
$ export CLIVM_GLOBAL_CONFIG="<Other clivm.yaml>:$PWD/clivm-all.yaml:$CLIVM_GLOBAL_CONFIG"
```

## Change Log

Please see [Releases](https://github.com/clivm/clivm-registry/releases).

## Contributors

[![contributors](https://contrib.rocks/image?repo=clivm/clivm-registry)](https://github.com/clivm/clivm-registry/graphs/contributors)

## License

[MIT](LICENSE)
