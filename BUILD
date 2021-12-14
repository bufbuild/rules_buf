load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@bazel_gazelle//:def.bzl", "DEFAULT_LANGUAGES", "gazelle", "gazelle_binary")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

gazelle_binary(
    name = "gazelle-skylib",
    languages = DEFAULT_LANGUAGES + [
        "@bazel_skylib//gazelle/bzl:bzl",
    ],
    visibility = ["//:__pkg__"],
)

# gazelle:prefix github.com/bufbuild/rules_buf
# gazelle:exclude example/**
gazelle(
    name = "gazelle",
    gazelle = ":gazelle-skylib",
)

bzl_library(
    name = "go_deps",
    srcs = ["go_deps.bzl"],
    visibility = ["//visibility:public"],
    deps = ["@bazel_gazelle//:deps"],
)

stardoc(
    name = "buf_rule_docs",
    out = "buf-rules.md",
    input = "//buf:defs.bzl",
    symbol_names = [
        "buf_lint_test",
        "buf_breaking_test",
        "buf_image",
    ],
    deps = [
        "//buf:defs",
    ],
)
