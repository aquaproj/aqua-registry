# Development Tools

Unfortunately, the current development tools depend on Shell Scripts and are unlikely to work on Windows (though they probably work on WSL).
[There is an issue to rewrite them in Go.](https://github.com/aquaproj/aqua-registry/issues/32699)

CLIs for developing aqua-registry are provided.
These can be installed with aqua.
Check out aqua-registry and run `aqua i -l`.

```sh
aqua i -l
```

We use a task runner called [cmdx](https://github.com/suzuki-shunsuke/cmdx).
You can check tasks with `cmdx help`.

```sh
cmdx help
```

Using development tools, you can generate files for each package (pkg.yaml, registry.yaml, scaffold.yaml) and test tool installation in containers.
Tests are performed in containers using the docker command, so you need the docker command and a compatible container engine.
Docker Desktop would work fine of course.
We install [docker/cli](https://github.com/docker/cli) and [abiosoft/colima](https://github.com/abiosoft/colima) with aqua.
Please confirm that the docker command works.

```sh
docker version
```

## Format with prettier

https://prettier.io/

```sh
npm i -g prettier
```

```sh
prettier -w registry.yaml
```

## cmdx s - Scaffold configuration and test it in containers

`cmdx s <package name>` generates a configuration file `pkgs/<package name>/registry.yaml` and a test data file `pkgs/<package name>/pkg.yaml`, and tests them in containers.
It gets data from GitHub Releases by GitHub API.
By default, it gets all releases, so it takes a bit long time if the repository has a lot of releases.
[`cmdx s` isn't perfect, but you must use it when you add new packages.](#use-cmdx-s-definitely)

## cmdx t - Test a package in containers

`cmdx t [<package name>]` tests a package in containers.
If the branch name is `feat/<package name>`, you can omit the argument `<package name>`.
`cmdx t` copies files `pkgs/<package name>/{pkg.yaml,registry.yaml}` in containers and test them.
If the test succeeds, `registry.yaml` is updated.

## cmdx rm - Remove containers

`cmdx rm` removes containers.
`cmdx s` and `cmdx t` reuse containers, but if you want to test packages in clean environment, you can do it by removing containers.

## cmdx rmp - Remove an installed package from containers

`cmdx rmp [<package name>]` removes an installed package from containers.
If the branch name is `feat/<package name>`, you can omit the argument `<package name>`.
It runs `aqua rm <package name>` and removes `aqua-checksums.json` in containers.
This task is useful when you want to test packages in clean environment.

## cmdx gr - Update `registry.yaml`

`cmdx gr` merges `pkgs/**/registry.yaml` and updates [registry.yaml](https://github.com/aquaproj/aqua-registry/blob/main/registry.yaml).
Please don't edit [registry.yaml](https://github.com/aquaproj/aqua-registry/blob/main/registry.yaml) directly.
When you edit `pkgs/**/registry.yaml`, please run `cmdx gr` to reflect the update to `registry.yaml` in the repository.

## cmdx con - Connect to a container

`cmdx con [<os>] [<arch>]` connect to a given container.
`cmdx s` and `cmdx t` tests packages in containers.
`cmdx con` is useful to look into the trouble in containers.
By default, `<os>` is `linux` and `<arch>` is CPU architecture of your machine.

## Code Auto-generation

Writing configuration files for each package from scratch is difficult and has quality issues.
Therefore, commands for auto-generating code are provided.
When adding a new package, always use this command.
Code written manually from scratch is not quality assured, so Pull Requests will not be accepted.
However, code auto-generation is not perfect and often generates incomplete code.
In that case, you need to manually fix the generated code.

aqua supports various package types, but currently auto-generation mainly supports only `github_release` and `cargo`.
When generating code for other packages like `http` package, specify `-l 1` to generate only a template and write the rest manually.

```sh
cmdx s -l 1 "<package name>"
```

## GitHub Access Token

Development tools execute GitHub API to get lists of GitHub Releases and assets.
It works without an access token, but the possibility of hitting API rate limits increases.
Hitting API rate limits can prevent normal code generation or cause tests to fail.
You can pass an access token through environment variables `GITHUB_TOKEN` or `AQUA_GITHUB_TOKEN`.
If these environment variables are not set, it will try to get an access token using the `gh auth token` command.
No special permissions are needed as it only reads public repository resources.
