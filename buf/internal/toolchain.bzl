# Copyright 2021-2025 Buf Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Buf toolchains macros to declare and register toolchains"""

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "update_attrs")

_TOOLCHAINS_REPO = "rules_buf_toolchains"

_BUILD_FILE = """
package(default_visibility = ["//visibility:public"])

load(":toolchain.bzl", "implement_buf_toolchains")

implement_buf_toolchains("{cmd_suffix}")
"""

_IMPLEMENT_TOOLCHAIN_FILE = """
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

def implement_buf_toolchains(cmd_suffix):
    for cmd in ["buf", "protoc-gen-buf-lint", "protoc-gen-buf-breaking"]:
        toolchain_impl = cmd + "_toolchain_impl"
        _buf_toolchain(
            name = toolchain_impl,
            cli = str(Label("//:"+ cmd + cmd_suffix)),
        )

"""

_DECLARE_TOOLCHAINS_HEAD = """
def declare_buf_toolchains(rules_buf_repo_name):
    for cmd in ["buf", "protoc-gen-buf-lint", "protoc-gen-buf-breaking"]:
        toolchain_impl = cmd + "_toolchain_impl"
"""

_DECLARE_TOOLCHAINS_CALL = """
        native.toolchain(
            name = cmd + "_{os}_{arch}_toolchain",
            toolchain = "@@{name}_{os}_{arch}//:" + toolchain_impl,
            toolchain_type = "@@{{}}//tools/{{}}:toolchain_type".format(rules_buf_repo_name, cmd),
            exec_compatible_with = [
                "@platforms//os:{os}",
                "@platforms//cpu:{cpu}",
            ],
        )
"""

_DECLARE_TOOLCHAINS_BUILD_FILE = """
package(default_visibility = ["//visibility:public"])

load(":toolchain.bzl", "declare_buf_toolchains")

declare_buf_toolchains(
    rules_buf_repo_name = "{rules_buf_repo_name}",
)
"""

def _register_toolchains(repo):
    native.register_toolchains(
        "@{repo}//:all".format(
            repo = repo,
        ),
    )

def _buf_register_toolchains_impl(ctx):
    platforms = ctx.attr.platforms  # list of "{os}-{arch}" strings
    ctx.file(
        "BUILD",
        _DECLARE_TOOLCHAINS_BUILD_FILE.format(
            rules_buf_repo_name = Label("//buf/repositories.bzl").workspace_name,
        ),
    )
    toolchain_file_text = _DECLARE_TOOLCHAINS_HEAD
    for platform in platforms:
        os, arch = platform.split("-", 1)
        if os == "darwin":
            os = "osx"
        cpu = arch
        if cpu == "amd64":
            cpu = "x86_64"
        toolchain_file_text += _DECLARE_TOOLCHAINS_CALL.format(name = ctx.attr.name, os = os, arch = arch, cpu = cpu)
    ctx.file("toolchain.bzl", toolchain_file_text)

buf_register_toolchains = repository_rule(
    implementation = _buf_register_toolchains_impl,
    attrs = {
        "platforms": attr.string_list(
            doc = "Buf platforms",
            mandatory = True,
        ),
    },
)

def _buf_download_releases_impl(ctx):
    version = ctx.attr.version
    repository_url = ctx.attr.repository_url
    sha256 = ctx.attr.sha256
    if not version:
        ctx.report_progress("Finding latest buf version")

        # Get the latest version from github. Refer: https://docs.github.com/en/rest/reference/releases
        ctx.download(
            url = "https://api.github.com/repos/bufbuild/buf/releases/latest",
            output = "version.json",
        )
        version_data = ctx.read("version.json")
        version = json.decode(version_data)["name"]

    os = ctx.attr.os
    cpu = ctx.attr.arch
    if os == "linux" and cpu == "arm64":
        cpu = "aarch64"
    if cpu == "amd64":
        cpu = "x86_64"

    ctx.report_progress("Downloading buf release hash for {}-{}".format(os, cpu))
    url = "{}/{}/sha256.txt".format(repository_url, version)
    sha256 = ctx.download(
        url = url,
        sha256 = sha256,
        canonical_id = url,
        output = "sha256.txt",
    ).sha256
    ctx.file("WORKSPACE", "workspace(name = \"{name}\")".format(name = ctx.name))
    ctx.file("toolchain.bzl", _IMPLEMENT_TOOLCHAIN_FILE)
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
        url = "{}/{}/{}".format(repository_url, version, bin)
        download_info = ctx.download(
            url = url,
            sha256 = sum,
            executable = True,
            canonical_id = url,
            output = output,
        )

    ctx.file(
        "BUILD",
        _BUILD_FILE.format(cmd_suffix = ".exe" if os == "windows" else ""),
    )
    return update_attrs(ctx.attr, ["version", "sha256"], {"version": version, "sha256": sha256})

buf_download_releases = repository_rule(
    implementation = _buf_download_releases_impl,
    attrs = {
        "os": attr.string(
            doc = "Buf release os",
            mandatory = True,
            values = ["linux", "darwin", "windows"],
        ),
        "arch": attr.string(
            doc = "Buf release cpu arch",
            mandatory = True,
            values = ["arm64", "amd64"],
        ),
        "version": attr.string(
            doc = "Buf release version",
        ),
        "repository_url": attr.string(
            doc = "Repository url base used for downloads",
            default = "https://github.com/bufbuild/buf/releases/download",
        ),
        "sha256": attr.string(
            doc = "Buf release sha256.txt checksum",
        ),
    },
)

# buildifier: disable=unnamed-macro
def rules_buf_toolchains(name = _TOOLCHAINS_REPO, version = None, sha256 = None, repository_url = None):
    """rules_buf_toolchains sets up toolchains for buf, protoc-gen-buf-lint, and protoc-gen-buf-breaking

    Args:
        name: The name of the toolchains repository. Defaults to "buf_toolchains"
        version: Release version, eg: `v.1.0.0-rc12`. If `None` defaults to latest
        sha256: The checksum sha256.txt file.
        repository_url: The repository url base used for downloads. Defaults to "https://github.com/bufbuild/buf/releases/download"
    """

    platforms_for_registration = []
    for platform in (
        struct(os = "linux", arch = "arm64"),
        struct(os = "linux", arch = "amd64"),
        struct(os = "darwin", arch = "arm64"),
        struct(os = "darwin", arch = "amd64"),
        struct(os = "windows", arch = "arm64"),
        struct(os = "windows", arch = "amd64"),
    ):
        name_with_platform = "{}_{}_{}".format(name, platform.os, platform.arch)
        buf_download_releases(name = name_with_platform, os = platform.os, arch = platform.arch, version = version, sha256 = sha256, repository_url = repository_url)
        platforms_for_registration.append("{}-{}".format(platform.os, platform.arch))

    buf_register_toolchains(name = name, platforms = platforms_for_registration)
    _register_toolchains(name)
