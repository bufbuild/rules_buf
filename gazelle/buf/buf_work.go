package buf

// bufWork is a subset of the `buf.work.yaml` representation copied from bufbuild/buf
// 
// Must be kept in sync with: bufbuild/buf/private/buf/bufwork.ExternalConfigV1
type bufWork struct {
	Version     string   `yaml:"version,omitempty" json:"version,omitempty"`
	Directories []string `yaml:"directories,omitempty" json:"directories,omitempty"`
}
