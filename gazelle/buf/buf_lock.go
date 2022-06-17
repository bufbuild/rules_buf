package buf

// bufLock is subset of the `buf.lock` representation copied from bufbuild/buf
// 
// Must be kept in sync with: bufbuild/buf/private/bufpkg/buflock.ExternalConfigV1
type bufLock struct {
	Version string `yaml:"version,omitempty" json:"version,omitempty"`
	Deps    []struct {
		Remote     string `yaml:"remote,omitempty" json:"remote,omitempty"`
		Owner      string `yaml:"owner,omitempty" json:"owner,omitempty"`
		Repository string `yaml:"repository,omitempty" json:"repository,omitempty"`
		Commit     string `yaml:"commit,omitempty" json:"commit,omitempty"`
	} `yaml:"deps,omitempty" json:"deps,omitempty"`
}
