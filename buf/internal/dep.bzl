""" `buf_dependency` repository rule """

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_DOC = """

"""

def _executable_extension(ctx):
    extension = ""
    if ctx.os.name.startswith("windows"):
        extension = ".exe"
    return extension

def _buf_dependecies_impl(ctx):
    buf = ctx.attr.buf
    os = ctx.os.name.lower()

    # Toolchains do not work in workspaces. Need to select a buf binary based on os/arch.
    # TODO(skrishna): investigate how `go_repository` fetches go repos.
    if os.startswith("linux"):
        arch = ctx.execute(["uname", "-m"]).stdout.lower()
        if arch.startswith("x86_64"):
            buf = ctx.attr._buf_linux_x86_64
        elif arch.startswith("aarch64"):
            buf = ctx.attr._buf_linux_aarch64
    elif os.startswith("mac"):
        arch = ctx.execute(["uname", "-m"]).stdout.lower()
        if arch.startswith("arm64"):
            buf = ctx.attr._buf_osx_arm64
        elif arch.startswith("x86_64"):
            buf = ctx.attr._buf_osx_x86_64
    elif os.startswith("windows"):
        arch = ctx.execute(["echo", "%PROCESSOR_ARCHITECTURE%"]).stdout.lower()
        if arch.startswith("AMD64"):
            buf = ctx.attr._buf_windows_x86_64
        elif arch.startswith("ARM64"):
            buf = ctx.attr._buf_windows_arm64
    else:
        fail("unsupported operating system: {}, please provide buf binary using the 'buf' attribute".format(os))

    for pin in ctx.attr.deps:
        res = ctx.execute(
            [buf, "export", pin, "--exclude-imports", "--output", ctx.path("")],
            quiet = False,
        )
        if res.return_code != 0:
            fail("failed with code: {}, error: {}".format(res.return_code, res.stderr))

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name), executable = False)
    ctx.file("BUILD", """# gazelle:map_kind proto_library proto_library {}""".format(str(Label("//gazelle/buf:defs.bzl"))), executable = False)

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
    implementation = _buf_dependecies_impl,
    doc = _DOC,
    attrs = {
        "deps": attr.string_list(
            allow_empty = False,
            mandatory = True,
            doc = "The module pins <remote>/<owner>/<repo>:<revision>",
        ),
        "buf": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
            doc = "The buf cli to use to fetch the buf modules. Use this to override the default version provided by this repo",
        ),
        "_buf_osx_arm64": attr.label(
            default = "@buf-osx-arm64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_osx_x86_64": attr.label(
            default = "@buf-osx-x86_64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_linux_x86_64": attr.label(
            default = "@buf-linux-x86_64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_linux_aarch64": attr.label(
            default = "@buf-linux-aarch64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_windows_arm64": attr.label(
            default = "@buf-windows-arm64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_windows_x86_64": attr.label(
            default = "@buf-windows-x86_64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
    },
)
