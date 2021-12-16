"""Defines buf_image repo rule"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_BUF_IMAGE_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

def _buf_image_imp(ctx):
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

    # Declare the file before writing to it. Bazel sandboxing disallows writing commands from creating arbitary files.
    ctx.file("image/image.bin", executable = False, legacy_utf8 = False)

    # Use buf build command to generate the image file for the repo
    res = ctx.execute([buf, "build", "{}:{}".format(ctx.attr.module, ctx.attr.commit), "-o", "image/image.bin"], quiet = False)
    if res.return_code != 0:
        fail("failed with code: {}, error: {}".format(res.return_code, res.stderr))

    # select a sha256 command based on os
    sha = ""
    if os.startswith("mac"):
        sha = ctx.execute(["shasum", "-a", "256", "image/image.bin"]).stdout.split(" ")[0]
    elif os.startswith("linux"):
        sha = ctx.execute(["sha256sum", "image/image.bin"]).stdout.split(" ")[0]
    else:
        sha = ctx.execute(["certUtil", "-hashfile", "image/image.bin", "SHA256"]).stdout.splitlines()[1]

    # Compare with previous sha256 (if present) to ensure byte-to-byte reproducibility
    if ctx.attr.sha256 != "" and ctx.attr.sha256 != sha:
        # fail("sha mismatch exp: {}, act: {}".format(ctx.attr.sha256, sha))

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name), executable = False)
    ctx.file("image/BUILD", _BUF_IMAGE_BUILD.format("image.bin"), executable = False)

    # Suggest adding `sha256` to ensure reproducibility if not present
    return update_attrs(ctx.attr, ["module", "commit", "sha256"], {"sha256": sha})

buf_image = repository_rule(
    implementation = _buf_image_imp,
    doc = "`buf_image` creates a buf image file against a buf module. It can be accessed by //@foo/image:file. This one will be superseded see `buf_repository`",
    attrs = {
        "module": attr.string(mandatory = True),
        "commit": attr.string(mandatory = True),
        "sha256": attr.string(),
        "buf": attr.label(
            executable = True,
            cfg = "exec",
            allow_single_file = True,
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
