load(":utils.bzl", "update_attrs")

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
    sha_command = ""
    if os.startswith("linux"):
        arch = ctx.execute(["uname", "-m"]).stdout.lower()
        if arch.startswith("x86_64"):
            buf = ctx.attr._buf_linux_x86_64
        elif arch.startswith("aarch64"):
            buf = ctx.attr._buf_linux_aarch64
        sha_command = ["cat", "image/image.bin", "|", "sha256sum"]
    elif os.startswith("mac"):
        arch = ctx.execute(["uname", "-m"]).stdout.lower()
        if arch.startswith("arm64"):
            buf = ctx.attr._buf_osx_arm64
        elif arch.startswith("x86_64"):
            buf = ctx.attr._buf_osx_x86_64
        sha_command = ["shasum", "-a", "256", "image/image.bin"]
    elif os.startswith("windows"):
        arch = ctx.execute(["echo", "%PROCESSOR_ARCHITECTURE%"]).stdout.lower()
        if arch.startswith("AMD64"):
            buf = ctx.attr._buf_windows_x86_64
        elif arch.startswith("ARM64"):
            buf = ctx.attr._buf_windows_arm64
        sha_command = ["certUtil", "-hashfile", "image/image.bin", "SHA256", "|", "findstr", "/v", '"hash"']
    else:
        fail("unsupported operating system: {}".format(os))

    ctx.file("image/image.bin", executable = False, legacy_utf8=False)
    res = ctx.execute([buf, "build", "{}:{}".format(ctx.attr.module, ctx.attr.commit), "-o", "image/image.bin"], quiet = False)
    if res.return_code != 0:
        fail("failed with code: {}, error: {}".format(res.return_code, res.stderr)) 

    sha = ""
    if os.startswith("mac"):
        sha = ctx.execute(["shasum", "-a", "256", "image/image.bin"]).stdout.split(" ")[0]
    elif os.startswith("linux"):
        sha = ctx.execute(["sha256sum", "image/image.bin"]).stdout.split(" ")[0]
    else:
        sha = ctx.execute(["certUtil", "-hashfile", "image/image.bin", "SHA256"]).stdout.splitlines()[1]

    if ctx.attr.sha256 != "" and ctx.attr.sha256 != sha:
        fail("sha mismatch exp: {}, act: {}".format(ctx.attr.sha256, sha))

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name), executable = False)
    ctx.file("image/BUILD", _BUF_IMAGE_BUILD.format("image.bin"), executable = False) 

    return update_attrs(ctx.attr, ["module", "commit", "sha256"], {"sha256": sha})

buf_image = repository_rule(
    implementation = _buf_image_imp,
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
            default = "@buf_osx_arm64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_osx_x86_64": attr.label(
            default = "@buf_osx_x86_64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_linux_x86_64": attr.label(
            default = "@buf_linux_x86_64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_linux_aarch64": attr.label(
            default = "@buf_linux_aarch64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_windows_arm64": attr.label(
            default = "@buf_windows_arm64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
        "_buf_windows_x86_64": attr.label(
            default = "@buf_windows_x86_64//file:downloaded",
            executable = True,
            cfg = "exec",
            allow_files = True,
        ),
    },
)
