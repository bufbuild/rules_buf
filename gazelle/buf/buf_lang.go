package buf

import (
	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/repo"
	"github.com/bazelbuild/bazel-gazelle/resolve"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

const lang = "buf"

type bufRule interface {
	// Kind of the buf rule, Ex: buf_lint_test.
	Kind() string
	// KindInfo returns the KindInfo of this rule.
	KindInfo() rule.KindInfo
	// LoadInfo returns the LoadInfo for this rule
	LoadInfo() rule.LoadInfo
	// GenerateRules returns a list of rules that need be generated for each bazel package.
	GenerateRules(args language.GenerateArgs) language.GenerateResult
}

type resolver interface {
	Resolve(c *config.Config, ix *resolve.RuleIndex, rc *repo.RemoteCache, r *rule.Rule, imports interface{}, from label.Label)
}

type bufLang struct {
	rules   []bufRule
	ruleMap map[string]bufRule
}

func newBufLang() *bufLang {
	rules := []bufRule{
		newLintRule(),
		newBreakingRule(),
	}
	ruleMap := make(map[string]bufRule)
	for _, r := range rules {
		ruleMap[r.Kind()] = r
	}
	return &bufLang{
		rules:   rules,
		ruleMap: ruleMap,
	}
}

func (*bufLang) Name() string {
	return lang
}

func (l *bufLang) Kinds() map[string]rule.KindInfo {
	res := make(map[string]rule.KindInfo)
	for _, br := range l.rules {
		res[br.Kind()] = br.KindInfo()
	}
	return res
}

func (*bufLang) Imports(c *config.Config, r *rule.Rule, f *rule.File) []resolve.ImportSpec {
	return nil
}

func (*bufLang) Embeds(r *rule.Rule, from label.Label) []label.Label {
	return nil
}

func (l *bufLang) Resolve(c *config.Config, ix *resolve.RuleIndex, rc *repo.RemoteCache, r *rule.Rule, imports interface{}, from label.Label) {
	for _, br := range l.rules {
		resolver, ok := br.(resolver)
		if !ok {
			continue
		}
		resolver.Resolve(c, ix, rc, r, imports, from)
	}
}

func (l *bufLang) Loads() []rule.LoadInfo {
	loadInfoMap := map[string]rule.LoadInfo{}
	for _, r := range l.rules {
		temp := r.LoadInfo()
		li := loadInfoMap[temp.Name]
		li.Name = temp.Name
		li.Symbols = append(li.Symbols, temp.Symbols...)
		loadInfoMap[temp.Name] = li
	}
	loadInfos := make([]rule.LoadInfo, 0, len(loadInfoMap))
	for _, v := range loadInfoMap {
		loadInfos = append(loadInfos, v)
	}
	return loadInfos
}

func (l *bufLang) GenerateRules(args language.GenerateArgs) language.GenerateResult {
	agr := language.GenerateResult{}
	for _, r := range l.rules {
		res := r.GenerateRules(args)
		agr.Gen = append(agr.Gen, res.Gen...)
		agr.Imports = append(agr.Imports, res.Imports...)
		agr.Empty = append(agr.Empty, res.Empty...)
	}
	return agr
}

func (*bufLang) Fix(c *config.Config, f *rule.File) {}

// getRulesOfKind returns all the rules of a kind in a map with their names as keys
func getRulesOfKind(rules []*rule.Rule, kind string) map[string]*rule.Rule {
	kindRules := map[string]*rule.Rule{}
	for _, r := range rules {
		if r.Kind() != kind {
			continue
		}

		kindRules[r.Name()] = r
	}
	return kindRules
}
