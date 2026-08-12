// A generated module for AquaRegistry functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"context"
)

type AquaRegistry struct{}

// Scaffold a package
func (m *AquaRegistry) Scaffold(ctx context.Context, pkg string) (*Directory, error) {
	return dag.CurrentModule().Source().Directory("docker").DockerBuild().
		WithExec([]string{"mkdir", "-p", "dist"}).
		WithExec([]string{"aqua", "gr", "--out-testdata", "dist/pkg.yaml", pkg}, ContainerWithExecOpts{
			RedirectStdout: "dist/registry.yaml",
		}).Directory("dist"), nil
}

// Test a package
func (m *AquaRegistry) Test(ctx context.Context, pkg *Directory) (*Container, error) {
	return dag.CurrentModule().Source().Directory("docker").DockerBuild().
		WithFile("/workspace/pkg.yaml", pkg.File("pkg.yaml")).
		WithFile("/workspace/registry.yaml", pkg.File("registry.yaml")).
		WithWorkdir("/workspace").
		WithExec([]string{"aqua", "i"}), nil
}

// Generate registry.yaml
func (m *AquaRegistry) Generate(
	ctx context.Context,
	dir *Directory,
) (*File, error) {
	return dag.CurrentModule().Source().Directory("docker").DockerBuild().
		WithDirectory("/out", dir).
		WithWorkdir("/out").
		WithExec([]string{"aqua", "policy", "allow"}).
		WithExec([]string{"aqua", "i", "-l"}).
		WithExec([]string{"aqua-registry", "gr"}).File("registry.yaml"), nil
}
