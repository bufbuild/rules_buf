load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "utils",
    srcs = [
        "utils.bzl",
    ],
    visibility = ["//visibility:private"],
    deps = [
    ],
)

bzl_library(
    name = "break",
    srcs = [
        "break.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":utils",
        ":image",
        "@rules_proto//proto:defs.bzl",
    ],
)

bzl_library(
    name = "lint",
    srcs = [
        "lint.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@rules_proto//proto:defs.bzl",
    ],
)

bzl_library(
    name = "image",
    srcs = [
        "image.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@rules_proto//proto:defs.bzl",
    ],
)

