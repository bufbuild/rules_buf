<!-- Generated with Stardoc: http://skydoc.bazel.build -->


# rules for building protocol buffers using buf

## Overview

The rules work alongside `proto_library` rule. They support,

- Linting ([buf_lint_test](#buf_lint_test))
- Breaking change detection ([buf_breaking_test](#buf_breaking_test)) 

Use [gazelle](/gazelle/buf) to auto generate all of these rules based on `buf.yaml`.



<a id="#buf_breaking_test"></a>

## buf_breaking_test

<pre>
buf_breaking_test(<a href="#buf_breaking_test-name">name</a>, <a href="#buf_breaking_test-against">against</a>, <a href="#buf_breaking_test-config">config</a>, <a href="#buf_breaking_test-exclude_imports">exclude_imports</a>, <a href="#buf_breaking_test-limit_to_input_files">limit_to_input_files</a>, <a href="#buf_breaking_test-targets">targets</a>)
</pre>


This checks protocol buffers for breaking changes using `buf breaking`. 
For an overview of breaking change detection using buf please refer: https://docs.buf.build/breaking/overview.

**NOTE**: 
In order to truly check breaking changes this rule should be used to check all `proto_library` targets that come under a [buf module](https://docs.buf.build/bsr/overview#module). 
Using unique test targets for each `proto_library` target checks each `proto_library` target in isolation. 
Checking targets/packages in isolation has the obvious caveat of not being able to detect when an entire package/target is removed/moved.

**Example**

This rule depends on `proto_library` rule.

```starlark
load("@rules_buf//buf:defs.bzl", "buf_breaking_test")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "foo_proto",
    srcs = ["foo.proto"],
)

buf_breaking_test(
    name = "foo_proto_breaking",
    # Image file to check against. Please refer to https://docs.buf.build/reference/images.
    against = "@build_buf_foo_foo//:file",
    targets = [":foo_proto"],
    config = ":buf.yaml",
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_breaking_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_breaking_test-against"></a>against |  The image file against which breaking changes are checked. This is typically derived from HEAD/last release tag of your repo/bsr. <code>rules_buf</code> provides a repository rule(<code>buf_image</code>) to reference an image from the buf schema registry   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="buf_breaking_test-config"></a>config |  The <code>buf.yaml</code> file   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="buf_breaking_test-exclude_imports"></a>exclude_imports |  Checks are limited to the source files excluding imports from breaking change detection. Please refer to https://docs.buf.build/breaking/protoc-plugin for more details   | Boolean | optional | True |
| <a id="buf_breaking_test-limit_to_input_files"></a>limit_to_input_files |  Checks are limited to input files. If a file gets deleted that will not be caught. Please refer to https://docs.buf.build/breaking/protoc-plugin for more details   | Boolean | optional | True |
| <a id="buf_breaking_test-targets"></a>targets |  <code>proto_library</code> targets to check for breaking changes   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |


<a id="#buf_lint_test"></a>

## buf_lint_test

<pre>
buf_lint_test(<a href="#buf_lint_test-name">name</a>, <a href="#buf_lint_test-config">config</a>, <a href="#buf_lint_test-targets">targets</a>)
</pre>


This lints protocol buffers using `buf lint`.
For an overview of linting using buf please refer: https://docs.buf.build/lint/overview.

**Example**

This rule depends on `proto_library` rule.

```starlark
load("@rules_buf//buf:defs.bzl", "buf_lint_test")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "foo_proto",
    srcs = ["pet.proto"],
    deps = ["@go_googleapis//google/type:datetime_proto"],
)

buf_lint_test(
    name = "foo_proto_lint",    
    targets = [":foo_proto"],
    config = "buf.yaml",
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_lint_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_lint_test-config"></a>config |  The <code>buf.yaml</code> file   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="buf_lint_test-targets"></a>targets |  <code>proto_library</code> targets that should be linted   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


