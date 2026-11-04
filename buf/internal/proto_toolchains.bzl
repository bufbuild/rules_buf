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

"""Proto toolchain resolution helpers"""

load("@com_google_protobuf//bazel/common:proto_common.bzl", "proto_common")

# Starting with rules_proto 7.1.0, @rules_proto//proto:toolchain_type is an
# alias for this type, so toolchains registered against it still resolve.
PROTO_TOOLCHAIN_TYPE = "@com_google_protobuf//bazel/private:proto_toolchain_type"

# Copied from protobuf's private toolchain_helpers.bzl.
_toolchain_resolution_enabled = getattr(proto_common, "INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION", False)

def _use_toolchain(toolchain_type):
    if _toolchain_resolution_enabled:
        return [config_common.toolchain_type(toolchain_type, mandatory = False)]
    return []

def _if_legacy_toolchain(legacy_attr_dict):
    if _toolchain_resolution_enabled:
        return {}
    return legacy_attr_dict

proto_toolchains = struct(
    use_toolchain = _use_toolchain,
    if_legacy_toolchain = _if_legacy_toolchain,
)
