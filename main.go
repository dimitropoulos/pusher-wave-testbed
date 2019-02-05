package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		environmentVariable := os.Getenv("TEST_ENV")
		fmt.Println("I'm gettin some requests over here")
		w.Write([]byte(environmentVariable))
	})
	http.ListenAndServe(":8080", nil)
}
