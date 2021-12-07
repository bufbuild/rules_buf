"""Defines buf_lint_test rule"""

load("@rules_proto//proto:defs.bzl", "ProtoInfo")

BufLintInfo = provider(
    fields = {
        "error_file": "File containing lint errors",
    },
)

_TOOLCHAIN = str(Label("//tools/protoc-gen-buf-lint:toolchain_type"))

def _buf_lint_aspect_impl(target, ctx):
    if ctx.rule.kind == "proto_library":
        proto_info = target[ProtoInfo]

        args = ctx.actions.args()

        args.add_joined(
            ["--plugin", "protoc-gen-buf-lint", ctx.toolchains[_TOOLCHAIN].cli],
            join_with = "=",
        )
        args.add_all(
            ["--descriptor_set_in"],
        )
        descriptor_sets = proto_info.transitive_descriptor_sets.to_list()
        descriptor_sets.append(proto_info.direct_descriptor_set)
        args.add_joined(
            descriptor_sets,
            join_with = ":",
        )

        args.add("--buf-lint_out=.")
        args.add_all(proto_info.direct_sources)
        out = ctx.actions.declare_file("lint.txt")

        inputs = [ctx.toolchains[_TOOLCHAIN].cli] + descriptor_sets

        ctx.actions.run(
            outputs = [out],
            inputs = inputs,
            executable = ctx.executable._protoc,
            arguments = [args],
        )

        return [
            BufLintInfo(
                error_file = out,
            ),
        ]

    return [BufLintInfo(error_file = "")]

buf_lint_aspect = aspect(
    implementation = _buf_lint_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_protoc": attr.label(
            default = "@protobuf//:protoc",
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = [_TOOLCHAIN],
)

def _buf_lint_rule_impl(ctx):
    files = []
    for dep in ctx.attr.deps:
        files.append(dep[BufLintInfo].error_file)

    return DefaultInfo(
        files = depset(files),
    )

buf_lint_rule = rule(
    implementation = _buf_lint_rule_impl,
    attrs = {
        "deps": attr.label_list(
            aspects = [buf_lint_aspect],
            providers = [ProtoInfo],
            mandatory = True,
        ),
    },
)

def _buf_lint_test_impl(ctx):
    proto_info = ctx.attr.target[ProtoInfo]
    config = json.encode({
        "input_config": {
            "version": "v1",
            "lint": {
                "use": ctx.attr.use_rules,
                "except": ctx.attr.except_rules,
                "enum_zero_value_suffix": ctx.attr.enum_zero_value_suffix,
                "allow_comment_ignores": ctx.attr.allow_comment_ignores,
                "rpc_allow_same_request_response": ctx.attr.rpc_allow_same_request_response,
                "rpc_allow_google_protobuf_empty_requests": ctx.attr.rpc_allow_google_protobuf_empty_requests,
                "rpc_allow_google_protobuf_empty_responses": ctx.attr.rpc_allow_google_protobuf_empty_responses,
                "service_suffix": ctx.attr.service_suffix,
            },
        },
    })

    deps = proto_info.transitive_descriptor_sets.to_list()
    deps.append(proto_info.direct_descriptor_set)

    script = "{protoc} '--buf-lint_opt={config}' --plugin=protoc-gen-buf-lint={protoc_gen_buf_lint}  --descriptor_set_in {deps} --buf-lint_out=. {targets}".format(
        protoc = ctx.executable._protoc.short_path,
        protoc_gen_buf_lint = ctx.toolchains[_TOOLCHAIN].cli.short_path,
        config = config,
        deps = ":".join([f.short_path for f in deps]),
        targets = " ".join([f.path for f in proto_info.direct_sources]),
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    files = [ctx.executable._protoc, ctx.toolchains[_TOOLCHAIN].cli] + deps + proto_info.direct_sources
    runfiles = ctx.runfiles(
        files = files,
    )

    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]

buf_lint_test = rule(
    implementation = _buf_lint_test_impl,
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
        # buf config attrs
        "use_rules": attr.string_list(
            default = ["DEFAULT"],
            doc = "https://docs.buf.build/lint/configuration#use",
        ),
        "except_rules": attr.string_list(
            default = [],
            doc = "https://docs.buf.build/lint/configuration#except",
        ),
        "allow_comment_ignores": attr.bool(
            default = True,
            doc = "https://docs.buf.build/lint/configuration#allow_comment_ignores",
        ),
        "enum_zero_value_suffix": attr.string(
            default = "_UNSPECIFIED",
            doc = "https://docs.buf.build/lint/configuration#enum_zero_value_suffix",
        ),
        "rpc_allow_same_request_response": attr.bool(
            doc = "https://docs.buf.build/lint/configuration#rpc_allow_",
        ),
        "rpc_allow_google_protobuf_empty_requests": attr.bool(
            doc = "https://docs.buf.build/lint/configuration#rpc_allow_",
        ),
        "rpc_allow_google_protobuf_empty_responses": attr.bool(
            doc = "https://docs.buf.build/lint/configuration#rpc_allow_",
        ),
        "service_suffix": attr.string(
            default = "Service",
            doc = "https://docs.buf.build/lint/configuration#service_suffix",
        ),
    },
    toolchains = [_TOOLCHAIN],
    test = True,
)
