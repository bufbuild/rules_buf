# Copyright 2021-2022 Buf Technologies, Inc.
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

_TOOLS = ["buf", "protoc-gen-buf-breaking", "protoc-gen-buf-lint"]

_TOOLCHAINS_REPO = "rules_buf_toolchains"

BufToolchainInfo = provider(fields = {
    "buf_tool": "A File for a buf executable",
    "protoc_breaking_tool": "A File for protoc-gen-buf-breaking executable",
    "protoc_lint_tool": "A File for protoc-gen-buf-lint executable",
})

def _buf_toolchain_impl(ctx):
    return platform_common.ToolchainInfo(
        buf = BufToolchainInfo(
            buf_tool = ctx.executable.buf,
            protoc_breaking_tool = ctx.executable.protoc_breaking,
            protoc_lint_tool = ctx.executable.protoc_lint,
        ),
    )

buf_toolchain = rule(
    implementation = _buf_toolchain_impl,
    attrs = {
        "buf": attr.label(
            doc = "The buf cli",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "protoc_breaking": attr.label(
            doc = "The buf cli",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "protoc_lint": attr.label(
            doc = "The buf cli",
            executable = True,
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
    ],
)

def _buf_dist_toolchain_repo_impl(ctx):
    manifest = json.decode(ctx.read(Label("@rules_buf_tool_manifest//:manifest.json")))
    bin_suffix = ""
    if ctx.attr.os == "windows":
        bin_suffix = ".exe"

    for tool in _TOOLS:
        info = manifest[ctx.attr.os][ctx.attr.arch][tool]
        out_name = "bin/" + tool
        ctx.download(info["url"], output = out_name + bin_suffix, sha256 = info["sha256"])

    ctx.template("BUILD.bazel", Label("@rules_buf//buf/internal:BUILD.dist.bazel"), substitutions = {"%BIN_SUFFIX%": bin_suffix}, executable = False)

_buf_dist_toolchain_repo = repository_rule(
    implementation = _buf_dist_toolchain_repo_impl,
    attrs = {
        "os": attr.string(
            mandatory = True,
            values = ["macos", "linux", "windows"],
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["arm64", "x86_64"],
        ),
    },
)

def _buf_download_manifest_repo_impl(ctx):
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

    ctx.report_progress("Downloading and preparing manifest")
    ctx.download(
        url = [
            "https://github.com/bufbuild/buf/releases/download/{}/sha256.txt".format(version),
        ],
        output = "sha256.txt",
    )

    manifest = {
        "macos": {
            "arm64": {},
            "x86_64": {},
        },
        "linux": {
            "arm64": {},
            "x86_64": {},
        },
        "windows": {
            "arm64": {},
            "x86_64": {},
        },
    }

    sha_list = ctx.read("sha256.txt").splitlines()

    for sha_line in sha_list:
        sha_line = sha_line.lower()
        if sha_line.strip(" ").endswith(".tar.gz"):
            continue

        sum, _, bin = sha_line.split(" ")

        tool = None

        for maybe_tool in _TOOLS:
            if bin.startswith(maybe_tool + "-"):
                tool = maybe_tool
                rest = bin[len(maybe_tool) + 1:]
                break

        if not tool:
            print("unknown tool found in manifest, skipping", bin)
            continue

        os, _, arch = rest.partition("-")
        arch = arch.removesuffix(".exe")

        if os == "darwin":
            os = "macos"

        if arch == "aarch64":
            arch = "arm64"

        manifest[os][arch][tool] = {
            "url": "https://github.com/bufbuild/buf/releases/download/{version}/{tool}".format(version = version, tool = bin),
            "sha256": sum,
        }

    ctx.file("BUILD.bazel", content = "", executable = False)
    ctx.file("manifest.json", content = json.encode_indent(manifest), executable = False)

    return update_attrs(ctx.attr, ["version"], {"version": version})

_buf_download_manifest_repo = repository_rule(
    implementation = _buf_download_manifest_repo_impl,
    attrs = {
        "version": attr.string(
            doc = "A buf github release version",
        ),
    },
    doc = "Prepares a manifest.json file from a buf release checksum manifest. If no version is provided it will use Github releases to fetch the latest one",
)

def _buf_toolchain_repo_impl(ctx):
    ctx.template(
        "BUILD.bazel",
        Label("@rules_buf//buf/internal:BUILD.toolchains.bazel"),
        substitutions = {
            "%NAME%": ctx.attr.name,
        },
        executable = False,
    )

_buf_toolchain_repo = repository_rule(
    implementation = _buf_toolchain_repo_impl,
    doc = "Provides toolchain() targets for all execution platforms buf supports.",
)

# buildifier: disable=unnamed-macro
def rules_buf_toolchains(name = _TOOLCHAINS_REPO, version = None):
    """rules_buf_toolchains sets up toolchains for buf, protoc-gen-buf-lint, and protoc-gen-buf-breaking

    Args:
        name: The name of the toolchains repository. Defaults to "buf_toolchains"
        version: Release version, eg: `v.1.0.0-rc12`. If `None` defaults to latest
    """
    _buf_download_manifest_repo(name = "rules_buf_tool_manifest", version = version)

    # declare platform specific distribution and buf_toolchain repos for all the supported platforms.
    # due to how toolchain resolution works the tool specific toolchain info is not loaded when registering a toolchain
    for os in ["macos", "linux", "windows"]:
        for arch in ["x86_64", "arm64"]:
            dist_name = "{name}_dist_{os}_{arch}".format(name = name, os = os, arch = arch)
            _buf_dist_toolchain_repo(
                name = dist_name,
                os = os,
                arch = arch,
            )

    _buf_toolchain_repo(name = name)
    native.register_toolchains("@{}//...".format(name))
