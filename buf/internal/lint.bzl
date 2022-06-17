# Copyright 2021-2022 Buf Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Defines buf_lint_test rule"""

load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(":plugin.bzl", "protoc_plugin_test")

_DOC = """
This lints protocol buffers using `buf lint`.
For an overview of linting using buf please refer: https://docs.buf.build/lint/overview.

**Gazelle**

The [gazelle extension](/gazelle/buf/README.md) can be used generate this rule.

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
"""

_TOOLCHAIN = str(Label("//tools/protoc-gen-buf-lint:toolchain_type"))

def _buf_lint_test_impl(ctx):
    proto_infos = [t[ProtoInfo] for t in ctx.attr.targets]
    config = json.encode({
        "input_config": "" if ctx.file.config == None else ctx.file.config.short_path,
    })
    files_to_include = []
    if ctx.file.config != None:
        files_to_include.append(ctx.file.config) 
    return protoc_plugin_test(ctx, proto_infos, ctx.executable._protoc, ctx.toolchains[_TOOLCHAIN].cli, config, files_to_include)

buf_lint_test = rule(
    implementation = _buf_lint_test_impl,
    doc = _DOC,
    attrs = {
        "_protoc": attr.label(
            default = "@com_google_protobuf//:protoc",
            executable = True,
            cfg = "exec",
        ),
        "targets": attr.label_list(
            providers = [ProtoInfo],
            mandatory = True,
            doc = "`proto_library` targets that should be linted",
        ),
        "config": attr.label(
            allow_single_file = True,
            doc = "The `buf.yaml` file",
        ),
    },
    toolchains = [_TOOLCHAIN],
    test = True,
)
