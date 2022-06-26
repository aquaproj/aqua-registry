# clienv-registry

[![Build Status](https://github.com/clienv/clienv-registry/workflows/test/badge.svg)](https://github.com/clienv/clienv-registry/actions) [![GitHub last commit](https://img.shields.io/github/last-commit/clienv/clienv-registry.svg)](https://github.com/clienv/clienv-registry) [![License](http://img.shields.io/badge/license-mit-blue.svg?style=flat-square)](https://raw.githubusercontent.com/clienv/clienv-registry/main/LICENSE)

[clienv](https://github.com/clienv/clienv)'s Standard Registry

## How to use

[Example](https://github.com/suzuki-shunsuke/my-aqua-config/blob/main/clienv.yaml)

clienv.yaml

```yaml
registries:
  - type: standard
    ref: v3.3.0 # renovate: depName=clienv/clienv-registry
```

## Search packages from the Standard Registry by the command `clienv g`

Please add the Standard Registry to your clienv.yaml's registries, and run `clienv g`.

```yaml
registries:
  - type: standard
    ref: v3.3.0 # renovate: depName=clienv/clienv-registry
```

`clienv g` launches the interactive UI and you can search the package by fuzzy search.

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

Please check [registry.yaml](https://github.com/clienv/clienv-registry/blob/main/registry.yaml) or search packages by `clienv g` command.
If the packages you want aren't found, please create issues or send pull requests!

By adding various packages to the standard registry, clienv becomes more useful and attractive.
We need your contribution!

## How to contribute

Please see [CONTRIBUTING.md](CONTRIBUTING.md)

## :bulb: Tips: Get all packages in your laptop

You can get over 400 packages in your laptop! By Lazy Install, packages aren't installed until they are really needed.

1. Check out this repository
1. Add [clienv-all.yaml](clienv-all.yaml) to the environment variable `AQUA_GLOBAL_CONFIG`
1. Run `clienv i -l -a`

```console
$ git clone https://github.com/clienv/clienv-registry
$ export AQUA_GLOBAL_CONFIG="$PWD/clienv-registry/clienv-all.yaml:$AQUA_GLOBAL_CONFIG"
$ clienv i -l -a
```

Set up cron to checkout the repository and run `clienv i -l -a` periodically, you can update packages automatically.

If you want to change some packages' version, please override them by the other configuration file.

```console
$ export AQUA_GLOBAL_CONFIG="<Other clienv.yaml>:$PWD/clienv-all.yaml:$AQUA_GLOBAL_CONFIG"
```

## Change Log

Please see [Releases](https://github.com/clienv/clienv-registry/releases).

## Contributors

[![contributors](https://contrib.rocks/image?repo=clienv/clienv-registry)](https://github.com/clienv/clienv-registry/graphs/contributors)

## License

[MIT](LICENSE)
