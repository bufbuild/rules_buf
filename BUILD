load("@bazel_gazelle//:def.bzl", "DEFAULT_LANGUAGES", "gazelle", "gazelle_binary")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

gazelle_binary(
    name = "gazelle-skylib",
    languages = DEFAULT_LANGUAGES + [
        # "@bazel_skylib//gazelle/bzl:bzl",
    ],
    visibility = ["//:__pkg__"],
)

# gazelle:prefix github.com/bufbuild/rules_buf
# gazelle:exclude example/**
gazelle(
    name = "gazelle",
    gazelle = ":gazelle-skylib",
)

gazelle(
    name = "gazelle_update_repos",
    command = "update-repos",
    args = [
        "-from_file=go.mod",
        "-prune",
        "-to_macro=gazelle/buf/repositories.bzl%gazelle_buf_dependencies",
    ]
)

stardoc(
    name = "buf_rule_docs",
    out = "buf-rules.md",
    input = "//buf:defs.bzl",
    symbol_names = [
        "buf_lint_test",
        "buf_breaking_test",
        "buf_repository",
        "buf_image",
    ],
    deps = [
        "//buf:defs",
    ],
)
