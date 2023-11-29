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

"""Defines functions to manage buf modules"""

def create_module_zip(ctx, zipper, proto_infos, config, lock, zip_file):
    """
    Creates a zip file for the module using the sources and `buf.yaml` and `buf.lock` files

    Args:
        ctx: rule context
        zipper: The zip tool to use
        proto_infos: The ProtoInfo providers of `proto_library`
        config: The config file
        lock: The lock file
        zip_file: The zip file to create
    """
    args = ctx.actions.args()
    args.add("c", zip_file.path)

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
        args.add_joined([source_paths[i], zipper_inputs[i]], join_with = "=")

    args.add_joined(["buf.yaml", config], join_with = "=")
    args.add_joined(["buf.lock", lock], join_with = "=")
    zipper_inputs = zipper_inputs + [config, lock]

    ctx.actions.run(
        inputs = zipper_inputs,
        outputs = [zip_file],
        executable = zipper,
        arguments = [args],
        progress_message = "Collecting proto sources",
        mnemonic = "zipper",
    )
