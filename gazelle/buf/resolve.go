package buf

import (
	"log"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/repo"
	"github.com/bazelbuild/bazel-gazelle/resolve"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

func (*bufLang) Imports(*config.Config, *rule.Rule, *rule.File) []resolve.ImportSpec { return nil }
func (*bufLang) Embeds(*rule.Rule, label.Label) []label.Label                        { return nil }

func (l *bufLang) Resolve(
	gazelleConfig *config.Config,
	ruleIndex *resolve.RuleIndex,
	remoteCache *repo.RemoteCache,
	ruleToResolve *rule.Rule,
	importsRaw interface{},
	fromLabel label.Label,
) {
	// Only breaking rule requires resolution
	switch ruleToResolve.Kind() {
	case breakingRuleKind:
		resolveBreakingRule(
			gazelleConfig,
			ruleIndex,
			remoteCache,
			ruleToResolve,
			importsRaw,
			fromLabel,
		)
	}
}

// resolveBreakingRule resolves targets of buf_breaking_test in Module mode
func resolveBreakingRule(
	gazelleConfig *config.Config,
	ruleIndex *resolve.RuleIndex,
	remoteCache *repo.RemoteCache,
	breakingRule *rule.Rule,
	importsRaw interface{},
	fromLabel label.Label,
) {
	config := GetConfigForGazelleConfig(gazelleConfig)
	if config.BreakingMode != BreakingModeModule {
		return
	}
	// importsRaw will be `[]string` for module mode
	imports, ok := importsRaw.([]string)
	if !ok {
		return
	}
	targetSet := make(map[string]struct{})
	for _, imp := range imports {
		results := ruleIndex.FindRulesByImportWithConfig(
			gazelleConfig,
			resolve.ImportSpec{
				Lang: "proto",
				Imp:  imp,
			},
			"proto",
		)
		if len(results) == 0 {
			log.Printf("unable to resolve proto dependency: %s", imp)
		}
		for _, res := range results {
			targetSet[res.Label.Rel(fromLabel.Repo, fromLabel.Pkg).String()] = struct{}{}
		}
	}
	targets := make([]string, 0, len(targetSet))
	for target := range targetSet {
		targets = append(targets, target)
	}
	breakingRule.SetAttr("targets", targets)
}
