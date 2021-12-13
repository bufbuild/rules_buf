package buf

import (
	"fmt"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/rule"
)

const breakingRuleKind = "buf_breaking_test"

type breakingRule struct {
}

func (breakingRule) Kind() string {
	return breakingRuleKind
}

func (breakingRule) KindInfo() rule.KindInfo {
	return rule.KindInfo{
		MatchAttrs: []string{"target"},
		MergeableAttrs: map[string]bool{
			"against":                  true,
			"ignore":                   true,
			"ignore_only":              true,
			"use_rules":                true,
			"except_rules":             true,
			"exclude_imports":          true,
			"limit_to_input_files":     true,
			"ignore_unstable_packages": true,
		},
	}
}

func (breakingRule) LoadInfo() rule.LoadInfo {
	return rule.LoadInfo{
		Name:    "@rules_buf//buf:defs.bzl",
		Symbols: []string{breakingRuleKind},
	}
}

// GenRule returns a list of rules that need be generated for each `proto_library` rule.
func (breakingRule) GenRule(pr *rule.Rule, c *Config) (*rule.Rule, interface{}) {
	if c.BreakingImageTarget == "" {
		return nil, nil
	}

	r := rule.NewRule("buf_breaking_test", fmt.Sprintf("%s_breaking", pr.Name()))

	r.SetAttr("target", fmt.Sprintf(":%s", pr.Name()))
	r.SetAttr("against", c.BreakingImageTarget)

	if !c.BreakingExludeImports {
		r.SetAttr("exclude_imports", false)
	}

	if !c.BreakingLimitToInputFiles {
		r.SetAttr("limit_to_input_files", false)
	}

	if c.Module != nil && c.Module.Breaking != nil {
		breaking := c.Module.Breaking
		if len(breaking.Use) > 0 {
			r.SetAttr("use_rules", breaking.Use)
		}

		if len(breaking.Except) > 0 {
			r.SetAttr("except_rules", breaking.Except)
		}

		if len(breaking.Ignore) > 0 {
			r.SetAttr("ignore", breaking.Ignore)
		}

		if len(breaking.IgnoreOnly) > 0 {
			r.SetAttr("ignore_only", breaking.IgnoreOnly)
		}

		if breaking.IgnoreUnstablePackages != nil {
			r.SetAttr("ignore_unstable_packages", *breaking.IgnoreUnstablePackages)
		}
	}

	return r, struct{}{}
}

// ShouldRemoveRule determines if this rule should be removed from the file. Typically rules generated in the previous run.
func (breakingRule) ShouldRemoveRule(r *rule.Rule, protoRules map[string]*rule.Rule) bool {
	target := strings.TrimPrefix(r.AttrString("target"), ":")
	return protoRules[target] == nil
}
