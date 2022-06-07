# rules_buf

Bazel rules for [Buf](https://buf.build/).

## Status

In alpha. Not ready for production use.

## Setup

Include the following snippet in the Workspace file to setup `rules_buf`. Refer to [release notes](https://github.com/bufbuild/rules_buf/releases) of a specific version for setup instructions.

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_buf",
    sha256 = "d6b2513456fe2229811da7eb67a444be7785f5323c6708b38d851d2b51e54d83",
    urls = [
        "https://github.com/bufbuild/rules_buf/releases/download/v0.1.0/rules_buf-v0.1.0.zip",
    ],
)

load("@rules_buf//buf:repositories.bzl", "rules_buf_dependencies", "rules_buf_toolchains")

rules_buf_dependencies()

rules_buf_toolchains()

# rules_proto
load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")

rules_proto_dependencies()

rules_proto_toolchains()
```

Refer to the [official docs](https://docs.buf.build/build-systems/bazel) or browse the [examples](examples) on how to setup and use for various scenarios.

## List of rules

- [buf_lint_test](https://docs.buf.build/build-systems/bazel#buf-lint-test)
- [buf_breaking_test](https://docs.buf.build/build-systems/bazel#buf-breaking-test)

## Gazelle Extension

The repo also has Gazelle extension for generating the lint and breaking change detection rules.

Please refer to the [gazelle section](https://docs.buf.build/build-systems/bazel#gazelle) in the docs.
