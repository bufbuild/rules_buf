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
	"github.com/bazelbuild/bazel-gazelle/language"
	"github.com/bazelbuild/bazel-gazelle/rule"
	"gopkg.in/yaml.v3"
)

type Config struct {
	// buf.yaml
	Module *BufModule

	// Global Flags
	LogLevel    string
	LogFormat   string
	ErrorFormat string

	BreakingImageTarget       string
	BreakingExcludeImports    bool
	BreakingLimitToInputFiles bool

	ModuleRoot bool
	ConfigFile label.Label
}

type BufModule struct {
	Version string       `json:"version,omitempty" yaml:"version,omitempty"`
	Name    string       `json:"name,omitempty" yaml:"name,omitempty"`
	Deps    []string     `json:"deps,omitempty" yaml:"deps,omitempty"`
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
		"buf_log_level",
		"buf_log_format",
		"buf_error_format",

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
		// Global Options
		case "buf_log_level":
			cfg.LogLevel = d.Value
		case "buf_log_format":
			cfg.LogFormat = d.Value
		case "buf_error_format":
			cfg.ErrorFormat = d.Value

		// Breaking config
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

const configRuleKind = "buf_config"

type configRule struct {
}

func (configRule) Kind() string {
	return configRuleKind
}

func (configRule) KindInfo() rule.KindInfo {
	return rule.KindInfo{
		MatchAttrs: []string{"config"},
	}
}

func (configRule) LoadInfo() rule.LoadInfo {
	return rule.LoadInfo{
		Name:    "@rules_buf//buf:defs.bzl",
		Symbols: []string{configRuleKind},
	}
}

func (configRule) GenerateRules(args language.GenerateArgs) (res language.GenerateResult) {
	cfg := GetConfig(args.Config)

	fmt.Println(args.Rel, cfg.ModuleRoot)

	var configRule *rule.Rule
	if cfg.ModuleRoot {
		configRule := rule.NewRule(configRuleKind, "")
		configRule.SetAttr("config", cfg.ConfigFile.Rel("", args.Rel).Name)
		res.Gen = append(res.Gen, configRule)
		res.Imports = append(res.Imports, struct{}{})
	}

	if args.File != nil {
		configRules := getRulesOfKind(args.File.Rules, configRuleKind)
		for _, r := range configRules {
			if configRule != nil && r.AttrString("config") == configRule.AttrString("config") {
				continue
			}

			res.Empty = append(res.Empty, r)
		}
	}

	return
}
