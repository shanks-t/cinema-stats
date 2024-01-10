package main

import (
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
)

type ApiResponse struct {
	Page         int     `json:"page"`
	TotalPages   int     `json:"total_pages"`
	TotalResults int     `json:"total_results"`
	Results      []Movie `json:"results"`
}

type Movie struct {
	Adult            bool    `json:"adult"`
	GenreIDs         []int   `json:"genre_ids"`
	ID               int     `json:"id"`
	OriginalLanguage string  `json:"original_language"`
	OriginalTitle    string  `json:"original_title"`
	Overview         string  `json:"overview"`
	Popularity       float64 `json:"popularity"`
	PosterPath       string  `json:"poster_path"`
	ReleaseDate      string  `json:"release_date"`
	Title            string  `json:"title"`
	Video            bool    `json:"video"`
	VoteAverage      float64 `json:"vote_average"`
	VoteCount        int     `json:"vote_count"`
}

func goDotEnvVariable(key string) string {

	// load .env file
	err := godotenv.Load("../.env")

	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	return os.Getenv(key)
}

func main() {
	token := goDotEnvVariable("TMDB_ACCESS_TOKEN")

	file, err := os.Create("movies.csv")
	if err != nil {
		fmt.Println("Error creating CSV file:", err)
		return
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write header
	header := []string{
		"ID", "Title", "OriginalTitle", "OriginalLanguage", "ReleaseDate",
		"PosterPath", "Overview", "Popularity", "VoteAverage", "VoteCount",
		"Adult", "Video", "GenreIDs",
	}
	writer.Write(header)

	var totalPages = 2 // Initially set to 1, will be updated from the API response
	for page := 1; page <= totalPages; page++ {
		url := fmt.Sprintf("https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=%d&sort_by=popularity.desc", page)

		req, _ := http.NewRequest("GET", url, nil)
		req.Header.Add("accept", "application/json")
		req.Header.Add("Authorization", "Bearer "+token) // Replace XXXX with your actual API Key

		res, _ := http.DefaultClient.Do(req)
		defer res.Body.Close()

		var response ApiResponse
		if err := json.NewDecoder(res.Body).Decode(&response); err != nil {
			fmt.Println("Error decoding JSON:", err)
			return
		}

		// totalPages = response.TotalPages // Update the total pages

		// Write movie details for the current page
		for _, movie := range response.Results {
			genreIDs := strings.Trim(strings.Join(strings.Fields(fmt.Sprint(movie.GenreIDs)), ","), "[]")
			row := []string{
				strconv.Itoa(movie.ID),
				movie.Title,
				movie.OriginalTitle,
				movie.OriginalLanguage,
				movie.ReleaseDate,
				movie.PosterPath,
				movie.Overview,
				fmt.Sprintf("%f", movie.Popularity),
				fmt.Sprintf("%f", movie.VoteAverage),
				strconv.Itoa(movie.VoteCount),
				strconv.FormatBool(movie.Adult),
				strconv.FormatBool(movie.Video),
				genreIDs,
			}
			writer.Write(row)
		}
		writer.Flush() // Flush after writing each page
		fmt.Printf("Page %d written successfully to movies.csv\n", page)
	}
}
