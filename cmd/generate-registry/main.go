package main

import (
	"log"

	genrg "github.com/aquaproj/aqua-registry/v3/internal/generate-registry"
)

func main() {
	if err := genrg.GenerateRegistry(); err != nil {
		log.Fatal(err)
	}
}
