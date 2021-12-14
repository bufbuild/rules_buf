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

type BreakingConfig struct {
	Use                    []string `json:"use,omitempty" yaml:"use,omitempty"`
	Except                 []string `json:"except,omitempty" yaml:"except,omitempty"`
	IgnoreUnstablePackages *bool    `json:"ignore_unstable_packages,omitempty" yaml:"ignore_unstable_packages,omitempty"`

	Ignore     []string            `json:"ignore,omitempty" yaml:"ignore,omitempty"`
	IgnoreOnly map[string][]string `json:"ignore_only,omitempty" yaml:"ignore_only,omitempty"`
}

type breakingRule struct {
}

func (breakingRule) Kind() string {
	return breakingRuleKind
}

func (breakingRule) KindInfo() rule.KindInfo {
	return rule.KindInfo{
		MatchAttrs: []string{"targets"},
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

func (br breakingRule) GenerateRules(args language.GenerateArgs) (res language.GenerateResult) {
	cfg := GetConfig(args.Config)
	// Skip if no target to check against
	if cfg.BreakingImageTarget == "" {
		return
	}

	// Breaking rules are applied to individual packages (package mode), module root is ignored
	if cfg.BreakingLimitToInputFiles {
		protoLibRules := getRulesOfKind(args.OtherGen, "proto_library")
		for _, plr := range protoLibRules {
			res.Gen = append(res.Gen, br.genRule(plr.Name(), cfg))
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

		return
	}

	// In module mode delete all
	if args.File != nil {
		breakingRules := getRulesOfKind(args.File.Rules, breakingRuleKind)
		for _, r := range breakingRules {
			res.Empty = append(res.Empty, r)
		}
	}

	if !cfg.ModuleRoot {
		return
	}

	// Module mode and is module root

	genRule := br.genRule("buf", cfg)
	genRule.SetAttr("targets", []string{})

	res.Gen = append(res.Gen, genRule)
	res.Imports = append(res.Imports, getProtoLibImports(args))

	return
}

func (breakingRule) Resolve(c *config.Config, ix *resolve.RuleIndex, _ *repo.RemoteCache, r *rule.Rule, importsRaw interface{}, from label.Label) {
	if r.Kind() != breakingRuleKind {
		return
	}

	imports, ok := importsRaw.([]string)
	if !ok {
		return
	}

	targetMap := map[string]bool{}
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
			targetMap[res.Label.Rel(from.Repo, from.Pkg).String()] = true
		}
	}

	targets := make([]string, 0, len(targetMap))
	for t := range targetMap {
		targets = append(targets, t)
	}
	r.SetAttr("targets", targets)
}

func (breakingRule) genRule(name string, c *Config) *rule.Rule {
	r := rule.NewRule(breakingRuleKind, fmt.Sprintf("%s_breaking", name))

	r.SetAttr("targets", []string{fmt.Sprintf(":%s", name)})
	r.SetAttr("against", c.BreakingImageTarget)

	if !c.BreakingExcludeImports {
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

	return r
}

func getProtoLibImports(args language.GenerateArgs) []string {
	cfg := GetConfig(args.Config)

	var targets []string
	fs.WalkDir(os.DirFS(args.Dir), ".", func(p string, d fs.DirEntry, err error) error {
		if d.IsDir() {
			return nil
		}

		if !strings.HasSuffix(d.Name(), ".proto") {
			return nil
		}

		if cfg.Module != nil && cfg.Module.Build != nil {
			for _, exclude := range cfg.Module.Build.Excludes {
				if strings.HasPrefix(p, exclude) {
					return nil
				}
			}
		}

		targets = append(targets, p)
		return nil
	})

	return targets
}
