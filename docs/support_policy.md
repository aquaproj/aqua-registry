# Support Policy

## aqua can't support some tools' plugin mechanism

Some tools have the plugin mechanism.

e.g.

- [GitHub CLI Extension](https://docs.github.com/en/github-cli/github-cli/creating-github-cli-extensions)
- [Terraform provider](https://developer.hashicorp.com/terraform/language/providers)
- [Gauge plugin](https://docs.gauge.org/plugin.html?os=macos&language=java&ide=null)
- etc

aqua simply installs commands in PATH (`AQUA_ROOT_DIR/bin`), but some of these plugins expect to be installed in the other location.
If aqua can't support the plugin, we will reject the pull request adding the plugin to aqua-registry.

So if you send a pull request adding a plugin to aqua-registry, please check if aqua can support the plugin.
We aren't necessarily familiar with the plugin, so please explain where the plugin expects to be installed and how the plugin works in the pull request description.

If you don't know well, please create a pull request and consult us.

## Note of Programming Language Support

aqua supports several programming languages such as Go and Node.js, but when we support a programming language, we need to be careful about where the programming language installs libraries and commands.

For instance, if the programming language installs commands in the same directory with the programming language itself, aqua can't add them to $PATH, meaning we can't execute them.
aqua doesn't support changing $PATH dynamically (We have no plan to support it as it makes aqua more complicated).
Node.js's `npm i -g` installs the same directory with node by default, so we gave up the support of Node.js before (Now aqua supports Node.js again because we can change the install path by `NPM_CONFIG_PREFIX`).
If the language installs libraries in the same directory with it, the language can't refer installed libraries when we change the version of the language.

So before supporting a programming language, we should consider carefully if it really works well.
Many programming languages have dedicated version managers, so maybe they are more appropriate.

## Supported OS and CPU Architecture

Please consider the following OS and CPU Architecture.
We test the registry in CI on the above environments by GitHub Actions' build matrix.

- OS
  - windows
  - darwin
  - linux
- CPU Architecture
  - amd64
  - arm64
