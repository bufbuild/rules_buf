load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_buf//buf:defs.bzl", "buf_lint_test")

proto_library(
    name = "pets_v1_proto",
    srcs = ["pets.proto"],
    visibility = ["//visibility:public"],
    deps = ["@com_google_protobuf//:duration_proto"],
)

buf_lint_test(
    name = "pets_v1_proto_lint",
    config = "//:buf.yaml",
    targets = [":pets_v1_proto"],
)
