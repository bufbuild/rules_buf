load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

package(default_visibility = ["//:__subpackages__"])

bzl_library(
    name = "break",
    srcs = ["break.bzl"],
    deps = [
        ":plugin",
        "@rules_proto//proto:defs",
    ],
)

bzl_library(
    name = "lint",
    srcs = ["lint.bzl"],
    deps = [
        ":plugin",
        "@rules_proto//proto:defs",
    ],
)

bzl_library(
    name = "plugin",
    srcs = ["plugin.bzl"],
)

bzl_library(
    name = "dependencies",
    srcs = ["dependencies.bzl"],
)
