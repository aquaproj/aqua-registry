package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/aquaproj/aqua-registry/internal/api"
)

func main() {
	if err := core(); err != nil {
		log.Fatal(err)
	}
}

const dirPermission os.FileMode = 0o775

func core() error {
	ctx := context.Background()
	if len(os.Args) != 2 { //nolint:gomnd
		return errors.New(`usage: $ go run ./cmd/scaffold <pkgname>
e.g. $ go run ./cmd/scaffold cli/cli`)
	}
	pkgName := os.Args[1]
	pkgDir := filepath.Join(append([]string{"pkgs"}, strings.Split(pkgName, "/")...)...)
	pkgFile := filepath.Join(pkgDir, "pkg.yaml")
	rgFile := filepath.Join(pkgDir, "registry.yaml")
	if err := os.MkdirAll(pkgDir, dirPermission); err != nil {
		return fmt.Errorf("create directories: %w", err)
	}
	if err := aquaGR(ctx, pkgName, rgFile); err != nil {
		return err
	}
	fmt.Fprintln(os.Stderr, "Update registry.yaml")
	if err := api.GenerateRegistry(); err != nil {
		return fmt.Errorf("update registry.yaml: %w", err)
	}
	if err := createAquaYAML(); err != nil {
		return err
	}
	if err := aquaG(ctx, pkgName); err != nil {
		return err
	}
	if err := createPkgFile(ctx, pkgName, pkgFile); err != nil {
		return err
	}
	if err := aquaI(ctx); err != nil {
		return err
	}
	return nil
}

func aquaGR(ctx context.Context, pkgName, rgFilePath string) error {
	outFile, err := os.Create(rgFilePath)
	if err != nil {
		return fmt.Errorf("create a file %s: %w", rgFilePath, err)
	}
	defer outFile.Close()
	fmt.Fprintf(os.Stderr, "+ aqua gr %s\n", pkgName)
	cmd := exec.CommandContext(ctx, "aqua", "gr", pkgName)
	cmd.Stdout = outFile
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("execute a command: %w", err)
	}
	return nil
}

func createAquaYAML() error {
	if _, err := os.Stat("aqua.yaml"); err == nil {
		return nil
	}
	outFile, err := os.Create("aqua.yaml")
	if err != nil {
		return fmt.Errorf("create aqua.yaml: %w", err)
	}
	defer outFile.Close()
	srcFile, err := os.Open("aqua.yaml.tmpl")
	if err != nil {
		return fmt.Errorf("open aqua.yaml.tmpl: %w", err)
	}
	defer srcFile.Close()
	if _, err := io.Copy(outFile, srcFile); err != nil {
		return fmt.Errorf("copy aqua.yaml.tmpl to aqua.yaml: %w", err)
	}
	return nil
}

func aquaG(ctx context.Context, pkgName string) error {
	fmt.Fprintf(os.Stderr, "+ aqua g -i %s\n", pkgName)
	cmd := exec.CommandContext(ctx, "aqua", "g", "-i", pkgName)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("execute a command: %w", err)
	}
	return nil
}

func aquaI(ctx context.Context) error {
	fmt.Fprintln(os.Stderr, "+ aqua i")
	cmd := exec.CommandContext(ctx, "aqua", "i")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("execute a command: aqua i: %w", err)
	}
	return nil
}

func createPkgFile(ctx context.Context, pkgName, pkgFilePath string) error {
	outFile, err := os.Create(pkgFilePath)
	if err != nil {
		return fmt.Errorf("create a file %s: %w", pkgFilePath, err)
	}
	defer outFile.Close()
	if _, err := outFile.WriteString("packages:\n"); err != nil {
		return fmt.Errorf("write a string to file %s: %w", pkgFilePath, err)
	}
	buf := &bytes.Buffer{}
	fmt.Fprintf(os.Stderr, "+ aqua g %s\n", pkgName)
	cmd := exec.CommandContext(ctx, "aqua", "g", pkgName)
	cmd.Stdout = buf
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("execute a command: aqua g %s: %w", pkgName, err)
	}
	txt := ""
	for _, line := range strings.Split(strings.TrimSpace(buf.String()), "\n") {
		txt += fmt.Sprintf("  %s\n", line)
	}
	if _, err := outFile.WriteString(txt); err != nil {
		return fmt.Errorf("write a string to file %s: %w", pkgFilePath, err)
	}
	return nil
}
