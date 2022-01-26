# rules_buf

Bazel rules for buf

## Setup 

Include the following snippet in the Workspace file to setup `rules_buf`. Refer to release notes of a specific version for setup instructions.
```starlark
local_repository(
    name = "rules_buf",
    path = "../",
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
