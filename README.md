# rules_buf

Bazel rules for [Buf](https://buf.build/).

## Setup 

Include the following snippet in the Workspace file to setup `rules_buf`. Refer to [release notes](https://github.com/bufbuild/rules_buf/releases) of a specific version for setup instructions.
```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_buf",
    sha256 = "d6b2513456fe2229811da7eb67a444be7785f5323c6708b38d851d2b51e54d83",
    urls = [        
        "https://github.com/bufbuild/rules_buf/releases/download/v1.0.0-rc11/rules_go-v1.0.0-rc11.zip",
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

See [examples](examples) for how to setup and use for various scenarios.

Depends on [rules_proto](https://github.com/bazelbuild/rules_proto). To use a specific version load it before calling `rules_buf_dependencies`

## List of rules
- [buf_lint_test](/buf#buf_lint_test)
- [buf_breaking_test](/buf#buf_lint_test)

## Gazelle Extension

The repo also has Gazelle extension for auto generating the lint and breaking change detection rules.

Please refer to the [gazelle readme](/gazelle/buf) for detailed info on various actions and options possible.

## Toolchains

- [buf](/tools)
- [protoc-gen-buf-lint](/tools)
- [protoc-gen-buf-breaking](/tools)
