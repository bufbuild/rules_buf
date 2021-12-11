load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//visibility:public"])

bzl_library(
    name = "defs",
    srcs = [
        "defs.bzl",
    ],
    deps = [
        "//buf/internal:break.bzl",
        "//buf/internal:image.bzl",
        "//buf/internal:lint.bzl",
    ],
)

bzl_library(
    name = "repositories",
    srcs = [
        "repositories.bzl",
    ],
    deps = [
        "//buf/internal:dependencies.bzl",
        "//tools:toolchain.bzl",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
    ],
)
