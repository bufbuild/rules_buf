package buf

import (
	"fmt"
	"strings"

	"github.com/bazelbuild/bazel-gazelle/rule"
)

const lintRuleKind = "buf_lint_test"

type lintRule struct {
}

func (lintRule) Kind() string {
	return lintRuleKind
}

func (lintRule) KindInfo() rule.KindInfo {
	return rule.KindInfo{
		MatchAttrs: []string{"target"},
	}
}

func (lintRule) LoadInfo() rule.LoadInfo {
	return rule.LoadInfo{
		Name:    "@rules_buf//buf:defs.bzl",
		Symbols: []string{lintRuleKind},
	}
}

// GenRule returns a list of rules that need be generated for each `proto_library` rule.
func (lintRule) GenRule(pr *rule.Rule, c *Config) (*rule.Rule, interface{}) {
	r := rule.NewRule("buf_lint_test", fmt.Sprintf("%s_lint", pr.Name()))

	r.SetAttr("target", fmt.Sprintf(":%s", pr.Name()))

	if c.Module != nil && c.Module.Lint != nil {
		lint := c.Module.Lint
		if len(lint.Use) > 0 {
			r.SetAttr("use_rules", lint.Use)
		}

		if len(lint.Except) > 0 {
			r.SetAttr("except_rules", lint.Except)
		}

		if lint.ServiceSuffix != nil {
			r.SetAttr("service_suffix", *lint.ServiceSuffix)
		}

		if lint.AllowCommentIgnores != nil {
			r.SetAttr("allow_comment_ignores", *lint.AllowCommentIgnores)
		}

		if lint.EnumZeroValueSuffix != nil {
			r.SetAttr("enum_zero_value_suffix", *lint.EnumZeroValueSuffix)
		}

		if lint.RpcAllowSameRequestResponse != nil {
			r.SetAttr("rpc_allow_same_request_response", *lint.RpcAllowSameRequestResponse)
		}

		if lint.RpcAllowGoogleProtobufEmptyRequests != nil {
			r.SetAttr("rpc_allow_google_protobuf_empty_requests", *lint.RpcAllowGoogleProtobufEmptyRequests)
		}

		if lint.RpcAllowGoogleProtobufEmptyResponses != nil {
			r.SetAttr("rpc_allow_google_protobuf_empty_responses", *lint.RpcAllowGoogleProtobufEmptyResponses)
		}
	}

	return r, struct{}{}
}

// ShouldRemoveRule determines if this rule should be removed from the file. Typically rules generated in the previous run.
func (lintRule) ShouldRemoveRule(r *rule.Rule, protoRules map[string]*rule.Rule) bool {
	target := strings.TrimPrefix(r.AttrString("target"), ":")
	return protoRules[target] == nil
}
