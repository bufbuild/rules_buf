<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules for building protocol buffers using buf

## Overview

The rules work alongside `proto_library` rule. They support,

- Linting ([buf_lint_test](#buf_lint_test))
- Breaking change detection ([buf_breaking_test](#buf_breaking_test))
- Formatting ([buf_format](#buf_format))
- BSR module dependencies ([buf_dependencies](#buf_dependencies))

Use [gazelle](/gazelle/buf) to auto generate all of these rules based on `buf.yaml`.

<a id="buf_format"></a>

## buf_format

<pre>
load("@rules_buf//buf:defs.bzl", "buf_format")

buf_format(<a href="#buf_format-name">name</a>)
</pre>

buf_format rule formats Protobuf files.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_format-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |


<a id="buf_breaking_test"></a>

## buf_breaking_test

<pre>
load("@rules_buf//buf:defs.bzl", "buf_breaking_test")

buf_breaking_test(<a href="#buf_breaking_test-timeout">timeout</a>, <a href="#buf_breaking_test-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="buf_breaking_test-timeout"></a>timeout |  <p align="center"> - </p>   |  `"short"` |
| <a id="buf_breaking_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="buf_lint_test"></a>

## buf_lint_test

<pre>
load("@rules_buf//buf:defs.bzl", "buf_lint_test")

buf_lint_test(<a href="#buf_lint_test-timeout">timeout</a>, <a href="#buf_lint_test-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="buf_lint_test-timeout"></a>timeout |  <p align="center"> - </p>   |  `"short"` |
| <a id="buf_lint_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="buf_dependencies"></a>

## buf_dependencies

<pre>
load("@rules_buf//buf:defs.bzl", "buf_dependencies")

buf_dependencies(<a href="#buf_dependencies-name">name</a>, <a href="#buf_dependencies-modules">modules</a>, <a href="#buf_dependencies-repo_mapping">repo_mapping</a>, <a href="#buf_dependencies-toolchain_repo">toolchain_repo</a>)
</pre>

`buf_dependencies` is a [repository rule](https://bazel.build/rules/repository_rules) that downloads one or more modules from the [BSR](https://docs.buf.build/bsr/introduction) and generates build files using Gazelle.
[Setup Gazelle](https://github.com/bazelbuild/bazel-gazelle#setup) to use this rule.

For more info please refer to the [`buf_dependencies` section](https://docs.buf.build/build-systems/bazel#buf-dependencies) of the docs.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="buf_dependencies-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="buf_dependencies-modules"></a>modules |  The module pins <remote>/<owner>/<repo>:<revision>, example: buf.build/acme/petapis:84a33a06f0954823a6f2a089fb1bb82e   | List of strings | required |  |
| <a id="buf_dependencies-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/core/dict">Dictionary: String -> String</a> | optional |  |
| <a id="buf_dependencies-toolchain_repo"></a>toolchain_repo |  The name of the rules_buf_toolchain repo. This is only needed the name of `rules_buf_toolchains` rule was modified.   | String | optional |  `"rules_buf_toolchains"`  |


