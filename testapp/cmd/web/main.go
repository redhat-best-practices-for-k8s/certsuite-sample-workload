package main

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
)

func getServicePort() int {
	v := os.Getenv("LIVENESS_PROBE_DEFAULT_PORT")
	if p, err := strconv.Atoi(v); err == nil {
		fmt.Println("Port was specified, use port=", p)
		return p
	}
	fmt.Println("Can't process LIVENESS_PROBE_DEFAULT_PORT, use 8080")
	return 8080
}
func main() {
	fmt.Println("try to start the server")
	//Liveness Probe handler
	http.HandleFunc("/health", func(rw http.ResponseWriter, r *http.Request) {
		fmt.Println("query received to check liveness")
		rw.WriteHeader(200)
		rw.Write([]byte("ok"))
	})
	//Readiness Probe handler
	http.HandleFunc("/ready", func(rw http.ResponseWriter, r *http.Request) {
		fmt.Println("query received to check readiness")
		rw.WriteHeader(200)
		rw.Write([]byte("ok"))
	})
	//Launch web server on port 8080
	port := getServicePort()
	addr := ":" + strconv.Itoa(port)
	err := http.ListenAndServe(addr, nil)
	if err != nil {
		fmt.Print("server stopped, err=", err.Error())
		os.Exit(-1)
	}
}
