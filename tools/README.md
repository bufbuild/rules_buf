# Buf Toolchains

Provides buf tools as bazel toolchains all of them are supported on 
 - macOS
 - Windows
 - Linux

 On `amd64` and `arm64`

| Tool | Label | 
|--|--|
| buf | `@rules_buf//tools/buf:toolchain_type` |
| protoc-gen-buf-lint | `@rules_buf//tools/protoc-gen-buf-lint:toolchain_type` |
| protoc-gen-buf-breaking | `@rules_buf//tools/protoc-gen-buf-breaking:toolchain_type` |

