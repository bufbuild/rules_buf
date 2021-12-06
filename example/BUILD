load("@bazel_gazelle//:def.bzl", "gazelle", "gazelle_binary")

gazelle_binary(
    name = "gazelle-buf",
    languages = [
        "@bazel_gazelle//language/proto:go_default_library",
        "@rules_buf//gazelle/buf:buf",
    ],
    visibility = ["//visibility:public"],
)

# gazelle:exclude google/**
gazelle(
    name = "gazelle",
    args = [
        "-buf_config=buf.yaml",
        "-buf_breaking_image=@petapis//image:file",
    ],
    gazelle = "//:gazelle-buf",
)

test_suite(
    name = "proto_lint_tests",
    tests = [
        "//pet/v1:petv1_proto_lint",
    ],
)

test_suite(
    name = "proto_breaking_tests",
    tests = [
        "//pet/v1:petv1_proto_breaking",
    ],
)

test_suite(
    name = "proto_tests",
    tests = [
        ":proto_breaking_tests",
        ":proto_lint_tests",
    ],
)
