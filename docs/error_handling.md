# Tool Installation Error Handling

## When Configuration Needs to Change for Specific Versions

You can change configuration by version using [version_overrides and version_constraint](https://aquaproj.github.io/docs/reference/registry-config/version-overrides).

## When Configuration Needs to Change for Specific OS/Arch

You can change configuration by OS/Arch with [overrides](https://aquaproj.github.io/docs/reference/registry-config/overrides).

## When Version Cannot Be Found

Sometimes a released version is deleted and disappears.
In that case, delete that version from pkg.yaml.
And delete configuration related to that version from registry.yaml (if any).
However, [no_asset](https://aquaproj.github.io/docs/reference/registry-config/no_asset) and [error_message](https://aquaproj.github.io/docs/reference/registry-config/error_message) don't need to be deleted.
You may or may not add `no_asset` and `error_message`.

## When Asset Cannot Be Found

When an asset cannot be found, either the asset name is wrong or the asset hasn't been released.

Running the `cmdx lsa [-r <repository name>] "<version>"` command outputs a list of assets, which is convenient.

```console
$ cmdx lsa -repo suzuki-shunsuke/pinact v3.0.0
+ REPO=${REPO#https://github.com/}
repo=$(bash scripts/get_test_pkg.sh "$REPO")

gh release view --json assets --jq ".assets[].name" -R "$repo" "$VERSION"

multiple.intoto.jsonl
pinact_3.0.0_checksums.txt
pinact_3.0.0_checksums.txt.pem
pinact_3.0.0_checksums.txt.sig
pinact_darwin_amd64.tar.gz
pinact_darwin_arm64.tar.gz
pinact_linux_amd64.tar.gz
pinact_linux_arm64.tar.gz
pinact_windows_amd64.zip
pinact_windows_arm64.zip
```

It's common for new GitHub Releases or tags to be released without assets being released.
When there are no assets, the following causes are possible:

1. Release is simply delayed. It will be released if you wait
2. CI failed midway and wasn't released
3. CI skipped the release

These are not problems with aqua or aqua-registry.
For example, if such a problem occurs with [suzuki-shunsuke/pinact](https://github.com/suzuki-shunsuke/pinact) and you want to take action, it would be good to create an issue or PR at https://github.com/suzuki-shunsuke/pinact.
As aqua-registry maintainers, we often encounter these problems.
Each time, we report problems to various repositories or fix CI.

It's common for specific os/arch not to be supported.
In that case, you need to exclude that os/arch from `supported_envs`.

If the asset name is wrong, the asset naming convention may have changed from a certain version.
For example, the GoReleaser configuration was modified and the format became zip, or the version disappeared from the asset name, etc.
In that case, you need to modify the asset in registry.yaml.
If the name changed due to a mistake on the tool side, it would be kind to report the problem or create a PR to fix it.

## When Command Cannot Be Found

When a command cannot be found, the following possibilities exist:

1. Command name is wrong
2. Command name changed
3. Path is wrong
4. Target os/arch is excluded by supported_envs

In these cases, you need to modify the `files` configuration.

```yaml
files:
  - name: <command name>
    src: <relative path to command executable>
```

By default, the command name is the last element when splitting the package name by `/`.
So for `cli/cli` it becomes `cli`, but the actual command name is `gh`, so you need to explicitly specify `files`.

```yaml
files:
  - name: gh
```

Note that even on Windows, `.exe` is not added to the name.

`src` is the relative path where the command executable is located when extracting assets like tarball or zip.
By default, it's the same as `name`.
For gh, since the path is different, you need to specify `src`.

```yaml
    files:
      - name: gh
        src: gh_{{trimV .Version}}_{{.OS}}_{{.Arch}}/bin/gh
```

https://github.com/aquaproj/aqua-registry/blob/dc98ca0c3314ae3cface74556a295a4cb0a95918/pkgs/cli/cli/registry.yaml#L7-L9

The auto-generation tool currently cannot auto-generate `files`.
Therefore, manual modification is necessary.

## Adding Support for Specific OS / Architecture

Sometimes a tool supports new OS/Architecture from a specific version but it's not reflected in registry.yaml and remains uninstallable.
In that case, you need to add that OS/Architecture to `supported_envs`.

## When Checksum Cannot Be Extracted from Checksum File

Please see [the document](https://aquaproj.github.io/docs/reference/registry-config/checksum).

## When Checksum Verification Fails

Please see [the document](https://aquaproj.github.io/docs/reference/registry-config/checksum).

1. Checksum written in checksum file is wrong => Disable checksum

```yaml
checksum:
  enabled: false
```

Or delete the checksum configuration since it's disabled by default.

:::info
The checksum enable/disable setting in registry configuration is just a setting for "whether to download checksum file and get checksum".
Even if this is disabled, if checksum verification is enabled in aqua.yaml, checksum verification will be performed.
In that case, it actually downloads the asset, calculates the checksum, and records it in aqua-checksums.json.
There is also an issue for getting checksum via GitHub API.
:::

2. Extracting wrong string from checksum file

Modify extraction parameters or disable checksum.

3. Wrong checksum algorithm (sha1, sha256, sha512, md5, etc) => Fix the algorithm

## When cosign Verification Fails

[Please see the document](https://aquaproj.github.io/docs/reference/registry-config/cosign).

## When SLSA Provenance Verification Fails

[Please see the document](https://aquaproj.github.io/docs/reference/registry-config/slsa-provenance).

## When GitHub Artifact Attestations Verification Fails

[Please see the document](https://aquaproj.github.io/docs/reference/registry-config/github-artifact-attestations).

`signer_workflow` might be wrong.
If attestations are not generated for a specific version in the first place, delete the github_artifact_attestations configuration.

The github_artifact_attestations configuration cannot be auto-generated currently.
Therefore, when adding a new tool, check if attestations are generated and add the configuration if they are.

## When Minisign Verification Fails

[Please see the document](https://aquaproj.github.io/docs/reference/registry-config/minisign).

The minisign configuration might be wrong.
If minisign signing is not performed for a specific version in the first place, delete the minisign configuration.
