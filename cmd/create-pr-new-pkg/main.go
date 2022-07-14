package main

import (
	"context"
	"log"

	newpkg "github.com/aquaproj/aqua-registry/internal/create-pr-new-pkg"
)

func main() {
	ctx := context.Background()
	if err := newpkg.CreatePRNewPkgs(ctx); err != nil {
		log.Fatal(err)
	}
}
