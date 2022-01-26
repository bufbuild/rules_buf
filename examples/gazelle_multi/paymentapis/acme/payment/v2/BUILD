load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_buf//buf:defs.bzl", "buf_lint_test")

proto_library(
    name = "acme_payment_v2_proto",
    srcs = ["payment.proto"],
    strip_import_prefix = "/paymentapis",
    visibility = ["//visibility:public"],
)

buf_lint_test(
    name = "acme_payment_v2_proto_lint",
    config = "//paymentapis:buf.yaml",
    targets = [":acme_payment_v2_proto"],
)
