package api

import (
	"bufio"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

func GenerateRegistry() error {
	tempFile, err := os.CreateTemp("", "")
	if err != nil {
		return err
	}
	defer tempFile.Close()
	defer os.Remove(tempFile.Name())
	if err := copyHeader(tempFile); err != nil {
		return err
	}
	registryFilePaths, err := listRegistryFiles()
	if err != nil {
		return err
	}
	lines, err := readRegistryFiles(registryFilePaths)
	if err != nil {
		return err
	}
	if _, err := tempFile.WriteString(strings.Join(lines, "\n") + "\n"); err != nil {
		return err
	}
	if err := copyRegistry(tempFile.Name()); err != nil {
		return err
	}
	return nil
}

func copyHeader(tempFile io.Writer) error {
	header, err := os.Open("registry-header.yaml")
	if err != nil {
		return err
	}
	defer header.Close()
	if _, err := io.Copy(tempFile, header); err != nil {
		return err
	}
	return nil
}

func listRegistryFiles() ([]string, error) {
	registryFilePaths := []string{}
	if err := filepath.WalkDir("pkgs", func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			if d == nil {
				return err
			}
			return nil
		}
		if filepath.Base(p) == "registry.yaml" {
			registryFilePaths = append(registryFilePaths, p)
		}
		return nil
	}); err != nil {
		return nil, err
	}
	sort.Strings(registryFilePaths)
	return registryFilePaths, nil
}

func readRegistryFiles(registryFilePaths []string) ([]string, error) {
	lines := []string{}
	for _, registryFilePath := range registryFilePaths {
		if err := func() error {
			f, err := os.Open(registryFilePath)
			if err != nil {
				return err
			}
			defer f.Close()
			scanner := bufio.NewScanner(f)
			for scanner.Scan() {
				line := scanner.Text()
				if strings.HasPrefix(line, "packages:") {
					continue
				}
				if line == "---" {
					continue
				}
				lines = append(lines, line)
			}
			if err := scanner.Err(); err != nil {
				return err
			}
			return nil
		}(); err != nil {
			return nil, err
		}
	}
	return lines, nil
}

func copyRegistry(tempFilePath string) error {
	rTempFile, err := os.Open(tempFilePath)
	if err != nil {
		return err
	}
	defer rTempFile.Close()
	registryFile, err := os.Create("registry.yaml")
	if err != nil {
		return err
	}
	defer registryFile.Close()
	if _, err := io.Copy(registryFile, rTempFile); err != nil {
		return err
	}
	return nil
}
