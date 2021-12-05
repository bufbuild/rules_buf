load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//tools:toolchain.bzl", "declare_toolchains")
load(":toolchain.bzl", "protoc_gen_buf_lint_toolchain")

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

declare_toolchains(
    name = "protoc_gen_buf_lint_toolchain_declaration",
    cmd = "protoc-gen-buf-lint",
    toolchain = protoc_gen_buf_lint_toolchain,
)
