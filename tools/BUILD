load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "platfroms",
    srcs = [
        "platforms.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
    ],
)

bzl_library(
    name = "toolchain",
    srcs = [
        "toolchain.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":platfoms"
    ],
)