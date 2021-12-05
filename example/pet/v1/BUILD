load("@rules_buf//:lint.bzl", "buf_lint_test")
load("@rules_buf//:break.bzl", "buf_breaking_test")

package(default_visibility = ["//:__subpackages__"])

proto_library(
    name = "pet_v1_proto",
    srcs = ["pet.proto"],
    deps = ["//google/type:google_type_proto"],
)

buf_lint_test(
    name = "lint",
    except_rules = [
        "PACKAGE_VERSION_SUFFIX",
        "FIELD_LOWER_SNAKE_CASE",
        "SERVICE_SUFFIX",
    ],
    target = ":pet_v1_proto",
    use_rules = [
        "DEFAULT",
    ],
)

buf_breaking_test(
    name = "breaking",
    against = "@petapis//image:file",
    target = ":pet_v1_proto",
)
