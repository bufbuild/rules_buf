"""Dependencies and toolchains required to use rules_buf."""

load("//buf/internal:dependencies.bzl", "bazel_dependencies", "buf_toolchains_dependecies")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("//tools:toolchain.bzl", "register_toolchains")

def rules_buf_dependencies():
    """An utility method to load all dependencies of `rules_buf`.
    """

    for name in buf_toolchains_dependecies:
        maybe(http_file, name, **buf_toolchains_dependecies[name])
    for name in bazel_dependencies:
        maybe(http_archive, name, **bazel_dependencies[name])

def rules_buf_toolchains():
    """An utility method to load all buf toolchains."""

    register_toolchains("buf")
    register_toolchains("protoc-gen-buf-breaking")
    register_toolchains("protoc-gen-buf-lint")
