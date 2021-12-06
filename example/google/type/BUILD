load("@rules_proto//proto:defs.bzl", "proto_library")

package(default_visibility = ["//:__subpackages__"])

proto_library(
    name = "datetime_proto",
    srcs = ["datetime.proto"],
    deps = ["@com_google_protobuf//:duration_proto"],
)
