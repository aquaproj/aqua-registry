package main

import (
	"log"

	"github.com/aquaproj/aqua-registry/internal/api"
)

func main() {
	if err := api.GenerateRegistry(); err != nil {
		log.Fatal(err)
	}
}
