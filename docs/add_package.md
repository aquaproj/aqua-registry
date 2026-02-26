# Adding New Tools

When submitting a Pull Request to add a new tool, there's no need to create an Issue.

Run `cmdx s` to auto-generate code.

```sh
cmdx s "<tool name>"
```

e.g.

```sh
cmdx s cli/cli
```

For package types other than github_release, specify `-l 1`.

```sh
cmdx s -l 1 "<package name>"
```

cmdx s generates a branch `feat/<package name>`, code, and commit, and tests using containers.

:::caution
`cmdx s` creates a commit, but please don't edit the commit by `git commit --amend`, `git rebase`, or somehow.
`cmdx s` creates a commit to distinguish scaffolded code from manual changes.
Please add new commits if you update code.
:::

:::info
This command may sometimes fail tests and output a large amount of error messages, but don't be overwhelmed by those error messages.
Test failures are expected.
:::

## Customizing cmdx s with Configuration File

:::note
In many cases, this is unnecessary.
Also, you should not use this feature carelessly.
:::

Sometimes `cmdx s` generation doesn't work in one go.
For github_release packages, `cmdx s` gets lists of GitHub Releases and assets via GitHub API and auto-generates configuration based on that.
However, sometimes you need to exclude specific versions or assets.
For example, if multiple CLIs are published in the same repository, if you don't exclude assets from other CLIs, code might be generated based on asset names from other CLIs.
Also, if multiple tools are published in the same repository, versions might have different prefixes for different tools.
In that case, if you don't ignore versions from other tools, code likely won't be generated correctly.

In such cases, follow these steps:

1. Generate a template configuration file `aqua-generate-registry.yaml` for `cmdx s` with `aqua gr -init <package name>`
2. Modify the configuration file `aqua-generate-registry.yaml`
3. Generate code with `cmdx s -c "<configuration file>" "<package name>"`

You can configure the following:

- `version_filter`: Versions not matching this condition are excluded
- `version_prefix`: Versions without this prefix are excluded
- `all_assets_filter`: Assets not matching this condition are excluded

However, using this feature carelessly can exclude things that shouldn't be excluded, so it shouldn't be used lightly.
`all_assets_filter` in particular requires caution. This is because it can accidentally exclude checksum files like `SHA256SUM` or `checksums.txt`, and it's difficult to notice if you've excluded them.
Therefore, you should first generate code without exclusion settings, and if unnecessary things are mixed in the generated code, write settings that explicitly exclude only those (without making the scope too broad to avoid excluding extra things).

:::caution
Note that `version_filter` is not a feature for dropping support for old versions.
`version_constraint`, `no_asset`, and `error_message` are used for dropping support for old versions.

https://github.com/aquaproj/aqua-registry/blob/191f2136c10b1eb962dd43c8f421af417b1b3a16/pkgs/Shopify/ejson/registry.yaml#L8-L10
:::

## Retrying `cmdx s` Until It Works

:::note
In many cases, this is unnecessary.
:::

As mentioned earlier, code generation with `cmdx s` doesn't always work on the first try.
Sometimes you need to repeat it several times.

1. Generate code without configuration file `cmdx s`
2. Check the generated code, and if extra versions or assets are included, delete the generated branch

`cmdx s` generates a branch and commit, but if it's before opening a Pull Request, you can delete them without problems.

```sh
git checkout main
git branch -D "feat/<package name>"
```

3. Generate configuration file `aqua gr -init`
4. Modify configuration file and generate code `cmdx s`
5. Repeat 2, 4 until extra versions and assets are excluded

## Modifying Manually

If installation of multiple versions is failing and the log is hard to read, it's good to comment out some versions in pkg.yaml and tackle problems one by one.
When modifying configuration, refer to [Manual Modification](#manual-modification) and [Style Guide](/docs/develop-registry/registry-style-guide/).
After modification, run `cmdx t` to confirm it can be installed correctly.
Repeat modification and confirmation until it can be installed.

When you're done with modifications, or if you're not sure how to fix it, submit a Pull Request.

:::note
The `cmdx new` command has been removed from the standard procedure.
However, the command itself remains and can still be used.
This command has large environment dependencies and didn't work well for some users, making troubleshooting and support difficult.
Since you can create Pull Requests without using `cmdx new`, we decided to remove it from the standard procedure.
[See also changelog.](/docs/products/aqua-registry/changelog#why-did-we-remove-cmdx-new-from-the-guide)
:::

## Use `cmdx s` definitely

We don't accept pull requests not following this guide.
Especially, we don't accept pull requests not using `cmdx s`.
Standard Registry must support not only the latest version but also almost all versions and [various platforms](#supported-os-and-cpu-architecture).
Many tools have so many versions that people can't check all of them manually.
So we can't trust the code not using `cmdx s`.
`cmdx s` checks all GitHub Releases and generates code supporting all of them (Strictly speaking, if there are too many GitHub Releases we have to restrict the number of GitHub Releases, though `cmdx s` can still check over 200 versions).
`cmdx s` generates much better code than us.

`cmdx s` isn't perfect and sometimes `cmdx s` causes errors and generates invalid code.
Then you have to fix the code according to the error message.
`cmdx s` supports only `github_release` type packages, so for other package types you have to fix the code.
Even if so, you must still use `cmdx s`.
`cmdx s` guarantees the quality of code.

## :bulb: How to ignore some assets and versions

You can ignore some assets and versions to scaffold better configuration files.

:::caution
Be careful to use this feature as it may exclude assets and versions unexpectedly.
Especially, `all_assets_filter` may exclude assets such as checksum files.
We recommend to scaffold codes without this feature first.
Then if `cmdx s` can't scaffold good codes due to some noisy versions or assets, you should re-scaffold code using this feature.
About `all_assets_filter`, we recommend specifying patterns to exclude assets (deny list) rather than specifying patterns to include assets (allow list).

e.g.

```yaml
all_assets_filter: not (Asset contains "static")
```
:::

1. Create `aqua-generate-registry.yaml` by `aqua gr --init` command:

```sh
aqua gr --init <package name>
```

2. Edit `aqua-generate-registry.yaml`:

Example 1. Filter assets:

```yaml
name: argoproj/argo-rollouts
all_assets_filter: not ((Asset matches "rollouts-controller") or (Asset matches "rollout-controller"))
```

Example 2. Filter versions by `version_prefix`:

```yaml
name: grpc/grpc-go/protoc-gen-go-grpc
version_prefix: cmd/protoc-gen-go-grpc/
```

Example 3. Filter versions by `version_filter`:

```yaml
name: crate-ci/typos
version_filter: not (Version startsWith "varcon-")
```

3. Run `cmdx s` with `aqua-generate-registry.yaml`

```sh
cmdx s -c aqua-generate-registry.yaml
```
