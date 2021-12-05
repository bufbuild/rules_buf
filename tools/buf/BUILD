load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//tools:toolchain.bzl", "declare_toolchains")
load(":toolchain.bzl", "buf_toolchain")

bzl_library(
    name = "toolchain",
    srcs = [
        "toolchain.bzl",
    ],
    visibility = ["//visibility:public"],
    deps = [
    ],
)

toolchain_type(name = "toolchain_type")
declare_toolchains(name = "buf_toolchain_declaration", toolchain = buf_toolchain)

