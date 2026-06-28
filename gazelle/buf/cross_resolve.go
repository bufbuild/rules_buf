// Copyright 2021-2025 Buf Technologies, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package buf

import (
	"path"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/resolve"
)

var (
	_ resolve.CrossResolver = (*bufLang)(nil)
)

func (*bufLang) CrossResolve(gazelleConfig *config.Config, ruleIndex *resolve.RuleIndex, importSpec resolve.ImportSpec, langWithDep string) []resolve.FindResult {
	// Both the language with dependency (langWithDep) and the dependency's lang should be proto
	// And example of where these are different is when `go` is trying to imported generated code from proto import path
	if langWithDep != "proto" || importSpec.Lang != "proto" {
		return nil
	}
	// First, check for gazelle:resolve buf directives
	// This allows users to override the default buf_deps resolution
	// Example: # gazelle:resolve buf proto/foo/bar.proto @com_example//proto/foo:bar_proto
	bufImportSpec := resolve.ImportSpec{
		Lang: "buf",
		Imp:  importSpec.Imp,
	}
	if override, ok := resolve.FindRuleWithOverride(gazelleConfig, bufImportSpec, "buf"); ok {
		return []resolve.FindResult{{Label: override}}
	}
	// Fall back to default buf_deps resolution
	config := GetConfigForGazelleConfig(gazelleConfig)
	depRepo := getRepoNameForPath(config.BufConfigFile.Pkg)

	// Generate target name from the proto file name, not the directory name
	// e.g., "nmts/v1/proto/ek/logical/interface.proto" -> "interface_proto"
	protoFile := path.Base(importSpec.Imp)
	targetName := strings.TrimSuffix(protoFile, ".proto") + "_proto"

	return []resolve.FindResult{
		{
			Label: label.New(depRepo, path.Dir(importSpec.Imp), targetName),
		},
	}
}
