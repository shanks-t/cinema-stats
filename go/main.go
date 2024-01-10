package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func main() {

	url := "https://movies-ratings2.p.rapidapi.com/ratings?id=tt1798709"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("X-RapidAPI-Key", "6028cf62cdmshbf408a335aabfb0p195585jsn278e13555123")
	req.Header.Add("X-RapidAPI-Host", "movies-ratings2.p.rapidapi.com")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return
	}

	// Create a file
	file, err := os.Create("rapid.txt")
	if err != nil {
		fmt.Println("Error creating file:", err)
		return
	}
	defer file.Close()

	// Write response to file
	_, err = file.WriteString(string(body))
	if err != nil {
		fmt.Println("Error writing to file:", err)
		return
	}

	fmt.Println("Response written to rapid.txt")
}
