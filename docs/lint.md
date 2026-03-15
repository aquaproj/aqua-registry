# Lint `pkgs/**/pkg.yaml` and `pkgs/**/registry.yaml`

You can lint `pkgs/**/pkg.yaml` and `pkgs/**/registry.yaml` using [Conftest](https://www.conftest.dev/)
For example, if you create or update a package `suzuki-shunsuke/pinact`, you can lint it using the following command:

```sh
conftest test --combine pkgs/suzuki-shunsuke/pinact/*
```
