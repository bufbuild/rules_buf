# rules_buf

Bazel rules for [Buf](https://buf.build/). The rules work alongside the `proto_library` rule of [rules_proto](https://github.com/bazelbuild/rules_proto).

## Status

This module is a beta, but we may make a few changes as we gather feedback from early adopters.

## Setup

### Bazel modules (`MODULE.bazel`)

`rules_buf` is published to the [Bazel Central Registry](https://registry.bazel.build/modules/rules_buf). Add the following to your `MODULE.bazel`:

```starlark
bazel_dep(name = "rules_buf", version = "0.5.2")

buf = use_extension("@rules_buf//buf:extensions.bzl", "buf")

# Pin the buf CLI version (optional; a default version is used otherwise).
buf.toolchains(version = "v1.68.4")

use_repo(buf, "rules_buf_toolchains")
```

### Legacy `WORKSPACE`

For projects that have not yet migrated to Bazel modules:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_buf",
    sha256 = "4a024a411996967c3a3f49b04765bd016169a2c79be3dc78aa62bfa2643850ef",
    strip_prefix = "rules_buf-0.5.2",
    urls = [
        "https://github.com/bufbuild/rules_buf/releases/download/v0.5.2/rules_buf-0.5.2.tar.gz",
    ],
)

load("@rules_buf//buf:repositories.bzl", "rules_buf_dependencies", "rules_buf_toolchains")

rules_buf_dependencies()

rules_buf_toolchains(version = "v1.68.4")

# rules_proto
load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies")

rules_proto_dependencies()

load("@rules_proto//proto:setup.bzl", "rules_proto_setup")

rules_proto_setup()
```

Refer to the latest [release notes](https://github.com/bufbuild/rules_buf/releases) for the exact `sha256` and version to pin.

Refer to the [docs](https://buf.build/docs/cli/build-systems/bazel) or browse the [examples](examples) on how to set up and use `rules_buf` in various scenarios.

## List of rules

- [buf_dependencies](https://buf.build/docs/cli/build-systems/bazel#buf-dependencies)
- [buf_lint_test](https://buf.build/docs/cli/build-systems/bazel#buf-lint-test)
- [buf_breaking_test](https://buf.build/docs/cli/build-systems/bazel#buf-breaking-test)
- [buf_format](https://buf.build/docs/cli/build-systems/bazel#buf-format)

## Gazelle Extension

The repo also offers a Gazelle extension for generating the rules.

Please refer to the [gazelle section](https://buf.build/docs/cli/build-systems/bazel#gazelle) in the docs.

## Development

The repository follows the [official recommendation](https://bazel.build/rules/deploying) on deploying bazel rules.
All the rule definitions are in [buf/internal](buf/internal).

### Gazelle

Gazelle extension is in [gazelle/buf](gazelle/buf). Before looking at the code it would be best to understand the [architecture of gazelle](https://github.com/bazelbuild/bazel-gazelle/blob/master/Design.rst). The file structure is loosely based on the `go` and `proto` [extensions](https://github.com/bazelbuild/bazel-gazelle/tree/master/language) that are shipped with gazelle.
They are also excellent to better understand the architecture.

The main entry point to the extension is via the `NewLanguage` function in [gazelle/buf/buf.go](gazelle/buf/buf.go). Gazelle mostly depends on [`Language`](https://pkg.go.dev/github.com/bazelbuild/bazel-gazelle@v0.34.0/language#Language) interface. Apart from that one can also implement some optional interfaces.

We implement the following interfaces,

- [`Language`](https://pkg.go.dev/github.com/bazelbuild/bazel-gazelle@v0.34.0/language#Language): Required. Used for build/test rule generation and label resolutions for these rules.
- [`RepoImporter`](https://pkg.go.dev/github.com/bazelbuild/bazel-gazelle@v0.34.0/language#RepoImporter): Optional. Used to generate `buf_dependencies` rule from `buf.yaml`/`buf.work.yaml`.
- [`CrossResolver`](https://pkg.go.dev/github.com/bazelbuild/bazel-gazelle@v0.34.0/resolve#CrossResolver): Optional. Used to resolve dependencies across extensions/languages. We use it to resolve any proto files that are part of `buf_dependencies` rules.
