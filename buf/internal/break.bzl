"""Defines buf_lint_breaking rule"""

load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(":common.bzl", "protoc_plugin_test")

_TOOLCHAIN = str(Label("//tools/protoc-gen-buf-breaking:toolchain_type"))

def _buf_breaking_test_impl(ctx):
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

    return protoc_plugin_test(ctx, ctx.executable._protoc, ctx.toolchains[_TOOLCHAIN].cli, config, [ctx.file.against])

buf_breaking_test = rule(
    implementation = _buf_breaking_test_impl,
    attrs = {
        "_protoc": attr.label(
            default = "@com_github_protocolbuffers_protobuf//:protoc",
            executable = True,
            cfg = "exec",
        ),
        "target": attr.label(
            providers = [ProtoInfo],
            mandatory = True,
        ),
        "against": attr.label(
            mandatory = True,
            allow_single_file = True,
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
