# v2 `buf.yaml` workspace

This example demonstrates using `rules_buf` with a [v2 `buf.yaml`](https://buf.build/docs/configuration/v2/buf-yaml) workspace. A single root `buf.yaml` declares the workspace's modules under `modules:` and applies shared `lint` and `breaking` configuration across all of them.

- The root `buf.yaml` is exported in [BUILD](BUILD).
- Each `buf_lint_test` and `buf_breaking_test` references the root `buf.yaml` via `config = "//:buf.yaml"` and identifies its module with the `module` attribute (e.g. `module = "fooapis"`).
- `proto_library` rules use `strip_import_prefix` so that imports resolve relative to the module root ([fooapis/foo/v1](fooapis/foo/v1/BUILD.bazel), [barapis/bar/v1](barapis/bar/v1/BUILD.bazel)).

See the [Gazelle example](../gazelle) for how to generate these rules automatically.
