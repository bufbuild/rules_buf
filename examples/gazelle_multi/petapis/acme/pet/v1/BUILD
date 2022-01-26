load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_buf//buf:defs.bzl", "buf_lint_test")

proto_library(
    name = "acme_pet_v1_proto",
    srcs = ["pet.proto"],
    strip_import_prefix = "/petapis",
    visibility = ["//visibility:public"],
    deps = ["//paymentapis/acme/payment/v2:acme_payment_v2_proto"],
)

buf_lint_test(
    name = "acme_pet_v1_proto_lint",
    config = "//petapis:buf.yaml",
    targets = [":acme_pet_v1_proto"],
)
