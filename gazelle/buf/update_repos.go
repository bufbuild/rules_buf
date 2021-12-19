package buf

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/rule"
	"gopkg.in/yaml.v3"
)

const repoRule = "buf_module"

type BufWorkspace struct {
	Version     string   `json:"version,omitempty" yaml:"version,omitempty"`
	Directories []string `json:"directories,omitempty" yaml:"directories,omitempty"`
}

type BufLock struct {
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
	file := filepath.Base(path)
	switch file {
	case "buf.yaml", "buf.mod", "buf.lock", "buf.work.yaml":
		return true
	}

	return false
}

func (*bufLang) ImportRepos(args language.ImportReposArgs) language.ImportReposResult {
	file := filepath.Base(args.Path)

	var res language.ImportReposResult
	switch file {
	case "buf.yaml", "buf.mod", "buf.lock":
		res = importSingleRepo(args)
	case "buf.work.yaml":
		res = importWorkspaceRepo(args)
	default:
		panic("should never panic!")
	}

	if res.Error != nil {
		return res
	}

	if args.Prune {
		genNamesSet := make(map[string]bool)
		for _, r := range res.Gen {
			genNamesSet[r.Name()] = true
		}
		for _, r := range args.Config.Repos {
			if name := r.Name(); r.Kind() == repoRule && !genNamesSet[name] {
				res.Empty = append(res.Empty, rule.NewRule(repoRule, name))
			}
		}
	}

	return res
}

func importSingleRepo(args language.ImportReposArgs) language.ImportReposResult {
	dir := filepath.Dir(args.Path)

	mod, err := loadDefaultConfig(dir)
	if err != nil {
		return language.ImportReposResult{
			Error: err,
		}
	}

	if mod.Name == "" {
		return language.ImportReposResult{
			Error: fmt.Errorf("buf module is missing the name attibute. It is required for gazelle"),
		}
	}

	var lock BufLock
	if err := readYamlFile(filepath.Join(dir, "buf.lock"), &lock); err != nil {
		if errors.Is(err, os.ErrNotExist) {
			err = fmt.Errorf("unable to locate buf.lock, please run buf mod update, err: %v", err)
		}

		return language.ImportReposResult{
			Error: err,
		}
	}

	r := getRepoRuleFromLockFile(&lock, getBazelTargetFromModule(mod.Name))
	return language.ImportReposResult{
		Gen: []*rule.Rule{r},
	}
}

func importWorkspaceRepo(args language.ImportReposArgs) language.ImportReposResult {
	var work BufWorkspace
	if err := readYamlFile(args.Path, &work); err != nil {
		return language.ImportReposResult{
			Error: err,
		}
	}

	gen := make([]*rule.Rule, 0, len(work.Directories))
	for _, dir := range work.Directories {
		dirArgs := args
		dirArgs.Path = filepath.Join(filepath.Dir(args.Path), dir, "buf.yaml")

		res := importSingleRepo(dirArgs)
		if res.Error != nil {
			return language.ImportReposResult{Error: res.Error}
		}

		gen = append(gen, res.Gen...)
	}

	return language.ImportReposResult{Gen: gen}
}

func getRepoRuleFromLockFile(lock *BufLock, name string) *rule.Rule {
	deps := make([]string, 0, len(lock.Deps))
	for _, dep := range lock.Deps {
		deps = append(deps, fmt.Sprintf("%s/%s/%s:%s", dep.Remote, dep.Owner, dep.Repository, dep.Commit))
	}

	r := rule.NewRule(repoRule, name)
	r.SetAttr("deps", deps)

	return r
}

func readYamlFile(path string, v interface{}) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	return yaml.Unmarshal(data, v)
}

// convert module name to bazel target
// Ex: buf.build/acme/petapis -> build_buf_acme_petapis
func getBazelTargetFromModule(name string) string {
	nameSegs := strings.Split(name, "/")
	remSegs := strings.Split(nameSegs[0], ".")

	remote := remSegs[len(remSegs)-1]
	for i := len(remSegs) - 2; i >= 0; i-- {
		remote += "_" + remSegs[i]
	}

	return remote + "_" + nameSegs[1] + "_" + nameSegs[2]
}
