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

"""Define module extensions for using rules_buf with bzlmod.
See https://bazel.build/docs/bzlmod#extension-definition
"""

load("//buf/internal:repo.bzl", "buf_dependencies")
load("//buf/internal:toolchain.bzl", "buf_download_releases", "buf_register_toolchains")

_DEFAULT_VERSION = "v1.47.2"
_DEFAULT_SHA256 = "1b37b75dc0a777a0cba17fa2604bc9906e55bb4c578823d8b7a8fe3fc9fe4439"
_DEFAULT_TOOLCHAIN_NAME = "rules_buf_toolchains"
_DEFAULT_DEPS = "buf_deps"

dependency = tag_class(attrs = {
    "name": attr.string(doc = "name of resulting deps repo", default = _DEFAULT_DEPS),
    "module": attr.string(doc = "A module name from the Buf Schema Registry, see https://buf.build/docs/bsr/module/manage"),
})

toolchains = tag_class(attrs = {
    "name": attr.string(doc = "name of resulting buf toolchains repo", default = _DEFAULT_TOOLCHAIN_NAME),
    "version": attr.string(doc = "Version of the buf tool, see https://github.com/bufbuild/buf/releases"),
    "sha256": attr.string(doc = "The checksum sha256.txt file"),
})

def _extension_impl(module_ctx):
    registrations = {}
    dependencies = {}

    # Iterate over the global modules registered either directly by the user
    # or transitively by some other bazel module they use.
    for mod in module_ctx.modules:
        # collect all buf.dependency tags, group by name of resulting buf_dependencies repo
        for dependency in mod.tags.dependency:
            if dependency.name not in dependencies.keys():
                dependencies[dependency.name] = []
            dependencies[dependency.name].append(dependency.module)

        # collect all toolchain versions, group by name of toolchain repo
        for toolchains in mod.tags.toolchains:
            if toolchains.name != _DEFAULT_TOOLCHAIN_NAME and not mod.is_root:
                fail("""\
                Only the root module may override the default name for the buf toolchains.
                This prevents conflicting registrations in the global namespace of external repos.
                """)
            if toolchains.name not in registrations.keys():
                registrations[toolchains.name] = []
            registrations[toolchains.name].append({"version": toolchains.version, "sha256": toolchains.sha256})

    # Don't require that the user manually registers a toolchain
    if len(registrations) == 0:
        registrations = {_DEFAULT_TOOLCHAIN_NAME: [{"version": _DEFAULT_VERSION, "sha256": _DEFAULT_SHA256}]}

    for name, versions in registrations.items():
        if len(versions) > 1:
            # TODO: should be semver-aware, using MVS
            selected = sorted(versions, key = lambda v: v["version"], reverse = True)[0]

            # buildifier: disable=print
            print("NOTE: buf toolchains {} has multiple versions {}, selected {}".format(name, versions, selected))
        else:
            selected = versions[0]
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
            buf_download_releases(
                name = name_with_platform,
                os = platform.os,
                arch = platform.arch,
                version = selected["version"],
                sha256 = selected["sha256"],
            )
            platforms_for_registration.append("{}-{}".format(platform.os, platform.arch))

        buf_register_toolchains(name = name, platforms = platforms_for_registration)

    for name, modules in dependencies.items():
        buf_dependencies(
            name = name,
            modules = modules,
        )

buf = module_extension(
    implementation = _extension_impl,
    tag_classes = {
        "dependency": dependency,
        "toolchains": toolchains,
    },
)
