load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//buf:__subpackages__"])

bzl_library(
    name = "break",
    srcs = [
        "break.bzl",
    ],
    deps = [
        "@rules_proto//proto:defs.bzl",
    ],
)

bzl_library(
    name = "lint",
    srcs = [
        "lint.bzl",
    ],
    deps = [
        "@rules_proto//proto:defs.bzl",
    ],
)

bzl_library(
    name = "image",
    srcs = [
        "image.bzl",
    ],
    deps = [
        "@bazel_tools//build_defs:utils.bzl",
    ],
)
