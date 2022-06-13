"""
# rules for building protocol buffers using buf

## Overview

The rules work alongside `proto_library` rule. They support,

- Linting ([buf_lint_test](#buf_lint_test))
- Breaking change detection ([buf_breaking_test](#buf_breaking_test)) 

Use [gazelle](/gazelle/buf) to auto generate all of these rules based on `buf.yaml`.

"""

load("//buf/internal:breaking.bzl", _buf_breaking_test = "buf_breaking_test")
load("//buf/internal:lint.bzl", _buf_lint_test = "buf_lint_test")
load("//buf/internal:repo.bzl", _buf_dependencies = "buf_dependencies")

buf_breaking_test = _buf_breaking_test
buf_lint_test = _buf_lint_test
buf_dependencies = _buf_dependencies
