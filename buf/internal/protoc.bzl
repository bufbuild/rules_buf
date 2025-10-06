"""Rules for exposing an alternate protoc.
"""

PLATFORMS = {
    "linux-aarch_64": [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
    "linux-ppcle_64": [
        "@platforms//os:linux",
        "@platforms//cpu:ppc64le",
    ],
    "linux-s390_64": [
        "@platforms//os:linux",
        "@platforms//cpu:s390x",
    ],
    "linux-x86_64": [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    "osx-aarch_64": [
        "@platforms//os:macos",
        "@platforms//cpu:aarch64",
    ],
    "osx-x86_64": [
        "@platforms//os:macos",
        "@platforms//cpu:x86_64",
    ],
    "win64": [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
}

PROTOC_RELEASES = {
    "1.0.0": {
        "linux-aarch_64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-linux-aarch_64.zip",
            "integrity": "sha384-Wkn5+euQoumm876K4dHkptJbr8ExSEKHoLgHTd3wnWRzWaKit17JEvaINByi6CEY",
        },
        "linux-ppcle_64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-linux-ppcle_64.zip",
            "integrity": "sha384-i6tRteYfc5ylEOQ3fhI3cu8Rw8cvWHHV1o8Pj9Kva0rSD4zUcStxKGA4sw00QAKc",
        },
        "linux-s390_64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-linux-s390_64.zip",
            "integrity": "sha384-QTsokdVS9SnnoIFsZY4PScyoS+ipEgf1mdkB8hXS8Qxw9Sz8BbWLPPa85mF3hJQc",
        },
        "linux-x86_32": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-linux-x86_32.zip",
            "integrity": "sha384-eSDeRDJD+VYbzyshn2ZVfLTMjwXqml8jMFvZ8yzUep8eHcuun8dbDWECRs3sNyCw",
        },
        "linux-x86_64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-linux-x86_64.zip",
            "integrity": "sha384-/fM7uKNpL3hhwCnUfrAzrFc7hxztyiiXLmWQq802dGEUSDYGKYmTq/jW87Sgo9Hh",
        },
        "osx-aarch_64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-osx-aarch_64.zip",
            "integrity": "sha384-QAt17YeU2mQEtnm0EqUbr4OdFnW0tZsvW0F3ff7j/kNY68oTgJVgh5jmCaaEBPQK",
        },
        "osx-x86_64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-osx-x86_64.zip",
            "integrity": "sha384-zyRftub+LGiZJ4KuSiW6uewRjPSgbkPd+D1tH/Zi1SpISG8XCacnv0GsBJfMc5xY",
        },
        "win32": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-win32.zip",
            "integrity": "sha384-h74gB5rehr7ODGtYAIjfaCr+Wl4nSN6iqWQ1ddyCX8rSF9GDo8jBeLfa3/V4OL2i",
        },
        "win64": {
            "url": "https://github.com/protocolbuffers/protobuf/releases/download/v32.1/protoc-32.1-win64.zip",
            "integrity": "sha384-jF2LaYcTdW99SPLBBcGorn21YQ9TZzONVWBco0gdVqckrQrG7HVhZIpQoELCZMzd",
        },
    },
}

def _download_protoc_impl(rctx):
    release = PROTOC_RELEASES[rctx.attr.version][rctx.attr.platform]
    rctx.download_and_extract(
        url = release["url"],
        integrity = release["integrity"],
    )
    build_content = """\
package(default_visibility = ["//visibility:public"])

load("@rules_proto//proto:proto_toolchain.bzl", "proto_toolchain")

proto_toolchain(
    name = "protoc",
    proto_compiler = "{protoc_label}",
)
""".format(
        protoc_label = ":bin/protoc.exe" if rctx.attr.platform.startswith("win") else ":bin/protoc",
    )

    rctx.file("BUILD.bazel", build_content)

download_protoc = repository_rule(
    doc = "Exposes a protoc_toolchain from a static protoc for a platform.",
    implementation = _download_protoc_impl,
    attrs = {
        "platform": attr.string(
            mandatory = True,
            values = PLATFORMS.keys(),
        ),
        "version": attr.string(
            mandatory = True,
        ),
    },
)

def _toolchains_repo_impl(repository_ctx):
    build_content = ""

    for [platform, compatible_with] in PLATFORMS.items():
        build_content += """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},    
    toolchain = "@rules_buf_protoc_{platform}//:protoc",
    toolchain_type = "@rules_proto//proto:toolchain_type",
)
""".format(
            platform = platform.replace("-", "_"),
            compatible_with = compatible_with,
        )
    repository_ctx.file("BUILD.bazel", build_content)

protoc_toolchains_repo = repository_rule(
    _toolchains_repo_impl,
    doc = """\
    Create a repository that registers protoc
    """,
)

def protoc_toolchains(version, register = True):
    """A utility method to load all Protobuf toolchains.

    Args:
        version: a release tag from protocolbuffers/protobuf, e.g. 'v25.3'
        register: whether to register the resulting toolchains.
            Should be True for WORKSPACE and False under bzlmod.
    """

    for platform in PLATFORMS.keys():
        download_protoc(
            name = "rules_buf_protoc_" + platform.replace("-", "_"),
            platform = platform,
            version = version,
        )
    name = "rules_buf_protoc"
    protoc_toolchains_repo(name = name)
    if register:
        native.register_toolchains("@{}//:all".format(name))
