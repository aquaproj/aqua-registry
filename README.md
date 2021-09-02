# aqua-registry

[aqua](https://github.com/suzuki-shunsuke/aqua)'s Official Registry

## How to use

[Example](aqua.yaml)

aqua.yaml

```yaml
registries:
- name: official
  type: github_content
  repo_owner: suzuki-shunsuke
  repo_name: aqua-registry
  path: registry.yaml
  ref: v0.1.1-0 # renovate: depName=suzuki-shunsuke/aqua-registry
```

## License

[MIT](LICENSE)
