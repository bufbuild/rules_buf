# Copyright 2021-2025 Buf Technologies, Inc.
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

load("@rules_proto//proto:defs.bzl", "ProtoInfo")

_DOC = """
`buf_build` builds an [Image](https://buf.build/docs/build/overview/) from one or more `proto_library` targets.
"""

_TOOLCHAIN = str(Label("//tools/buf:toolchain_type"))

def _buf_build_impl(ctx):
    proto_infos = [t[ProtoInfo] for t in ctx.attr.targets]
    zip_file = ctx.actions.declare_file("{}.zip".format(ctx.label.name))
    zipper_args = ctx.actions.args()
    zipper_args.add("c", zip_file.path)

    zipper_inputs = []
    source_paths = []
    for pi in proto_infos:
        for f in pi.direct_sources:
            zipper_inputs.append(f)

            # This is the import path "foo/foo.proto"
            # We have to trim the prefix if strip_import_prefix attr is used in proto_library.
            source_paths.append(
                f.path[len(pi.proto_source_root) + 1:] if f.path.startswith(pi.proto_source_root) else f.path,
            )

    for i in range(len(zipper_inputs)):
        zipper_args.add_joined([source_paths[i], zipper_inputs[i]], join_with = "=")

    zipper_args.add_joined(["buf.yaml", ctx.file.config], join_with = "=")
    if ctx.file.lock != None:
        zipper_args.add_joined(["buf.lock", ctx.file.lock], join_with = "=")
    zipper_inputs = zipper_inputs + [ctx.file.config]
    if ctx.file.lock != None:
        zipper_inputs = [ctx.file.lock]

    ctx.actions.run(
        inputs = zipper_inputs,
        outputs = [zip_file],
        executable = ctx.executable._zipper,
        arguments = [zipper_args],
        progress_message = "Collecting proto sources",
        mnemonic = "zipper",
    )

    image_file = ctx.outputs.output
    ctx.actions.run(
        inputs = [zip_file],
        outputs = [image_file],
        executable = ctx.toolchains[_TOOLCHAIN].cli,
        arguments = ["build", zip_file.path, "-o", image_file.path],
        progress_message = "Building image",
    )

    return [
        DefaultInfo(
            files = depset([image_file]),
        ),
    ]

buf_build = rule(
    implementation = _buf_build_impl,
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
            doc = """`proto_library` targets that should be built. 
            Only the direct source will be included i.e. only the files in the `srcs` attribute of `proto_library` targets.
            The files from the `deps` attribute will not be part of the image.
            """,
        ),
        "config": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The `buf.yaml` file",
        ),
        "lock": attr.label(
            allow_single_file = True,
            doc = "The `buf.lock` file",
        ),
        "output": attr.output(
            mandatory = True,
            doc = "The output file",
        ),
    },
    toolchains = [_TOOLCHAIN],
)
