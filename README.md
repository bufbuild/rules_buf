# rules_buf

Bazel rules for buf

## Setup 

Include the following snippet in the Workspace file to setup `rules_buf`
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
- [buf_repository](/buf#buf_repository)

## Gazelle Extension

The repo also has Gazelle extension for auto generating the lint and breaking change detection rules. In addition to generating test rules it can also be used to manage protocol buffer dependencies powered by the buf schema registry.

Please refer the [gazelle readme](/gazelle/buf) for detailed info on various actions and options possible.

## Toolchains

- [buf](/tools)
- [protoc-gen-buf-lint](/tools)
- [protoc-gen-buf-breaking](/tools)
