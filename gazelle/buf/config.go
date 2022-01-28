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

type Config struct {
	// buf.yaml
	Module *BufModule

	BreakingImageTarget       string
	BreakingExcludeImports    bool
	BreakingLimitToInputFiles bool

	ModuleRoot bool
	ConfigFile label.Label
}

type BufModule struct {
	Version string       `json:"version,omitempty" yaml:"version,omitempty"`
	Name    string       `json:"name,omitempty" yaml:"name,omitempty"`
	Build   *BuildConfig `json:"build,omitempty" yaml:"build,omitempty"`
}

type BuildConfig struct {
	Excludes []string `json:"excludes,omitempty" yaml:"excludes,omitempty"`
}

func (*bufLang) RegisterFlags(flagSet *flag.FlagSet, cmd string, c *config.Config) {
	SetConfig(c, &Config{
		BreakingExcludeImports:    true,
		BreakingLimitToInputFiles: false,
	})
}

func (*bufLang) CheckFlags(flagSet *flag.FlagSet, c *config.Config) error { return nil }

func (*bufLang) KnownDirectives() []string {
	return []string{
		"buf_breaking_against",
		"buf_breaking_exclude_imports",
		"buf_breaking_limit_to_input_files",
	}
}

func (*bufLang) Configure(c *config.Config, rel string, f *rule.File) {
	cfg := loadConfig(c, rel, f)
	SetConfig(c, cfg)
}

func loadConfig(c *config.Config, rel string, f *rule.File) *Config {
	cfg := *GetConfig(c)

	cfg.ModuleRoot = false
	bc, file, err := loadDefaultConfig(filepath.Join(c.RepoRoot, rel))
	if err != nil {
		log.Println("error trying to load default config", err)
	}
	if bc != nil {
		cfg.Module = bc
		cfg.ModuleRoot = true
		cfg.ConfigFile = label.New("", rel, file)
	}

	if f == nil {
		return &cfg
	}

	for _, d := range f.Directives {
		switch d.Key {
		case "buf_breaking_against":
			cfg.BreakingImageTarget = d.Value
		case "buf_breaking_exclude_imports":
			value, err := strconv.ParseBool(strings.TrimSpace(d.Value))
			if err != nil {
				log.Fatalf("buf_breaking_exclude_imports directive should be a boolean got: %s", d.Value)
			}
			cfg.BreakingExcludeImports = value
		case "buf_breaking_limit_to_input_files":
			value, err := strconv.ParseBool(strings.TrimSpace(d.Value))
			if err != nil {
				log.Fatalf("buf_breaking_limit_to_input_files directive should be a boolean got: %s", d.Value)
			}
			cfg.BreakingLimitToInputFiles = value
		}
	}

	return &cfg
}

func readConfig(file string) (*BufModule, error) {
	data, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}

	var cfg BufModule
	return &cfg, parseJsonOrYaml(data, &cfg)
}

func GetConfig(c *config.Config) *Config {
	cfg := c.Exts[lang]
	if cfg != nil {
		return cfg.(*Config)
	}

	return nil
}

func SetConfig(c *config.Config, cfg *Config) {
	c.Exts[lang] = cfg
}

func parseJsonOrYaml(data []byte, v interface{}) error {
	if err := yaml.Unmarshal(data, v); err != nil {
		if err := json.Unmarshal(data, v); err != nil {
			return err
		}
	}

	return nil
}

func loadDefaultConfig(wd string) (*BufModule, string, error) {
	for _, file := range []string{
		"buf.yaml",
		"buf.mod",
	} {
		bc, err := readConfig(filepath.Join(wd, file))
		if errors.Is(err, fs.ErrNotExist) {
			continue
		}
		if err != nil {
			return nil, "", fmt.Errorf("buf: unable to parse buf config file at %s, err: %w", file, err)
		}

		return bc, file, nil
	}

	return nil, "", nil
}

func isWithinExcludes(cfg *Config, path string) bool {
	if cfg.Module != nil && cfg.Module.Build != nil {
		for _, exclude := range cfg.Module.Build.Excludes {
			if strings.Contains(path, exclude) {
				return true
			}
		}
	}

	return false
}
