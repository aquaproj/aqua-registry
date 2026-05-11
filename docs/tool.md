# Development Tools

CLIs for developing aqua-registry are provided.
These can be installed with aqua.
Check out aqua-registry and run `aqua i -l`.

```sh
aqua i -l
```

CLI named argd is installed.

```sh
argd help
```

Using development tools, you can generate files for each package (pkg.yaml, registry.yaml, scaffold.yaml) and test tool installation in containers.
Tests are performed in containers using the docker command, so you need the docker command and a compatible container engine.
Docker Desktop would work fine of course.
We install [docker/cli](https://github.com/docker/cli) and [abiosoft/colima](https://github.com/abiosoft/colima) with aqua.
Please confirm that the docker command works.

```sh
docker version
```

## Summary

### Requirements

- aqua ([Install](https://aquaproj.github.io/docs/install))
- docker
- argd `aqua i -l`
- prettier `npm i -g prettier`

### GitHub Access Token

1. AQUA_GITHUB_TOKEN
1. GITHUB_TOKEN
1. AQUA_GHTKN_ENABLED ([ghtkn integration](https://github.com/suzuki-shunsuke/ghtkn))

### Commands

```sh
aqua gr --init <package name> # (Optional) Generate aqua-generate-registry.yaml, which is a config file for `argd s` command. The config file is optional.
argd s [-c <config file path>] [-B] [-cmd <command name>] <package name> # Scaffold configuration and test it in containers
argd t [<package name>] # Test a package in containers
conftest test pkgs/<package name>/*.yaml
prettier -w pkgs/<package name>/*.yaml
argd rm # Remove containers
argd rmp [<package>] # Remove installed packages from containers
argd gr # Update registry.yaml by merging pkgs/**/registry.yaml
argd con [<os>] [<arch>] # Connect a container by docker exec. This is useful for debugging.
argd lsa <owner/repo> <version> # List release assets of a GitHub Release
```

## Format with prettier

https://prettier.io/

```sh
npm i -g prettier
```

```sh
prettier -w registry.yaml
```

## argd scaffold (s) - Scaffold configuration and test it in containers

`argd scaffold (s) <package name>` generates a configuration file `pkgs/<package name>/registry.yaml` and a test data file `pkgs/<package name>/pkg.yaml`, and tests them in containers.
It gets data from GitHub Releases by GitHub API.
By default, it gets all releases, so it takes a bit long time if the repository has a lot of releases.
[`argd scaffold` isn't perfect, but you must use it when you add new packages.](#use-scaffold-command-definitely)

## argd test (t) - Test a package in containers

`argd test (t) [<package name>]` tests a package in containers.
If the branch name is `feat/<package name>`, you can omit the argument `<package name>`.
`argd test` copies files `pkgs/<package name>/{pkg.yaml,registry.yaml}` in containers and test them.
If the test succeeds, `registry.yaml` is updated.

## Linting

Please see [Lint pkgs/**/pkg.yaml and pkgs/**/registry.yaml.](lint.md)

## aqua-registry remove (rm) - Remove containers

`argd remove` removes containers.
`argd scaffold` and `argd test` reuse containers, but if you want to test packages in clean environment, you can do it by removing containers.

## argd remove-package (rmp) - Remove an installed package from containers

`argd remove-package (rmp) [<package name>]` removes an installed package from containers.
If the branch name is `feat/<package name>`, you can omit the argument `<package name>`.
It runs `aqua rm <package name>` and removes `aqua-checksums.json` in containers.
This task is useful when you want to test packages in clean environment.

## argd gr - Update `registry.yaml`

`argd gr` merges `pkgs/**/registry.yaml` and updates [registry.yaml](https://github.com/aquaproj/aqua-registry/blob/main/registry.yaml).
Please don't edit [registry.yaml](https://github.com/aquaproj/aqua-registry/blob/main/registry.yaml) directly.
When you edit `pkgs/**/registry.yaml`, please run `argd gr` to reflect the update to `registry.yaml` in the repository.

## argd connect (con) - Connect to a container

`argd con [<os>] [<arch>]` connect to a given container.
`argd scaffold` and `argd test` tests packages in containers.
`argd con` is useful to look into the trouble in containers.
By default, `<os>` is `linux` and `<arch>` is CPU architecture of your machine.

## argd list-assets (lsa) - List release assets

`argd list-assets (lsa) <owner/repo> <version>` lists the asset names of a GitHub Release.
This is useful when debugging asset name mismatches during package configuration.

## Code Auto-generation

Writing configuration files for each package from scratch is difficult and has quality issues.
Therefore, commands for auto-generating code are provided.
When adding a new package, always use this command.
Code written manually from scratch is not quality assured, so Pull Requests will not be accepted.
However, code auto-generation is not perfect and often generates incomplete code.
In that case, you need to manually fix the generated code.

aqua supports various package types, but auto-generation currently supports only `github_release` and `cargo`.
When generating code for package types other than `github_release` and `cargo`, such as `http`, specify `-l 1` to generate only a template and write the rest manually.

```sh
argd s -l 1 "<package name>"
```

## GitHub Access Token

Development tools execute GitHub API to get lists of GitHub Releases and assets.
It works without an access token, but the possibility of hitting API rate limits increases.
Hitting API rate limits can prevent normal code generation or cause tests to fail.
You can pass an access token through environment variables `GITHUB_TOKEN` or `AQUA_GITHUB_TOKEN`.
Or if `AQUA_GHTKN_ENABLED` is enabled, this tool will get an access token using [ghtkn integration](https://github.com/suzuki-shunsuke/ghtkn).
No special permissions are needed as it only reads public repository resources.
