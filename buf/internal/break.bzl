"""Defines buf_lint_breaking rule"""

load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(":common.bzl", "protoc_plugin_test")

_TOOLCHAIN = str(Label("//tools/protoc-gen-buf-breaking:toolchain_type"))

def _buf_breaking_test_impl(ctx):
    proto_infos = [t[ProtoInfo] for t in ctx.attr.targets]
    config = json.encode({
        "against_input": ctx.file.against.path,
        "limit_to_input_files": ctx.attr.limit_to_input_files,
        "exclude_imports": ctx.attr.exclude_imports,
        "input_config": {
            "version": "v1",
            "breaking": {
                "use": ctx.attr.use_rules,
                "except": ctx.attr.except_rules,
                "ignore_unstable_packages": ctx.attr.ignore_unstable_packages,
            },
        },
    })

    return protoc_plugin_test(ctx, proto_infos, ctx.executable._protoc, ctx.toolchains[_TOOLCHAIN].cli, config, [ctx.file.against])

buf_breaking_test = rule(
    implementation = _buf_breaking_test_impl,
    doc = """
This checks protocol buffers for breaking changes using `buf breaking`. For an overview of linting using buf please refer: https://docs.buf.build/lint/overview.

NOTE: In order to truly check breaking changes this rule should be used to check all `proto_library` targets that come under a common import path. Using separate for each `proto_library` target only checks the current target for breaking changes. Checking individual targets/packages for breaking changes has the obvious caveat of not being able to detect when an entire package/target is removed/moved

Example:
    This rule works alongside `proto_library` rule.

    load("@rules_buf//buf:defs.bzl", "buf_lint_test")
    load("@rules_proto//proto:defs.bzl", "proto_library")

    proto_library(
        name = "foo_proto",
        srcs = ["pet.proto"],
        deps = ["@go_googleapis//google/type:datetime_proto"],
    )

    buf_lint_test(
        name = "foo_proto_lint",
        except_rules = [
            "PACKAGE_VERSION_SUFFIX",
            "FIELD_LOWER_SNAKE_CASE",
        ],
        targets = [":foo_proto"],
        use_rules = ["DEFAULT"],
    )
    
""",
    attrs = {
        "_protoc": attr.label(
            default = "@com_github_protocolbuffers_protobuf//:protoc",
            executable = True,
            cfg = "exec",
        ),
        "targets": attr.label_list(
            providers = [ProtoInfo],
            doc = """`proto_library` targets to check breaking changes against.""",
        ),
        "against": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The image file against which breaking changes are checked. `rules_buf` provides a repository rule(`buf_image`) to reference an image from the buf schema registry",
        ),
        # buf config attrs
        "use_rules": attr.string_list(
            default = ["FILE"],
            doc = "https://docs.buf.build/breaking/configuration#use",
        ),
        "except_rules": attr.string_list(
            default = [],
            doc = "https://docs.buf.build/breaking/configuration#except",
        ),
        "limit_to_input_files": attr.bool(
            default = True,
            doc = "https://docs.buf.build/breaking/protoc-plugin",
        ),
        "ignore_unstable_packages": attr.bool(
            default = False,
            doc = "https://docs.buf.build/breaking/configuration#ignore_unstable_packages",
        ),
        "exclude_imports": attr.bool(
            default = True,
            doc = "https://docs.buf.build/breaking/protoc-plugin",
        ),
        "ignore": attr.string_list(
            default = [],
            doc = "https://docs.buf.build/lint/configuration#ignore",
        ),
        "ignore_only": attr.string_list_dict(
            doc = "https://docs.buf.build/lint/configuration#ignore_only",
        ),
    },
    toolchains = [_TOOLCHAIN],
    test = True,
)
