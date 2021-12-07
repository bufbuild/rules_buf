load("@rules_buf//:lint.bzl", "buf_lint_test")
load("@rules_buf//:break.bzl", "buf_breaking_test")
load("@rules_proto//proto:defs.bzl", "proto_library")

package(default_visibility = ["//:__subpackages__"])

proto_library(
    name = "petv1_proto",
    srcs = ["pet.proto"],
    deps = ["@go_googleapis//google/type:datetime_proto"],
)

buf_lint_test(
    name = "petv1_proto_lint",
    except_rules = [
        "PACKAGE_VERSION_SUFFIX",
        "FIELD_LOWER_SNAKE_CASE",
    ],
    target = ":petv1_proto",
    use_rules = ["DEFAULT"],
)

buf_breaking_test(
    name = "petv1_proto_breaking",
    against = "@petapis//image:file",
    target = ":petv1_proto",
    use_rules = ["FILE"],
)
