package buf

import (
	"errors"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/rule"
	"gopkg.in/yaml.v3"
)

type BufLockFile struct {
	Version string               `json:"version,omitempty" yaml:"version,omitempty"`
	Deps    []*BufLockDependency `json:"deps,omitempty" yaml:"deps,omitempty"`
}

type BufLockDependency struct {
	Remote     string `json:"remote,omitempty" yaml:"remote,omitempty"`
	Owner      string `json:"owner,omitempty" yaml:"owner,omitempty"`
	Repository string `json:"repository,omitempty" yaml:"repository,omitempty"`
	Commit     string `json:"commit,omitempty" yaml:"commit,omitempty"`
	Digest     string `json:"digest,omitempty" yaml:"digest,omitempty"`
}

func (*bufLang) CanImport(path string) bool {
	if _, err := readBufLock(path); err != nil {
		// Log if not a parsing error
		tp := &yaml.TypeError{}
		if !errors.As(err, &tp) {
			log.Println(err)
		}
		return false
	}

	return true
}

func (*bufLang) ImportRepos(args language.ImportReposArgs) language.ImportReposResult {
	lockFile, _ := readBufLock(args.Path)

	gen := getRepoRulesFromLockFile(lockFile)

	var empty []*rule.Rule
	if args.Prune {
		genNamesSet := make(map[string]bool)
		for _, r := range gen {
			genNamesSet[r.Name()] = true
		}
		for _, r := range args.Config.Repos {
			if name := r.Name(); r.Kind() == "buf_repository" && !genNamesSet[name] {
				empty = append(empty, rule.NewRule("buf_repository", name))
			}
		}
	}
	return language.ImportReposResult{Gen: gen, Empty: empty}
}

func getRepoRulesFromLockFile(lockFile *BufLockFile) []*rule.Rule {
	gen := make([]*rule.Rule, 0, len(lockFile.Deps))
	for _, dep := range lockFile.Deps {
		r := rule.NewRule(
			"buf_repository",
			strings.Join(append(reverse(strings.Split(dep.Remote, ".")), dep.Owner, dep.Repository), "_"),
		)
		r.SetAttr("commit", dep.Commit)
		r.SetAttr("digest", dep.Digest)
		r.SetAttr("module", fmt.Sprintf("%s/%s/%s", dep.Remote, dep.Owner, dep.Repository))
		gen = append(gen, r)
	}
	return gen
}

func readBufLock(path string) (*BufLockFile, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var lockFile BufLockFile
	if err := yaml.Unmarshal(data, &lockFile); err != nil {
		return nil, err
	}

	return &lockFile, nil
}

func reverse(s []string) []string {
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
	return s
}
