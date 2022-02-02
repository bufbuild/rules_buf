"""Defines buf_breaking_test rule"""

load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(":plugin.bzl", "protoc_plugin_test")

_DOC = """
This checks protocol buffers for breaking changes using `buf breaking`. 
For an overview of breaking change detection using buf please refer: https://docs.buf.build/breaking/overview.

**NOTE**: 
In order to truly check breaking changes this rule should be used to check all `proto_library` targets that come under a [buf module](https://docs.buf.build/bsr/overview#module). 
Using unique test targets for each `proto_library` target checks each `proto_library` target in isolation. 
Checking targets/packages in isolation has the obvious caveat of not being able to detect when an entire package/target is removed/moved.

**Gazelle**

The [gazelle extension](/gazelle/buf/README.md) can be used generate this rule. It supports generating once for buf module and also at a bazel package level.

**Example**

This rule depends on `proto_library` rule.

```starlark
load("@rules_buf//buf:defs.bzl", "buf_breaking_test")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "foo_proto",
    srcs = ["foo.proto"],
)

buf_breaking_test(
    name = "foo_proto_breaking",
    # Image file to check against. Please refer to https://docs.buf.build/reference/images.
    against = "@build_buf_foo_foo//:file",
    targets = [":foo_proto"],
    config = ":buf.yaml",
)
```
"""

_TOOLCHAIN = str(Label("//tools/protoc-gen-buf-breaking:toolchain_type"))

def _buf_breaking_test_impl(ctx):
    proto_infos = [t[ProtoInfo] for t in ctx.attr.targets]
    config = json.encode({
        "against_input": ctx.file.against.short_path,
        "limit_to_input_files": ctx.attr.limit_to_input_files,
        "exclude_imports": ctx.attr.exclude_imports,
        "input_config": ctx.file.config.short_path,
    })

    return protoc_plugin_test(
        ctx,
        proto_infos,
        ctx.executable._protoc,
        ctx.toolchains[_TOOLCHAIN].cli,
        config,
        [ctx.file.against, ctx.file.config],
    )

buf_breaking_test = rule(
    implementation = _buf_breaking_test_impl,
    doc = _DOC,
    attrs = {
        "_protoc": attr.label(
            default = "@com_google_protobuf//:protoc",
            executable = True,
            cfg = "exec",
        ),
        "targets": attr.label_list(
            providers = [ProtoInfo],
            doc = """`proto_library` targets to check for breaking changes""",
        ),
        "against": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = """The image file against which breaking changes are checked. This is typically derived from HEAD/last release tag of your repo/bsr. `rules_buf` provides a repository rule(`buf_image`) to reference an image from the buf schema registry""",
        ),
        "config": attr.label(
            allow_single_file = True,
            doc = """The `buf.yaml` file""",
        ),
        "limit_to_input_files": attr.bool(
            default = True,
            doc = """Checks are limited to input files. If a file gets deleted that will not be caught. Please refer to https://docs.buf.build/breaking/protoc-plugin for more details""",
        ),
        "exclude_imports": attr.bool(
            default = True,
            doc = """Checks are limited to the source files excluding imports from breaking change detection. Please refer to https://docs.buf.build/breaking/protoc-plugin for more details""",
        ),
    },
    toolchains = [_TOOLCHAIN],
    test = True,
)
