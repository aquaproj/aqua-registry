package newpkg

import (
	"strings"
	"testing"
)

func Test_getDesc(t *testing.T) {
	t.Parallel()
	data := []struct {
		name  string
		yaml  string
		isErr bool
		exp   string
	}{
		{
			name: "normal",
			yaml: `packages:
  - type: github_release
    repo_owner: cli
    repo_name: cli
    description: GitHub’s official command line tool
    search_words:
      - github
`,
			exp: "GitHub’s official command line tool",
		},
		{
			name: "no description",
			yaml: `packages:
  - type: github_release
    repo_owner: cli
    repo_name: cli
    search_words:
      - github
`,
		},
	}
	for _, d := range data {
		d := d
		t.Run(d.name, func(t *testing.T) {
			t.Parallel()
			desc, err := getDesc(strings.NewReader(d.yaml))
			if err != nil {
				if d.isErr {
					return
				}
				t.Fatal(err)
			}
			if d.isErr {
				t.Fatal("error should be returned")
			}
			if desc != d.exp {
				t.Fatalf("wanted %s, got %s", d.exp, desc)
			}
		})
	}
}

func Test_getBody(t *testing.T) {
	t.Parallel()
	data := []struct {
		name    string
		pkgName string
		desc    string
		exp     string
	}{
		{
			name:    "normal",
			pkgName: "cli/cli",
			desc:    "GitHub’s official command line tool",
			exp:     "[cli/cli](https://github.com/cli/cli): GitHub’s official command line tool",
		},
		{
			name:    "no link",
			pkgName: "foo",
			desc:    "GitHub’s official command line tool",
			exp:     "foo: GitHub’s official command line tool",
		},
	}
	for _, d := range data {
		d := d
		t.Run(d.name, func(t *testing.T) {
			t.Parallel()
			body := getBody(d.pkgName, d.desc)
			if body != d.exp {
				t.Fatalf("wanted %s, got %s", d.exp, body)
			}
		})
	}
}
