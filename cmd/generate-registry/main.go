package main

import (
	"log"

	genrg "github.com/aquaproj/aqua-registry/internal/generate-registry"
)

func main() {
	if err := genrg.GenerateRegistry(); err != nil {
		log.Fatal(err)
	}
}
