<!-- Generated with Stardoc: http://skydoc.bazel.build -->


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



<a id="#buf_breaking_test"></a>

## buf_breaking_test

<pre>
buf_breaking_test(<a href="#buf_breaking_test-name">name</a>, <a href="#buf_breaking_test-against">against</a>, <a href="#buf_breaking_test-except_rules">except_rules</a>, <a href="#buf_breaking_test-exclude_imports">exclude_imports</a>, <a href="#buf_breaking_test-ignore">ignore</a>, <a href="#buf_breaking_test-ignore_only">ignore_only</a>,
                  <a href="#buf_breaking_test-ignore_unstable_packages">ignore_unstable_packages</a>, <a href="#buf_breaking_test-limit_to_input_files">limit_to_input_files</a>, <a href="#buf_breaking_test-targets">targets</a>, <a href="#buf_breaking_test-use_rules">use_rules</a>)
</pre>


This checks protocol buffers for breaking changes using `buf breaking`. For an overview of breaking change detection using buf please refer: https://docs.buf.build/breaking/overview.

**NOTE**: In order to truly check breaking changes this rule should be used to check all `proto_library` targets that come under a [buf module](https://docs.buf.build/bsr/overview#module). Using unique test targets for each `proto_library` target checks each `proto_library` target in isolation. Checking targets/packages in isolation has the obvious caveat of not being able to detect when an entire package/target is removed/moved.

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
    # Image file to check against
    against = "@build_buf_foo_foo//:file",
    targets = [":foo_proto"],
    use_rules = ["DEFAULT"],
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_breaking_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_breaking_test-against"></a>against |  The image file against which breaking changes are checked. This is typically derived from HEAD/last release tag of your repo/bsr. <code>rules_buf</code> provides a repository rule(<code>buf_image</code>) to reference an image from the buf schema registry   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="buf_breaking_test-except_rules"></a>except_rules |  https://docs.buf.build/breaking/configuration#except   | List of strings | optional | [] |
| <a id="buf_breaking_test-exclude_imports"></a>exclude_imports |  https://docs.buf.build/breaking/protoc-plugin   | Boolean | optional | True |
| <a id="buf_breaking_test-ignore"></a>ignore |  https://docs.buf.build/breaking/configuration#ignore   | List of strings | optional | [] |
| <a id="buf_breaking_test-ignore_only"></a>ignore_only |  https://docs.buf.build/breaking/configuration#ignore_only   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> List of strings</a> | optional | {} |
| <a id="buf_breaking_test-ignore_unstable_packages"></a>ignore_unstable_packages |  https://docs.buf.build/breaking/configuration#ignore_unstable_packages   | Boolean | optional | False |
| <a id="buf_breaking_test-limit_to_input_files"></a>limit_to_input_files |  https://docs.buf.build/breaking/protoc-plugin   | Boolean | optional | True |
| <a id="buf_breaking_test-targets"></a>targets |  <code>proto_library</code> targets to check for breaking changes   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="buf_breaking_test-use_rules"></a>use_rules |  https://docs.buf.build/breaking/configuration#use   | List of strings | optional | ["FILE"] |


<a id="#buf_image"></a>

## buf_image

<pre>
buf_image(<a href="#buf_image-name">name</a>, <a href="#buf_image-buf">buf</a>, <a href="#buf_image-commit">commit</a>, <a href="#buf_image-module">module</a>, <a href="#buf_image-repo_mapping">repo_mapping</a>, <a href="#buf_image-sha256">sha256</a>)
</pre>

`buf_image` creates a buf image file against a buf module. It can be accessed by //@foo/image:file. This one will be superseded see `buf_repository`

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_image-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_image-buf"></a>buf |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="buf_image-commit"></a>commit |  -   | String | required |  |
| <a id="buf_image-module"></a>module |  -   | String | required |  |
| <a id="buf_image-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | required |  |
| <a id="buf_image-sha256"></a>sha256 |  -   | String | optional | "" |


<a id="#buf_lint_test"></a>

## buf_lint_test

<pre>
buf_lint_test(<a href="#buf_lint_test-name">name</a>, <a href="#buf_lint_test-allow_comment_ignores">allow_comment_ignores</a>, <a href="#buf_lint_test-enum_zero_value_suffix">enum_zero_value_suffix</a>, <a href="#buf_lint_test-except_rules">except_rules</a>, <a href="#buf_lint_test-ignore">ignore</a>,
              <a href="#buf_lint_test-ignore_only">ignore_only</a>, <a href="#buf_lint_test-rpc_allow_google_protobuf_empty_requests">rpc_allow_google_protobuf_empty_requests</a>,
              <a href="#buf_lint_test-rpc_allow_google_protobuf_empty_responses">rpc_allow_google_protobuf_empty_responses</a>, <a href="#buf_lint_test-rpc_allow_same_request_response">rpc_allow_same_request_response</a>,
              <a href="#buf_lint_test-service_suffix">service_suffix</a>, <a href="#buf_lint_test-targets">targets</a>, <a href="#buf_lint_test-use_rules">use_rules</a>)
</pre>


This lints protocol buffers using `buf lint`. For an overview of linting using buf please refer: https://docs.buf.build/lint/overview.

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
    except_rules = [
        "PACKAGE_VERSION_SUFFIX",
        "FIELD_LOWER_SNAKE_CASE",
    ],
    targets = [":foo_proto"],
    use_rules = ["DEFAULT"],
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_lint_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_lint_test-allow_comment_ignores"></a>allow_comment_ignores |  https://docs.buf.build/lint/configuration#allow_comment_ignores   | Boolean | optional | True |
| <a id="buf_lint_test-enum_zero_value_suffix"></a>enum_zero_value_suffix |  https://docs.buf.build/lint/configuration#enum_zero_value_suffix   | String | optional | "_UNSPECIFIED" |
| <a id="buf_lint_test-except_rules"></a>except_rules |  https://docs.buf.build/lint/configuration#except   | List of strings | optional | [] |
| <a id="buf_lint_test-ignore"></a>ignore |  https://docs.buf.build/lint/configuration#ignore   | List of strings | optional | [] |
| <a id="buf_lint_test-ignore_only"></a>ignore_only |  https://docs.buf.build/lint/configuration#ignore_only   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> List of strings</a> | optional | {} |
| <a id="buf_lint_test-rpc_allow_google_protobuf_empty_requests"></a>rpc_allow_google_protobuf_empty_requests |  https://docs.buf.build/lint/configuration#rpc_allow_   | Boolean | optional | False |
| <a id="buf_lint_test-rpc_allow_google_protobuf_empty_responses"></a>rpc_allow_google_protobuf_empty_responses |  https://docs.buf.build/lint/configuration#rpc_allow_   | Boolean | optional | False |
| <a id="buf_lint_test-rpc_allow_same_request_response"></a>rpc_allow_same_request_response |  https://docs.buf.build/lint/configuration#rpc_allow_   | Boolean | optional | False |
| <a id="buf_lint_test-service_suffix"></a>service_suffix |  https://docs.buf.build/lint/configuration#service_suffix   | String | optional | "Service" |
| <a id="buf_lint_test-targets"></a>targets |  <code>proto_library</code> targets that should be linted   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="buf_lint_test-use_rules"></a>use_rules |  https://docs.buf.build/lint/configuration#use   | List of strings | optional | ["DEFAULT"] |


<a id="#buf_repository"></a>

## buf_repository

<pre>
buf_repository(<a href="#buf_repository-name">name</a>, <a href="#buf_repository-buf">buf</a>, <a href="#buf_repository-commit">commit</a>, <a href="#buf_repository-digest">digest</a>, <a href="#buf_repository-module">module</a>, <a href="#buf_repository-repo_mapping">repo_mapping</a>)
</pre>


`buf_repository` downloads a [buf module](https://docs.buf.build/bsr/overview#module) and generates `BUILD` files. It currently generates a single `proto_library` target with all the proto files inside a module. The target is named as `default_proto_library`.

**Example**
```starlark
# `proto_library` target can referenced using "@build_buf_acme_petapis//:default_proto_library"
buf_repository(
    name = "build_buf_acme_petapis",
    module = "buf.build/acme/petapis",
    commit = "84a33a06f0954823a6f2a089fb1bb82e",    
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_repository-buf"></a>buf |  The buf cli to use to fetch the buf modules. Use this to override the default version provided by this repo   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="buf_repository-commit"></a>commit |  commit/revision of the module on BSR to download   | String | required |  |
| <a id="buf_repository-digest"></a>digest |  The digest of module contents. <code>buf_repository</code> will verify the downloaded module matches this digest. A value for digest will be suggested if one is not provided.<br><br>A value for digest can also be found in the <code>buf.lock</code> file. If you can't find the <code>buf.lock</code> file please run <code>buf mod update</code>.   | String | optional | "" |
| <a id="buf_repository-module"></a>module |  The name of the module on bsr. Example: <code>buf.build/acme/petapis</code>   | String | required |  |
| <a id="buf_repository-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | required |  |


