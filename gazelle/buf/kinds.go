package buf

import "github.com/bazelbuild/bazel-gazelle/rule"

const (
	lintRuleKind     = "buf_lint_test"
	breakingRuleKind = "buf_breaking_test"
)

var bufKinds = map[string]rule.KindInfo{
	lintRuleKind: {
		MatchAttrs: []string{"targets"},
		MergeableAttrs: map[string]bool{
			"config": true,
		},
	},
	breakingRuleKind: {
		MatchAttrs: []string{"targets"},
		MergeableAttrs: map[string]bool{
			"against":              true,
			"exclude_imports":      true,
			"limit_to_input_files": true,
		},
		ResolveAttrs: map[string]bool{
			"targets": true,
		},
	},
}

var bufLoads = []rule.LoadInfo{
	{
		Name: "@rules_buf//buf:defs.bzl",
		Symbols: []string{
			lintRuleKind,
			breakingRuleKind,
		},
	},
}

func (*bufLang) Kinds() map[string]rule.KindInfo { return bufKinds }
func (*bufLang) Loads() []rule.LoadInfo          { return bufLoads }
