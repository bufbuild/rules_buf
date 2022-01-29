package buf

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/repo"
	"github.com/bazelbuild/bazel-gazelle/resolve"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

const breakingRuleKind = "buf_breaking_test"

type breakingRule struct{}

func newBreakingRule() breakingRule {
	return breakingRule{}
}

func (breakingRule) Kind() string {
	return breakingRuleKind
}

func (breakingRule) KindInfo() rule.KindInfo {
	return rule.KindInfo{
		MatchAttrs: []string{"targets"},
		MergeableAttrs: map[string]bool{
			"against":              true,
			"exclude_imports":      true,
			"limit_to_input_files": true,
		},
		ResolveAttrs: map[string]bool{
			"targets": true,
		},
	}
}

func (breakingRule) LoadInfo() rule.LoadInfo {
	return rule.LoadInfo{
		Name:    "@rules_buf//buf:defs.bzl",
		Symbols: []string{breakingRuleKind},
	}
}

func (b breakingRule) GenerateRules(args language.GenerateArgs) language.GenerateResult {
	res := language.GenerateResult{}
	cfg := GetConfigForGazelleConfig(args.Config)
	// Skip if no target to check against
	if cfg.BreakingImageTarget == "" {
		return res
	}
	// Breaking rules are applied to individual packages (package mode), module root is ignored
	if cfg.BreakingLimitToInputFiles {
		// Skip if we are in any of the excludes directories
		if isWithinExcludes(cfg, args.Rel) {
			return res
		}
		protoLibRules := getRulesOfKind(args.OtherGen, "proto_library")
		for _, plr := range protoLibRules {
			res.Gen = append(res.Gen, b.genRule(plr.Name(), cfg))
			res.Imports = append(res.Imports, struct{}{})
		}
		if args.File != nil {
			breakingRules := getRulesOfKind(args.File.Rules, breakingRuleKind)
			for _, r := range breakingRules {
				targets := r.AttrStrings("targets")
				// Allow if generated package mode and target belongs to current package
				if len(targets) == 1 && protoLibRules[targets[0]] != nil {
					continue
				}

				res.Empty = append(res.Empty, r)
			}
		}
		return res
	}
	// In module mode delete all
	if args.File != nil {
		breakingRules := getRulesOfKind(args.File.Rules, breakingRuleKind)
		for _, r := range breakingRules {
			res.Empty = append(res.Empty, r)
		}
	}
	if !cfg.ModuleRoot {
		return res
	}
	// Module mode and is module root
	genRule := b.genRule("buf", cfg)
	genRule.SetAttr("targets", []string{})
	res.Gen = []*rule.Rule{
		genRule,
	}
	res.Imports = []interface{}{
		getProtoLibImports(args),
	}
	return res
}

func (breakingRule) Resolve(c *config.Config, ix *resolve.RuleIndex, _ *repo.RemoteCache, r *rule.Rule, importsRaw interface{}, from label.Label) {
	if r.Kind() != breakingRuleKind {
		return
	}
	// Check if Managed mode. importsRaw will be `struct{}{}` for package mode
	imports, ok := importsRaw.([]string)
	if !ok {
		return
	}
	targetSet := make(map[string]struct{})
	for _, imp := range imports {
		results := ix.FindRulesByImportWithConfig(
			c,
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
			targetSet[res.Label.Rel(from.Repo, from.Pkg).String()] = struct{}{}
		}
	}
	targets := make([]string, 0, len(targetSet))
	for t := range targetSet {
		targets = append(targets, t)
	}
	r.SetAttr("targets", targets)
}

func (breakingRule) genRule(name string, c *Config) *rule.Rule {
	r := rule.NewRule(breakingRuleKind, fmt.Sprintf("%s_breaking", name))
	r.SetAttr("targets", []string{fmt.Sprintf(":%s", name)})
	r.SetAttr("against", c.BreakingImageTarget)
	// Set optional attributes
	if !c.BreakingExcludeImports {
		r.SetAttr("exclude_imports", false)
	}
	if !c.BreakingLimitToInputFiles {
		r.SetAttr("limit_to_input_files", false)
	}
	if c.Module != nil {
		r.SetAttr("config", c.ConfigFile.String())
	}
	return r
}

func getProtoLibImports(args language.GenerateArgs) []string {
	cfg := GetConfigForGazelleConfig(args.Config)
	var targets []string
	fs.WalkDir(os.DirFS(args.Dir), ".", func(p string, d fs.DirEntry, err error) error {
		if d.IsDir() {
			return nil
		}
		if !strings.HasSuffix(d.Name(), ".proto") {
			return nil
		}
		// Skip if we are in any of the excludes directories
		if isWithinExcludes(cfg, p) {
			return nil
		}
		targets = append(targets, p)
		return nil
	})
	return targets
}
