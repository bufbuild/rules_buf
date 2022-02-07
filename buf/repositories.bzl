"""Dependencies and toolchains required to use rules_buf."""

load("//buf/internal:dependencies.bzl", "bazel_dependencies")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//buf/internal:toolchain.bzl", _rules_buf_toolchains = "rules_buf_toolchains")

def rules_buf_dependencies():
    """Utility method to load all dependencies of `rules_buf`."""
    for name in bazel_dependencies:
        maybe(http_archive, name, **bazel_dependencies[name])

def rules_buf_toolchains(version = None):
    """Utility method to load all buf toolchains."""
    _rules_buf_toolchains(version)
