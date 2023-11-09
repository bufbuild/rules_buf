// Copyright 2021-2022 Buf Technologies, Inc.
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
	"fmt"
	"io/fs"
	"os"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

func (*bufLang) Fix(c *config.Config, f *rule.File) {}

func (*bufLang) GenerateRules(args language.GenerateArgs) language.GenerateResult {
	result := language.GenerateResult{}
	config := GetConfigForGazelleConfig(args.Config)
	// Skip if we are in any of the excludes directories
	if isWithinExcludes(config, args.Rel) {
		return result
	}
	protoRuleMap := make(map[string]*rule.Rule, len(args.OtherGen))
	// Lint and breaking package mode
	for _, rule := range args.OtherGen {
		if rule.Kind() != "proto_library" {
			continue
		}
		protoTarget := rule.Name()
		protoRuleMap[protoTarget] = rule
		result.Gen = append(result.Gen, generateLintRule(config, protoTarget))
		result.Imports = append(result.Imports, struct{}{})
		if config.BreakingImageTarget == "" || config.BreakingMode == BreakingModeModule {
			continue
		}
		result.Gen = append(result.Gen, generateBreakingRule(config, protoTarget))
		result.Imports = append(result.Imports, struct{}{})
	}
	if config.ModuleRoot {
		protoImportPaths := getProtoImportPaths(config, args.Dir)
		if config.Module.Name != "" {
			pushRule := generatePushRule()
			result.Gen = append(result.Gen, pushRule)
			result.Imports = append(result.Imports, protoImportPaths)
		}
		if config.BreakingImageTarget != "" && config.BreakingMode == BreakingModeModule {
			breakingRule := generateBreakingRule(config, "buf")
			result.Gen = append(result.Gen, breakingRule)
			result.Imports = append(result.Imports, getProtoImportPaths(config, args.Dir))
		}
	}
	if args.File == nil {
		return result
	}
	// Stale rules to remove
	for _, rule := range args.File.Rules {
		// In module mode delete all
		if rule.Kind() == breakingRuleKind && config.BreakingMode == BreakingModeModule {
			result.Empty = append(result.Empty, generateEmptyRule(rule))
			continue
		}
		if rule.Kind() == pushRuleKind {
			result.Empty = append(result.Empty, generateEmptyRule(rule))
			continue
		}
		// proto_library targets are mapped one to one for lint and breaking rules in package mode
		if rule.Kind() == lintRuleKind || rule.Kind() == breakingRuleKind {
			if shouldRemoveSingleTargetBufRule(
				protoRuleMap,
				rule,
			) {
				result.Empty = append(result.Empty, generateEmptyRule(rule))
			}
		}
	}
	return result
}

func generateLintRule(config *Config, target string) *rule.Rule {
	r := rule.NewRule("buf_lint_test", fmt.Sprintf("%s_lint", target))
	r.SetAttr("targets", []string{fmt.Sprintf(":%s", target)})
	if config.Module != nil {
		r.SetAttr("config", config.BufConfigFile.String())
	}
	return r
}

func generateBreakingRule(config *Config, target string) *rule.Rule {
	r := rule.NewRule(breakingRuleKind, fmt.Sprintf("%s_breaking", target))
	r.SetAttr("targets", []string{fmt.Sprintf(":%s", target)})
	r.SetAttr("against", config.BreakingImageTarget)
	// Set optional attributes
	if !config.BreakingExcludeImports {
		r.SetAttr("exclude_imports", false)
	}
	if config.BreakingMode == BreakingModePackage {
		r.SetAttr("limit_to_input_files", true)
	}
	if config.Module != nil {
		r.SetAttr("config", config.BufConfigFile.String())
	}
	return r
}

func generatePushRule() *rule.Rule {
	r := rule.NewRule(pushRuleKind, "buf_push")
	r.SetAttr("config", "buf.yaml")
	r.SetAttr("lock", "buf.lock")
	return r
}

// shouldRemoveSingleTargetBufRule checks if lint and breaking rules in package mode need to be removed
func shouldRemoveSingleTargetBufRule(
	protoRuleMap map[string]*rule.Rule,
	bufRule *rule.Rule,
) bool {
	targets := bufRule.AttrStrings("targets")
	if len(targets) > 1 {
		// Not generated by us
		return false
	}
	if len(targets) == 1 && protoRuleMap[strings.TrimPrefix(targets[0], ":")] != nil {
		// Target is accurate so skip
		return false
	}
	return true
}

func getProtoImportPaths(config *Config, moduleRoot string) []string {
	var targets []string
	fs.WalkDir(
		os.DirFS(moduleRoot),
		".",
		func(path string, dirEntry fs.DirEntry, err error) error {
			if dirEntry.IsDir() {
				return nil
			}
			if !strings.HasSuffix(dirEntry.Name(), ".proto") {
				return nil
			}
			// Skip if we are in any of the excludes directories
			if isWithinExcludes(config, path) {
				return nil
			}
			targets = append(targets, path)
			return nil
		},
	)
	return targets
}

func generateEmptyRule(bufRule *rule.Rule) *rule.Rule {
	return rule.NewRule(bufRule.Kind(), bufRule.Name())
}
