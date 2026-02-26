# Trouble shooting

## `cmdx new` fails to push a commit to the origin

:::info
We removed `cmdx new` from the guide.
You can still use `cmdx new`, but if you have any trouble with `cmdx new`, you can create a pull request without `cmdx new`.
[Please see the changelog for details.](changelog.md#why-did-we-remove-cmdx-new-from-the-guide)
:::

If `cmdx new` can't push a commit to a remote branch, please confirm if `origin` is not the upstream `aquaproj/aqua-registry` but your fork.
If `origin` is not your fork, please change it to your fork.

e.g. Fail to push a commit

```console
$ cmdx new pre-commit/pre-commit
# ...
+ git push origin feat/pre-commit/pre-commit
remote: Permission to aquaproj/aqua-registry.git denied to ***.
fatal: unable to access 'https://github.com/aquaproj/aqua-registry/': The requested URL returned error: 403
```

1. [If you haven't forked aquaproj/aqua-registry, please fork it](https://github.com/aquaproj/aqua-registry/fork).
2. Check remote repositories.

```sh
git remote -v
```

3. Please fix `origin`.

```sh
git remote set-url origin https://github.com/<your fork>
```

4. Please set `upstream` if necessary.

```sh
git remote add upstream https://github.com/aquaproj/aqua-registry
```
