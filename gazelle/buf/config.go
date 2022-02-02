package buf

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/config"
	"github.com/bazelbuild/bazel-gazelle/label"
	"github.com/bazelbuild/bazel-gazelle/rule"
	"gopkg.in/yaml.v3"
)

var defaultBufConfigFiles = []string{
	"buf.yaml",
	"buf.mod",
}

func (*bufLang) RegisterFlags(flagSet *flag.FlagSet, cmd string, gazelleConfig *config.Config) {
	SetConfigForGazelleConfig(gazelleConfig, &Config{
		BreakingExcludeImports: true,
		BreakingMode:           BreakingModeModule,
	})
}

func (*bufLang) CheckFlags(flagSet *flag.FlagSet, gazelleConfig *config.Config) error { return nil }

func (*bufLang) KnownDirectives() []string {
	return []string{
		"buf_breaking_mode",
		"buf_breaking_against",
		"buf_breaking_exclude_imports",
	}
}

func (*bufLang) Configure(gazelleConfig *config.Config, relativePath string, file *rule.File) {
	cfg := loadConfig(gazelleConfig, relativePath, file)
	SetConfigForGazelleConfig(gazelleConfig, cfg)
}

func loadConfig(gazelleConfig *config.Config, packageRelativePath string, file *rule.File) *Config {
	// Config is inherited from parent directory if we modify without making a copy
	// it will be polluted when traversing sibling directories.
	//
	// https://github.com/bazelbuild/bazel-gazelle/blob/master/Design.rst#configuration
	config := *GetConfigForGazelleConfig(gazelleConfig)
	config.ModuleRoot = false
	bufModule, bufConfigFile, err := loadDefaultBufModule(
		filepath.Join(
			gazelleConfig.RepoRoot,
			packageRelativePath,
		),
	)
	if err != nil {
		log.Print("error trying to load default config", err)
	}
	if bufModule != nil {
		config.Module = bufModule
		config.ModuleRoot = true
		config.BufConfigFile = label.New("", packageRelativePath, bufConfigFile)
	}
	if file == nil {
		return &config
	}
	for _, d := range file.Directives {
		switch d.Key {
		case "buf_breaking_against":
			config.BreakingImageTarget = d.Value
		case "buf_breaking_exclude_imports":
			value, err := strconv.ParseBool(strings.TrimSpace(d.Value))
			if err != nil {
				log.Printf("buf_breaking_exclude_imports directive should be a boolean got: %s", d.Value)
			}
			config.BreakingExcludeImports = value
		case "buf_breaking_mode":
			breakingMode, err := ParseBreakingMode(d.Value)
			if err != nil {
				log.Printf("error parsing buf_breaking_mode: %v", err)
			}
			config.BreakingMode = breakingMode
		}
	}
	return &config
}

func readConfig(file string) (*BufModule, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}
	var bufModule BufModule
	return &bufModule, parseJsonOrYaml(data, &bufModule)
}

func parseJsonOrYaml(data []byte, v interface{}) error {
	if err := json.Unmarshal(data, v); err != nil {
		if err := yaml.Unmarshal(data, v); err != nil {
			return err
		}
	}
	return nil
}

func loadDefaultBufModule(workingDirectory string) (*BufModule, string, error) {
	for _, bufConfigFile := range defaultBufConfigFiles {
		bufModule, err := readConfig(filepath.Join(workingDirectory, bufConfigFile))
		if errors.Is(err, fs.ErrNotExist) {
			continue
		}
		if err != nil {
			return nil, "", fmt.Errorf("buf: unable to parse buf config file at %s, err: %w", bufConfigFile, err)
		}

		return bufModule, bufConfigFile, nil
	}
	return nil, "", nil
}

func isWithinExcludes(config *Config, path string) bool {
	if config.Module != nil && config.Module.Build != nil {
		for _, exclude := range config.Module.Build.Excludes {
			if strings.Contains(path, exclude) {
				return true
			}
		}
	}
	return false
}
