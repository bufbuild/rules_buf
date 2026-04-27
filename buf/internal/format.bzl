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

"""Implementation of the buf_format rule."""

_DOC = """
buf_format rule formats Protobuf files.
"""

_TEMPLATE = """
buf=$(readlink "{}")
if ! cd "$BUILD_WORKSPACE_DIRECTORY"; then
  echo "Unable to change to workspace (BUILD_WORKSPACE_DIRECTORY: $BUILD_WORKSPACE_DIRECTORY)"
  exit 1
fi

$buf format {} .
"""

_TOOLCHAIN = str(Label("//tools/buf:toolchain_type"))

def _buf_format_impl(ctx):
    ctx.actions.write(
        output = ctx.outputs.executable,
        is_executable = True,
        content = _TEMPLATE.format(ctx.toolchains[_TOOLCHAIN].cli.short_path, "-w"),
    )

    return [
        DefaultInfo(
            runfiles = ctx.runfiles(
                files = [ctx.toolchains[_TOOLCHAIN].cli],
            ),
        ),
    ]

buf_format = rule(
    implementation = _buf_format_impl,
    doc = _DOC,
    attrs = {},
    toolchains = [_TOOLCHAIN],
    executable = True,
)
