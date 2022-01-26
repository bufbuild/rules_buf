package buf

import (
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/language/proto"
	"github.com/bazelbuild/bazel-gazelle/resolve"
	"github.com/bazelbuild/bazel-gazelle/rule"
)

var _ resolve.CrossResolver = (*bufLang)(nil)

func (*bufLang) CrossResolve(c *config.Config, ix *resolve.RuleIndex, imp resolve.ImportSpec, lang string) []resolve.FindResult {
	if lang != "proto" || imp.Lang != "proto" {
		return nil
	}

	// TODO: Rather than repo root load from nearest buf.yaml
	var repoRule *rule.Rule
	for _, repo := range c.Repos {
		if repo.Kind() != repoRuleKind {
			continue
		}

		repoRule = repo
	}

	if repoRule == nil {
		return nil
	}

	allFiles, err := bufLsAll(c.RepoRoot)
	if err != nil {
		fmt.Println("error running buf ls-files", err)
		return nil
	}

	inputFiles, err := bufLs(c.RepoRoot)
	if err != nil {
		fmt.Println("error running buf ls-files", err)
		return nil
	}

	importFiles := difference(allFiles, inputFiles)
	for _, impf := range importFiles {
		if impf != imp.Imp {
			continue
		}

		rule := path.Dir(imp.Imp)
		return []resolve.FindResult{
			{
				Label: label.New(repoRule.Name(), rule, proto.RuleName(rule)),
			},
		}
	}

	return []resolve.FindResult{}
}

func difference(a, b []string) []string {
	mb := make(map[string]struct{}, len(b))
	for _, x := range b {
		mb[x] = struct{}{}
	}
	var diff []string
	for _, x := range a {
		if _, found := mb[x]; !found {
			diff = append(diff, x)
		}
	}
	return diff
}

func findBuf() string {
	// TODO: change to get from within bazel, use the `bazel` package in `rules_go`
	return "buf"
}

var bufLs = func(dir string, args ...string) ([]string, error) {
	bazelDirs, err := fs.Glob(os.DirFS(dir), "bazel-*")
	if err != nil {
		fmt.Println("unable to traverse filesystem", err)
	}

	module, _, err := loadDefaultConfig(dir)
	if err != nil {
		return nil, err
	}

	if module != nil && module.Build != nil {
		bazelDirs = append(bazelDirs, module.Build.Excludes...)
	}

	bazelDirsJson, _ := json.Marshal(bazelDirs)
	config := fmt.Sprintf(`{"version":"v1","build": {"excludes": %s}}`, bazelDirsJson)

	out, err := runBufCommand(dir, "ls-files", "--as-import-paths", "--config", (config))
	if err != nil {
		return nil, err
	}

	return parseLsOut(out), nil
}

var bufLsAll = func(dir string) ([]string, error) {
	return bufLs(dir, "--include-imports")
}

func parseLsOut(out []byte) []string {
	scanner := bufio.NewScanner(bytes.NewReader(out))
	var imports []string
	for scanner.Scan() {
		imports = append(imports, scanner.Text())
	}

	return imports
}

func runBufCommand(dir string, args ...string) ([]byte, error) {
	bufCli := findBuf()

	var stderr bytes.Buffer
	cmd := exec.Command(bufCli, args...)
	cmd.Dir = dir
	cmd.Stderr = &stderr

	out, err := cmd.Output()
	if err != nil {
		var errStr string
		var xerr *exec.ExitError
		if errors.As(err, &xerr) {
			errStr = strings.TrimSpace(stderr.String())
		} else {
			errStr = err.Error()
		}
		return nil, fmt.Errorf("running '%s %s': %s", cmd.Path, strings.Join(cmd.Args, " "), errStr)
	}
	return out, nil
}
