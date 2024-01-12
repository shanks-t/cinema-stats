package main

import (
	"bufio"
	"encoding/json"
	"log"
	"os"
)

type Movie struct {
	ID int `json:"id"`
}

func ReadMovieIDs(jsonPath string) ([]int, error) {
	file, err := os.Open(jsonPath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var ids []int
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		var movie Movie
		if err := json.Unmarshal(scanner.Bytes(), &movie); err != nil {
			// Handle the error or skip the faulty line
			log.Printf("Error decoding JSON line: %v", err)
			continue
		}
		ids = append(ids, movie.ID)
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return ids, nil
}
