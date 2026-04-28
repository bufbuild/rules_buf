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

"""buf_deps macro that pins this example's BSR module dependencies."""

load("@rules_buf//buf:defs.bzl", "buf_dependencies")

def buf_deps():
    buf_dependencies(
        name = "buf_deps_barapis",
        modules = [
            "buf.build/acme/paymentapis:9a877cf260e1488d869a31fce3bea26d",
            "buf.build/acme/petapis:7abdb7802c8f4737a1a23a35ca8266ef",
            "buf.build/envoyproxy/protoc-gen-validate:daf171c6cdb54629b5f51e345a79e4dd",
            "buf.build/googleapis/googleapis:c17df5b2beca46928cc87d5656bd5343",
        ],
    )
    buf_dependencies(
        name = "buf_deps_fooapis",
        modules = [
            "buf.build/acme/paymentapis:9a877cf260e1488d869a31fce3bea26d",
            "buf.build/acme/petapis:7abdb7802c8f4737a1a23a35ca8266ef",
            "buf.build/googleapis/googleapis:c17df5b2beca46928cc87d5656bd5343",
        ],
    )
