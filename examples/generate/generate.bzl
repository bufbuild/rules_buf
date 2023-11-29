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

"""Defines buf_generate rule"""

_DOC = """
`buf_generate` runs `buf generate` against an image and zips the output.
"""

_TOOLCHAIN = str(Label("@rules_buf//tools/buf:toolchain_type"))

def _buf_generate_impl(ctx):
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "{} generate {} --template {} --output $BUILD_WORKSPACE_DIRECTORY/{}".format(
            ctx.toolchains[_TOOLCHAIN].cli.short_path,
            ctx.file.image.short_path,
            ctx.file.template.short_path,
            ctx.attr.out_dir,
        ),
        is_executable = True,
    )
    return [
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = [ctx.file.image, ctx.file.template, ctx.toolchains[_TOOLCHAIN].cli],
            ),
        ),
    ]

buf_generate = rule(
    implementation = _buf_generate_impl,
    doc = _DOC,
    attrs = {
        "image": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = """The image file to generate from. Typically a `buf_image` rule.""",
        ),
        "template": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The `buf.gen.yaml` file",
        ),
        "out_dir": attr.string(
            mandatory = True,
            doc = "The base directory to generate to. This is prepended to the out directories in the generation template",
        ),
    },
    toolchains = [_TOOLCHAIN],
    executable = True,
)
