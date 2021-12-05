test_suite(
    name = "proto_lint_tests",
    tests = [
        "//pet/v1:lint",
    ],
)

test_suite(
    name = "proto_breaking_tests",
    tests = [
        "//pet/v1:breaking",
    ]
)

test_suite(
    name = "proto_tests",
    tests = [
        ":proto_breaking_tests",
        ":proto_lint_tests"
    ]
)