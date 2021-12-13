<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Starlark rules for building protocol buffers using buf

<a id="#buf_breaking_test"></a>

## buf_breaking_test

<pre>
buf_breaking_test(<a href="#buf_breaking_test-name">name</a>, <a href="#buf_breaking_test-against">against</a>, <a href="#buf_breaking_test-except_rules">except_rules</a>, <a href="#buf_breaking_test-exclude_imports">exclude_imports</a>, <a href="#buf_breaking_test-ignore">ignore</a>, <a href="#buf_breaking_test-ignore_only">ignore_only</a>,
                  <a href="#buf_breaking_test-ignore_unstable_packages">ignore_unstable_packages</a>, <a href="#buf_breaking_test-limit_to_input_files">limit_to_input_files</a>, <a href="#buf_breaking_test-targets">targets</a>, <a href="#buf_breaking_test-use_rules">use_rules</a>)
</pre>


This checks protocol buffers for breaking changes using `buf breaking`. For an overview of linting using buf please refer: https://docs.buf.build/lint/overview.

NOTE: In order to truly check breaking changes this rule should be used to check all `proto_library` targets that come under a common import path. Using separate for each `proto_library` target only checks the current target for breaking changes. Checking individual targets/packages for breaking changes has the obvious caveat of not being able to detect when an entire package/target is removed/moved

Example:
    This rule works alongside `proto_library` rule.

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
    


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_breaking_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="buf_breaking_test-against"></a>against |  The image file against which breaking changes are checked. <code>rules_buf</code> provides a repository rule(<code>buf_image</code>) to reference an image from the buf schema registry   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="buf_breaking_test-except_rules"></a>except_rules |  https://docs.buf.build/breaking/configuration#except   | List of strings | optional | [] |
| <a id="buf_breaking_test-exclude_imports"></a>exclude_imports |  https://docs.buf.build/breaking/protoc-plugin   | Boolean | optional | True |
| <a id="buf_breaking_test-ignore"></a>ignore |  https://docs.buf.build/lint/configuration#ignore   | List of strings | optional | [] |
| <a id="buf_breaking_test-ignore_only"></a>ignore_only |  https://docs.buf.build/lint/configuration#ignore_only   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> List of strings</a> | optional | {} |
| <a id="buf_breaking_test-ignore_unstable_packages"></a>ignore_unstable_packages |  https://docs.buf.build/breaking/configuration#ignore_unstable_packages   | Boolean | optional | False |
| <a id="buf_breaking_test-limit_to_input_files"></a>limit_to_input_files |  https://docs.buf.build/breaking/protoc-plugin   | Boolean | optional | True |
| <a id="buf_breaking_test-targets"></a>targets |  <code>proto_library</code> targets to check breaking changes against.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="buf_breaking_test-use_rules"></a>use_rules |  https://docs.buf.build/breaking/configuration#use   | List of strings | optional | ["FILE"] |


<a id="#buf_image"></a>

## buf_image

<pre>
buf_image(<a href="#buf_image-name">name</a>, <a href="#buf_image-buf">buf</a>, <a href="#buf_image-commit">commit</a>, <a href="#buf_image-module">module</a>, <a href="#buf_image-repo_mapping">repo_mapping</a>, <a href="#buf_image-sha256">sha256</a>)
</pre>



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

Example:
    This rule works alongside `proto_library` rule.

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


