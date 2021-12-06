# rules_buf

Bazel rules and Gazelle extension for buf

## Setup 

Depends on [rules_proto](https://github.com/bazelbuild/rules_proto) and should be loaded before this. (Temporary solution, will be inclued in dependencides before release)

```starlark
local_repository(
    name = "rules_buf",
    path = "../",
)

load("@rules_buf//:repo.bzl", "rules_buf_toolchains")

rules_buf_toolchains()
```

See `example` folder for a basic setup.

## Image

`buf_image` repo rule provides a way to reference a buf image from BSR with byte-to-byte reproducability.

In a `WORKSPACE` file one can depend on a buf image at a specific commit.
```starlark
load("@rules_buf//:image.bzl", "buf_image")

buf_image(
    name = "petapis",
    module = "buf.build/alex/petapis",
    commit = "ed11b653d2f74267a3fa009f7c37f69a",
    sha256 = "e824b046b36047fd4d13f23919cbe3fe09653a28de5a5b5940a1a219aac3c44d",
)
```

In the future we can expose an image archive similar to github repo archives. This will allows us to use more standard repo rules such as `http_file` to fetch images.

## Linting

Depends on `rules_proto` for `FileDescriptorSet` and invokes using `protoc` and lint plugin, `protoc-gen-buf-lint`.

Lint test (`buf_lint_test`) is defined in `lint.bzl`. 

```starlark
buf_lint_test(
    name = "lint",
    except_rules = [
        "PACKAGE_VERSION_SUFFIX",
        "FIELD_LOWER_SNAKE_CASE",
        "SERVICE_SUFFIX",
    ],
    target = ":pet_v1_proto",
    use_rules = [
        "DEFAULT",
    ],
)
```

Provides all the options of the plugin except for `ignore` and `ignore_only`. These can be solved by creating seperate rules with limited files akin to `bazel`

## Breaking change detection

Depends on `rules_proto` for `FileDescriptorSet` and invokes using `protoc` and lint plugin, `protoc-gen-buf-lint`.

Breaking test (`buf_breaking_test`) is defined in `break.bzl`. 

```starlark
buf_breaking_test(
    name = "breaking",
    against = "@petapis//image:file",
    target = ":pet_v1_proto",
)
```

Notice that here a buf image is being referenced created using the the `buf_image` repo rule.

Provides all the options of the plugin except for `ignore` and `ignore_only`. These can be solved by creating seperate rules with limited files akin to `bazel`

## Toolchains

Provides bazel toolchains for `buf`, `protoc-gen-buf-breaking`, and `protoc-gen-buf-lint`. 

They can accessed at `@rules_buf//tools/buf:toolchain_type`, `@rules_buf//tools/protoc-gen-buf-breaking:toolchain_type`, and `@rules_buf//tools/protoc-gen-buf-lint:toolchain_type`

Supports `darwin` - `arm64/x86_64`, `windows` - `arm64/x86_64`, `linux` - `amd64/aarch64` (Github releases of buf)

## Tests

All rules have been tested manually on `darwin/arm64` (M1 Mac). Linux and Windows are implemented but yet to be tested. Automated tests need to be explored.


## Gazelle Extension

The repo also has Gazelle extension for auto generating the lint and breaking change detection rules. Just add the target `@rules_buf//gazelle/buf:buf` to `gazelle` languages. See example folder.

It automatically picks up `buf.yaml/buf.mod` file from repo root. It supports the following command line options,

* `buf_config` path to `buf.yaml` file relative to repo root
* `buf_breaking_image` file target of buf image to check against
