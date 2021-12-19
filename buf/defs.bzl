"""
# rules for building protocol buffers using buf

## Overview

The rules work alongside `proto_library` rule. They support,

- Linting ([buf_lint_test](#buf_lint_test))
- Breaking change detection ([buf_breaking_test](#buf_breaking_test)) 
- Repository rule for managing protobuf dependencies ([buf_repository](#buf_repository))

Each of them can be adopted independent from one another.

They currently do not have or limited support for,
- [WIP] buf build (image generation)
- buf generate
- managed mode

Use [gazelle](/gazelle/buf) to auto generate all of these rules based on `buf.yaml`.

"""

load("//buf/internal:break.bzl", _buf_breaking_test = "buf_breaking_test")
load("//buf/internal:image.bzl", _buf_image = "buf_image")
load("//buf/internal:lint.bzl", _buf_lint_test = "buf_lint_test")
load("//buf/internal:repo.bzl", _buf_repository = "buf_repository")
load("//buf/internal:dep.bzl", _buf_dependencies = "buf_dependencies")

buf_breaking_test = _buf_breaking_test
buf_lint_test = _buf_lint_test

buf_image = _buf_image
buf_repository = _buf_repository
buf_module = _buf_dependencies
