"""Defines buf_image repo rule"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_DOC = """
`buf_repository` downloads a [buf module](https://docs.buf.build/bsr/overview#module) and generates `BUILD` files. It currently generates a single `proto_library` target with all the proto files inside a module. The target is named as `default_proto_library`.

**Example**
```starlark
# `proto_library` target can referenced using "@build_buf_acme_petapis//:default_proto_library"
buf_repository(
    name = "build_buf_acme_petapis",
    module = "buf.build/acme/petapis",
    commit = "84a33a06f0954823a6f2a089fb1bb82e",    
)
```
"""

_BUF_IMAGE_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

_PROTO_LIBRARY_BUILD = """
load("@rules_proto//proto:defs.bzl", "proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "{name}",
    srcs = glob(["{prefix}/**/*.proto"]),
    strip_import_prefix = "{prefix}",
    deps = [
        # Well known types
        # TODO(skrishna): Should we parse files and understand which ones are needed?
        "@com_google_protobuf//:wrappers_proto",
        "@com_google_protobuf//:type_proto",
        "@com_google_protobuf//:timestamp_proto",
        "@com_google_protobuf//:struct_proto",
        "@com_google_protobuf//:source_context_proto",
        "@com_google_protobuf//:field_mask_proto",
        "@com_google_protobuf//:empty_proto",
        "@com_google_protobuf//:duration_proto",
        "@com_google_protobuf//:descriptor_proto",
        "@com_google_protobuf//:compiler_plugin_proto",
        "@com_google_protobuf//:api_proto",
        "@com_google_protobuf//:any_proto",
        {deps}
    ],
)
"""

def _get_deps(lock_file):
    """buf.lock deps parser"""
    lines = lock_file.splitlines()
    deps = []
    last_dep = None
    deps_found = False
    for line in lines:
        # Skip until deps key is found
        if not deps_found:
            deps_found = line.startswith("deps:")
            continue

        # Skip comments
        if line.startswith("#"):
            continue

        line = line.strip(" ")

        if line.startswith("-"):
            if last_dep:
                deps = deps + [last_dep]
            last_dep = {}
            line = line.strip("- ")

        kv = line.split(": ")
        last_dep[kv[0]] = kv[1]

    if last_dep:
        deps = deps + [last_dep]
    return deps

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

    res = ctx.execute(
        [buf, "build", "{}:{}".format(ctx.attr.module, ctx.attr.commit)],
        quiet = False,
        environment = {
            "BUF_CACHE_DIR": "cache",
        },
    )
    if res.return_code != 0:
        fail("failed with code: {}, error: {}".format(res.return_code, res.stderr))

    digest = ctx.read("cache/v1/module/sum/{}/{}".format(ctx.attr.module, ctx.attr.commit))
    lock_file = ctx.read("cache/v1/module/data/{}/{}/buf.lock".format(ctx.attr.module, ctx.attr.commit))
    deps = _get_deps(lock_file)

    repo_names = [
        '"@{remote}_{owner}_{repo}//:default_proto_library"'.format(
            remote = "_".join(
                reversed(dep["remote"].split(".")),
            ),
            owner = dep["owner"],
            repo = dep["repository"],
        )
        for dep in deps
    ]

    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name), executable = False)
    ctx.file(
        "BUILD",
        _PROTO_LIBRARY_BUILD.format(
            name = "default_proto_library",
            prefix = "cache/v1/module/data/{}/{}".format(ctx.attr.module, ctx.attr.commit),
            deps = ", ".join(repo_names),
        ),
    )

    # Suggest adding `digest` to ensure reproducibility if not present
    return update_attrs(ctx.attr, ["module", "commit", "digest"], {"digest": digest})

buf_repository = repository_rule(
    implementation = _buf_image_imp,
    doc = _DOC,
    attrs = {
        "module": attr.string(
            mandatory = True,
            doc = "The name of the module on bsr. Example: `buf.build/acme/petapis`",
        ),
        "commit": attr.string(
            mandatory = True,
            doc = """commit/revision of the module on BSR to download""",
        ),
        "digest": attr.string(
            doc = """The digest of module contents. `buf_repository` will verify the downloaded module matches this digest. A value for digest will be suggested if one is not provided.

A value for digest can also be found in the `buf.lock` file. If you can't find the `buf.lock` file please run `buf mod update`.
            """,
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
