"""Buf toolchains macros to declare and register toolchains"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_BUF_RELEASE_PLATFORMS = [
    {
        "os": "osx",
        "cpu": "arm64",
    },
    {
        "os": "osx",
        "cpu": "x86_64",
    },
    {
        "os": "linux",
        "cpu": "aarch64",
    },
    {
        "os": "linux",
        "cpu": "x86_64",
    },
    {
        "os": "windows",
        "cpu": "arm64",
    },
    {
        "os": "windows",
        "cpu": "x86_64",
    },
]

_BUF_RELEASES_REPO = "buf_releases"

def _register_toolchains(name):
    labels = [
        "@rules_buf//tools/{name}:{name}-{os}-{cpu}_toolchain".format(
            name = name,
            os = p["os"],
            cpu = p["cpu"],
        )
        for p in _BUF_RELEASE_PLATFORMS
    ]
    native.register_toolchains(
        *labels
    )

def _buf_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        cli = ctx.executable.cli,
    )
    return [toolchain_info]

_buf_toolchain = rule(
    implementation = _buf_toolchain_impl,
    attrs = {
        "cli": attr.label(
            doc = "The buf cli",
            executable = True,
            cfg = "exec",
            mandatory = True,
        ),
    },
)

_BUF_RELEASE_BUILD_FILE = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "{name}",
    srcs = ["{bin}"],
)
"""

def _buf_download_releases_impl(ctx):
    version = ctx.attr.version
    if not version:
        ctx.report_progress("Finding latest buf version")

        # Get the latest version from github. Refer: https://docs.github.com/en/rest/reference/releases
        #
        # TODO: Change this to use https://api.github.com/repos/bufbuild/buf/releases/latest once we hit v1.
        ctx.download(
            url = "https://api.github.com/repos/bufbuild/buf/releases?per_page=1",
            output = "versions.json",
        )
        versions_data = ctx.read("versions.json")
        versions = json.decode(versions_data)
        version = versions[0]["name"]

    ctx.report_progress("Downloading buf release hash")
    ctx.download(
        url = [
            "https://github.com/bufbuild/buf/releases/download/{}/sha256.txt".format(version),
        ],
        output = "sha256.txt",
    )
    sha_list = ctx.read("sha256.txt").splitlines()
    for sha_line in sha_list:
        if sha_line.strip(" ").endswith(".tar.gz"):
            continue
        (sum, _, bin) = sha_line.partition(" ")
        bin = bin.strip(" ")

        # Bazel defines macOS as osx
        # Windows binaries are suffixed with .exe. This only effects the targets name and the binary will continue to have the suffix.
        target = bin.lower().replace("darwin", "osx").rstrip(".exe")
        ctx.download(
            url = "https://github.com/bufbuild/buf/releases/download/{}/{}".format(version, bin),
            sha256 = sum,
            executable = True,
            output = "{}/{}".format(target, bin),
        )
        ctx.file("{}/BUILD".format(target), _BUF_RELEASE_BUILD_FILE.format(name = target, bin = bin))
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))
    return update_attrs(ctx.attr, ["version"], {"version": version})

_buf_download_releases = repository_rule(
    implementation = _buf_download_releases_impl,
    attrs = {
        "version": attr.string(
            doc = "Buf release version",
        ),
    },
)

def declare_buf_toolchains(name, cmd):
    """declare_buf_toolchains macro declares toolchains based on public releases of [buf](github.com/bufbuild/buf/releases)

    Args:
        name: Macro name, can be anything,
        cmd: Must be one of  [buf, protoc-gen-bug-lint, protoc-gen-buf-breaking]
    """
    native.toolchain_type(name = "toolchain_type")
    for p in _BUF_RELEASE_PLATFORMS:
        os = p["os"]
        cpu = p["cpu"]
        exec_name = "{}-{}-{}".format(cmd, os, cpu)
        _buf_toolchain(
            name = exec_name,
            cli = "@{}//{}".format(_BUF_RELEASES_REPO, exec_name),
        )

        native.toolchain(
            name = "{}_toolchain".format(exec_name),
            toolchain = ":{}".format(exec_name),
            toolchain_type = ":toolchain_type",
            exec_compatible_with = [
                "@platforms//os:{}".format(os),
                "@platforms//cpu:{}".format(cpu),
            ],
        )

# buildifier: disable=unnamed-macro
def rules_buf_toolchains(version = None):
    """rules_buf_toolchains downloads buf, protoc-gen-buf-lint, and protoc-gen-buf-breaking from github releases of buf: https://github.com/bufbuild/buf/releases

    Args:
        version: Release version, eg: `v.1.0.0-rc12`. If `None` defaults to latest
    """

    _buf_download_releases(name = _BUF_RELEASES_REPO, version = version)

    _register_toolchains("buf")
    _register_toolchains("protoc-gen-buf-breaking")
    _register_toolchains("protoc-gen-buf-lint")
