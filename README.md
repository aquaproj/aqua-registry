# aqua-registry

[aqua](https://github.com/suzuki-shunsuke/aqua)'s Standard Registry

## How to use

[Example](https://github.com/suzuki-shunsuke/my-aqua-config/blob/main/aqua.yaml)

aqua.yaml

```yaml
registries:
- type: standard
  ref: v0.4.1 # renovate: depName=suzuki-shunsuke/aqua-registry
```

## Search packages from the Standard Registry by the command `aqua g`

Please add the Standard Registry to your aqua.yaml's registries, and run `aqua g`.

```yaml
registries:
- type: standard
  ref: v0.4.1 # renovate: depName=suzuki-shunsuke/aqua-registry
```

`aqua g` launches the interactive UI and you can search the package by fuzzy search.

```
  direnv (standard)
  consul (standard)
  conftest (standard)
> golangci-lint (standard)
  47/47
>
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

## License

[MIT](LICENSE)
