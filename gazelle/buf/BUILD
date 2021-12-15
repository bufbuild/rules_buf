load("@io_bazel_rules_go//go:def.bzl", "go_library")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

go_library(
    name = "buf",
    srcs = [
        "break.go",
        "config.go",
        "gazelle.go",
        "lint.go",
        "update_repos.go",
    ],
    importpath = "github.com/bufbuild/rules_buf/gazelle/buf",
    visibility = ["//visibility:public"],
    deps = [
        "@bazel_gazelle//config:go_default_library",
        "@bazel_gazelle//label:go_default_library",
        "@bazel_gazelle//language:go_default_library",
        "@bazel_gazelle//repo:go_default_library",
        "@bazel_gazelle//resolve:go_default_library",
        "@bazel_gazelle//rule:go_default_library",
        "@in_gopkg_yaml_v3//:yaml_v3",
    ],
)

bzl_library(
    name = "repositories",
    srcs = ["repositories.bzl"],
    visibility = ["//visibility:public"],
    deps = ["@bazel_gazelle//:deps"],
)
