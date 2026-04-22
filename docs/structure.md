# Repository Structure

Package-related code is located in the `pkgs/<package name>` directory of https://github.com/aquaproj/aqua-registry.
e.g. [cli/cli](https://github.com/aquaproj/aqua-registry/tree/main/pkgs/cli/cli)
Each package directory contains the following files:

- pkg.yaml: List of versions installed during testing. This is essentially test data
- registry.yaml: Configuration. Each tool's registry.yaml is merged to generate the repository root registry.yaml
- scaffold.yaml: Optional. Configuration file for commands that auto-generate pkg.yaml and registry.yaml. Required when you want to change the auto-generation behavior

:::note
pkg.yaml is just test data. You can install versions not included in this file.
:::

There is also a registry.yaml at the repository root, which is a huge YAML file merging all registry.yaml files under `pkgs`.
When specifying Standard Registry in aqua.yaml, this repository root registry.yaml is referenced.
To modify the repository root registry.yaml, modify the registry.yaml under pkgs and run the `cmdx gr` command.
