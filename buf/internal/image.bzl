# Copyright 2021-2023 Buf Technologies, Inc.
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

"""Defines buf_image rule"""

load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(":module.bzl", "create_module_zip")

_DOC = """
`buf_image` builds one or more `proto_library` targets outputs an image file.
"""

_TOOLCHAIN = str(Label("//tools/buf:toolchain_type"))

def _buf_image_impl(ctx):
    zip_file = ctx.actions.declare_file("{}.zip".format(ctx.label.name))
    create_module_zip(
        ctx,
        ctx.executable._zipper,
        [t[ProtoInfo] for t in ctx.attr.targets],
        ctx.file.config,
        ctx.file.lock,
        zip_file,
    )
    image_file = ctx.actions.declare_file("{}.{}".format(ctx.label.name, ctx.attr.format))
    args = ctx.actions.args()
    args.add("build")
    args.add(zip_file)
    args.add_joined(["--output", image_file], join_with = "=")
    ctx.actions.run(
        inputs = [zip_file],
        outputs = [image_file],
        executable = ctx.toolchains[_TOOLCHAIN].cli,
        arguments = [args],
    )
    return [
        DefaultInfo(
            files = depset([image_file]),
        ),
    ]

buf_image = rule(
    implementation = _buf_image_impl,
    doc = _DOC,
    attrs = {
        "_zipper": attr.label(
            default = Label("@bazel_tools//tools/zip:zipper"),
            executable = True,
            cfg = "exec",
        ),
        "targets": attr.label_list(
            providers = [ProtoInfo],
            mandatory = True,
            doc = """`proto_library` targets that should be part of the image. 
            Only the direct source will be part of the image i.e. only the files in the `srcs` attribute of `proto_library` targets will
            be included, the files from the `deps` attribute will not be included.
            """,
        ),
        "config": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The `buf.yaml` file",
        ),
        "lock": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The `buf.lock` file",
        ),
        "format": attr.string(
            doc = "The output image format. Supported formats: binpb,json,txtpb",
            default = "bin",
        ),
    },
    toolchains = [_TOOLCHAIN],
)
