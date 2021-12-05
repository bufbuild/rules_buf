load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load("@bazel_skylib//lib:shell.bzl", "shell")

_TOOLCHAIN = str(Label("//tools/protoc-gen-buf-breaking:toolchain_type"))

def _buf_breaking_test_impl(ctx):
    proto_info = ctx.attr.target[ProtoInfo]
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

    deps = proto_info.transitive_descriptor_sets.to_list()
    deps.append(proto_info.direct_descriptor_set)

    # {protoc} '--buf-breaking_opt={config}' --plugin=protoc-gen-buf-breaking={protoc_gen_buf_breaking}  --descriptor_set_in {deps} --buf-breaking_out=. {targets}'
    script = "{protoc} '--buf-breaking_opt={config}' --plugin=protoc-gen-buf-breaking={protoc_gen_buf_breaking}  --descriptor_set_in {deps} --buf-breaking_out=. {targets}".format(
        protoc = ctx.executable._protoc.short_path,
        protoc_gen_buf_breaking = ctx.toolchains[_TOOLCHAIN].cli.short_path,
        config = config,
        deps = ":".join([f.short_path for f in deps]),
        targets = " ".join([f.short_path for f in proto_info.direct_sources]),
    )

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
        is_executable = True,
    )

    files = [ctx.executable._protoc, ctx.file.against, ctx.toolchains[_TOOLCHAIN].cli] + deps + proto_info.direct_sources
    runfiles = ctx.runfiles(
        files = files,
    )

    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]

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
    },
    toolchains = [_TOOLCHAIN],
    test = True,
)
