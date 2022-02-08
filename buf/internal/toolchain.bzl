"""Buf toolchains macros to declare and register toolchains"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_TOOLCHAINS_REPO = "rules_buf_toolchains"

_BUILD_FILE = """
load(":toolchain.bzl", "declare_buf_toolchains")

package(default_visibility = ["//visibility:public"])

declare_buf_toolchains(
    os = "{os}",
    cpu = "{cpu}",
    rules_buf_repo_name = "{rules_buf_repo_name}",
 )
"""

_TOOLCHAIN_FILE = """
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
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
)

def declare_buf_toolchains(os, cpu, rules_buf_repo_name):
    for cmd in ["buf", "protoc-gen-buf-lint", "protoc-gen-buf-breaking"]:
        ext = ""
        if os == "windows":
            ext = ".exe"
        toolchain_impl = cmd + "_toolchain_impl"         
        _buf_toolchain(
            name = toolchain_impl,
            cli = str(Label("//:"+ cmd)),
        )
        native.toolchain(
            name = cmd + "_toolchain",
            toolchain = ":" + toolchain_impl,
            toolchain_type = "@{}//tools/{}:toolchain_type".format(rules_buf_repo_name, cmd),
            exec_compatible_with = [
                "@platforms//os:" + os,
                "@platforms//cpu:" + cpu,
            ],
        )

"""

def _register_toolchains(repo, cmd):
    native.register_toolchains(
        "@{repo}//:{cmd}_toolchain".format(
            repo = repo,
            cmd = cmd,
        ),
    )

# Copied from rules_go: https://github.com/bazelbuild/rules_go/blob/bd44f4242b46e73fb2a81fc87ea4b52173bde84e/go/private/sdk.bzl#L240
#
# NOTE: This doesn't check for windows/arm64
# We can upgrade to repository_ctx.os.name and repository_ctx.os.arch once bazel 5.1 releases bazelbuild/bazel#14685
def _detect_host_platform(ctx):
    if ctx.os.name == "linux":
        goos, goarch = "linux", "amd64"
        res = ctx.execute(["uname", "-p"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "s390x":
                goarch = "s390x"
            elif uname == "i686":
                goarch = "386"

        # uname -p is not working on Aarch64 boards
        # or for ppc64le on some distros
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "aarch64":
                goarch = "arm64"
            elif uname == "armv6l":
                goarch = "arm"
            elif uname == "armv7l":
                goarch = "arm"
            elif uname == "ppc64le":
                goarch = "ppc64le"

        # Default to amd64 when uname doesn't return a known value.

    elif ctx.os.name == "mac os x":
        goos, goarch = "darwin", "amd64"

        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "arm64":
                goarch = "arm64"

        # Default to amd64 when uname doesn't return a known value.

    elif ctx.os.name.startswith("windows"):
        goos, goarch = "windows", "amd64"
    elif ctx.os.name == "freebsd":
        goos, goarch = "freebsd", "amd64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)

    return goos, goarch

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

    os, cpu = _detect_host_platform(ctx)
    if os not in ["linux", "darwin", "windows"] or cpu not in ["arm64", "amd64"]:
        fail("Unsupported operating system or cpu architecture ")
    if os == "linux" and cpu == "arm64":
        cpu = "aarch64"
    if cpu == "amd64":
        cpu = "x86_64"

    ctx.report_progress("Downloading buf release hash")
    ctx.download(
        url = [
            "https://github.com/bufbuild/buf/releases/download/{}/sha256.txt".format(version),
        ],
        output = "sha256.txt",
    )
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))
    ctx.file("toolchain.bzl", _TOOLCHAIN_FILE)
    sha_list = ctx.read("sha256.txt").splitlines()
    for sha_line in sha_list:
        if sha_line.strip(" ").endswith(".tar.gz"):
            continue
        (sum, _, bin) = sha_line.partition(" ")
        bin = bin.strip(" ")
        lower_case_bin = bin.lower()
        if lower_case_bin.find(os) == -1 or lower_case_bin.find(cpu) == -1:
            continue

        output = lower_case_bin[:lower_case_bin.find(os) - 1]
        if os == "windows":
            output += ".exe"

        ctx.report_progress("Downloading " + bin)
        download_info = ctx.download(
            url = "https://github.com/bufbuild/buf/releases/download/{}/{}".format(version, bin),
            sha256 = sum,
            executable = True,
            output = output,
        )

    if os == "darwin":
        os = "osx"

    ctx.file(
        "BUILD",
        _BUILD_FILE.format(
            os = os,
            cpu = cpu,
            rules_buf_repo_name = Label("//buf/repositories.bzl").workspace_name,
        ),
    )
    return update_attrs(ctx.attr, ["version"], {"version": version})

_buf_download_releases = repository_rule(
    implementation = _buf_download_releases_impl,
    attrs = {
        "version": attr.string(
            doc = "Buf release version",
        ),
    },
)

# buildifier: disable=unnamed-macro
def rules_buf_toolchains(name = _TOOLCHAINS_REPO, version = None):
    """rules_buf_toolchains sets up toolchains for buf, protoc-gen-buf-lint, and protoc-gen-buf-breaking

    Args:
        name: The name of the toolchains repository. Defaults to "buf_toolchains"
        version: Release version, eg: `v.1.0.0-rc12`. If `None` defaults to latest
    """

    _buf_download_releases(name = name, version = version)

    _register_toolchains(name, "buf")
    _register_toolchains(name, "protoc-gen-buf-breaking")
    _register_toolchains(name, "protoc-gen-buf-lint")
