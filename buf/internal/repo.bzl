"""Defines buf_dependencies repo rule"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_DOC = """
The `buf_dependencies` rule downloads and generates `proto_library` targets for buf modules hosted on the BSR.
"""

def _executable_extension(ctx):
    extension = ""
    if ctx.os.name.startswith("windows"):
        extension = ".exe"
    return extension

def _valid_pin(pin):
    module_commit = pin.split(":")
    if len(module_commit) != 2:
        return False

    module_parts = module_commit[0].split("/")
    if len(module_parts) != 3:
        return False

    return True

def _buf_dependencies_impl(ctx):
    buf = ctx.path(Label("@{}//:buf{}".format(ctx.attr.toolchain_repo, _executable_extension(ctx))))

    for pin in ctx.attr.modules:
        if not _valid_pin(pin):
            fail("failed to parse dep should be in the form of <remote>/<owner>/<repo>:<commit>")

        res = ctx.execute(
            [buf, "export", pin, "--exclude-imports", "--output", ctx.path("")],
            quiet = False,
        )
        if res.return_code != 0:
            fail("failed with code: {}, error: {}".format(res.return_code, res.stderr))

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name), executable = False)

    # Run gazelle to generate `proto_library` rules.
    # Note that this doesn't require the `buf` extension
    # as all the files are exported to workspace root.
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

    return update_attrs(ctx.attr, ["modules"], {})

buf_dependencies = repository_rule(
    implementation = _buf_dependencies_impl,
    doc = _DOC,
    attrs = {
        "modules": attr.string_list(
            allow_empty = False,
            mandatory = True,
            doc = "The module pins <remote>/<owner>/<repo>:<revision>, example: buf.build/acme/petapis:84a33a06f0954823a6f2a089fb1bb82e",
        ),
        "toolchain_repo": attr.string(
            default = "rules_buf_toolchains",
            doc = "The name of the rules_buf_toolchain repo. This is only needed the name of `rules_buf_toolchains` rule was modified.",
        ),
    },
)
