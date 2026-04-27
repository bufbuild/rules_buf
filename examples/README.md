# Examples

Examples on how to use `rules_buf` in various scenarios. For more info refer to the [official docs](https://buf.build/docs/cli/build-systems/bazel).

## Scenarios

### [Bazel Modules](bzlmod)

This demonstrates using this repo with [Bazel modules](https://bazel.build/versions/9.1.0/external/overview).

### [Version](version)

This demonstrates basic setup and pinning a `buf` cli version. This also demonstrates using the `buf` cli as a bazel toolchain.

### [Gazelle](gazelle)

This demonstrates setting up the `gazelle` plugin to generate `proto_library`, `buf_lint_test`, and `buf_breaking_test` rules.

### [Single Module](single_module)

This demonstrates setting up lint and breaking tests in a project with a `buf.yaml`.

### [Workspaces](workspace)

This demonstrates setting up lint and breaking tests in a [v1 `buf.work.yaml`](https://buf.build/docs/configuration/v1/buf-work-yaml/) workspace project.

### [v2](v2)

This demonstrates setting up lint and breaking tests using a [v2 `buf.yaml`](https://buf.build/docs/configuration/v2/buf-yaml) workspace.

### [Echo](echo)

A minimal end-to-end example: `proto_library` plus generated Connect/Go server code, built and run via Bazel.

### [Toolchain](toolchain)

This demonstrates using the `buf_format` rule together with the [`toolchains_protoc`](https://github.com/aspect-build/toolchains_protoc) hermetic `protoc` toolchain.

### [Unused](unused)

This exercises the lint extension's behavior on a `proto_library` that includes an unused import, using the standard `protobuf` Bazel module for `protoc`.
