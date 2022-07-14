package main

import (
	"context"
	"log"
	"os"

	"github.com/aquaproj/aqua-registry/internal/scaffold"
)

func main() {
	ctx := context.Background()
	if err := scaffold.Scaffold(ctx, os.Args...); err != nil {
		log.Fatal(err)
	}
}
