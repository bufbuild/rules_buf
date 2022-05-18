"""Defines `buf_repository` rule """

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_DOC = """
The `buf_dependencies` rule downloads and generates `proto_library` targets for buf modules specified in `deps` attribute.
"""

def _executable_extension(ctx):
    extension = ""
    if ctx.os.name.startswith("windows"):
        extension = ".exe"
    return extension

def _buf_dependencies_impl(ctx):
    buf = ctx.path(Label("@rules_buf_toolchains//:buf{}".format(_executable_extension(ctx))))
    for pin in ctx.attr.deps:
        res = ctx.execute(
            [buf, "export", pin, "--exclude-imports", "--output", ctx.path("")],
            quiet = False,
        )
        if res.return_code != 0:
            fail("failed with code: {}, error: {}".format(res.return_code, res.stderr))

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name), executable = False)

    # Run gazelle to generate `proto_library` rules
    #
    # Copied from `go_repository` rule
    _gazelle = "@bazel_gazelle_go_repository_tools//:bin/gazelle{}".format(_executable_extension(ctx))
    gazelle = ctx.path(Label(_gazelle))

    cmd = [
        gazelle,
        "-lang",
        "proto",
        "-mode",
        "fix",
        "-repo_root",
        ctx.path(""),
    ]

    res = ctx.execute(cmd, quiet = False)
    if res.return_code != 0:
        fail("failed with code: {}, error: {}".format(res.return_code, res.stderr))

    return update_attrs(ctx.attr, ["deps"], {})

buf_dependencies = repository_rule(
    implementation = _buf_dependencies_impl,
    doc = _DOC,
    attrs = {
        "deps": attr.string_list(
            allow_empty = False,
            mandatory = True,
            doc = "The module pins <remote>/<owner>/<repo>:<revision>",
        ),
    },
)
