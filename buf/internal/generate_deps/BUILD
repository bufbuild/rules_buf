load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_library(
    name = "generate_deps_lib",
    srcs = ["main.go"],
    importpath = "github.com/bufbuild/rules_go/buf/internal/generate_deps",
    visibility = ["//visibility:private"],
)

go_binary(
    name = "generate_deps",
    embed = [":generate_deps_lib"],
    visibility = ["//private:__subpackages__"],
)
