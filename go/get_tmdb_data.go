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
	"sync"
	"time"

	"github.com/joho/godotenv"
)

type MovieDetail struct {
	Budget              int       `json:"budget"`
	Genres              []Genre   `json:"genres"`
	ID                  int       `json:"id"`
	ImdbID              string    `json:"imdb_id"`
	OriginalLanguage    string    `json:"original_language"`
	OriginalTitle       string    `json:"original_title"`
	Overview            string    `json:"overview"`
	Popularity          float64   `json:"popularity"`
	PosterPath          string    `json:"poster_path"`
	ProductionCompanies []Company `json:"production_companies"`
	ProductionCountries []Country `json:"production_countries"`
	ReleaseDate         string    `json:"release_date"`
	Revenue             int       `json:"revenue"`
	Runtime             int       `json:"runtime"`
	Status              string    `json:"status"`
	Title               string    `json:"title"`
	VoteAverage         float64   `json:"vote_average"`
	VoteCount           int       `json:"vote_count"`
}

type Genre struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

type Company struct {
	ID            int    `json:"id"`
	LogoPath      string `json:"logo_path"`
	Name          string `json:"name"`
	OriginCountry string `json:"origin_country"`
}

type Country struct {
	ISO3166_1 string `json:"iso_3166_1"`
	Name      string `json:"name"`
}

var (
	token = goDotEnvVariable("TMDB_ACCESS_TOKEN")
	mu    sync.Mutex
)

func goDotEnvVariable(key string) string {

	// load .env file
	err := godotenv.Load("../.env")

	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	return os.Getenv(key)
}

func fetchAndWriteMovies(id int, token string, writer *csv.Writer, wg *sync.WaitGroup) {

	fmt.Printf("Fetching movie with id: %d...\n", id)
	url := fmt.Sprintf("https://api.themoviedb.org/3/movie/%d?language=en-US", id)
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Add("accept", "application/json")
	req.Header.Add("Authorization", "Bearer "+token)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Printf("http request failed: %v\n", err)
	}
	defer res.Body.Close()

	// Check the HTTP status code
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		fmt.Printf("Non-success HTTP status code: %d\n", res.StatusCode)
		return
	}

	var movieDetail MovieDetail
	if err := json.NewDecoder(res.Body).Decode(&movieDetail); err != nil {
		fmt.Println("Error decoding JSON:", err)
		return
	}

	// Process and write movie details to CSV
	genreNames := make([]string, len(movieDetail.Genres))
	for i, genre := range movieDetail.Genres {
		genreNames[i] = genre.Name
	}
	genreString := strings.Join(genreNames, "; ")

	companyNames := make([]string, len(movieDetail.ProductionCompanies))
	for i, company := range movieDetail.ProductionCompanies {
		companyNames[i] = company.Name
	}
	companyString := strings.Join(companyNames, "; ")

	countryNames := make([]string, len(movieDetail.ProductionCountries))
	for i, country := range movieDetail.ProductionCountries {
		countryNames[i] = country.Name
	}
	countryString := strings.Join(countryNames, "; ")

	// Define the row to write to the CSV
	row := []string{
		strconv.Itoa(movieDetail.ID),
		movieDetail.Title,
		movieDetail.OriginalTitle,
		movieDetail.OriginalLanguage,
		movieDetail.ReleaseDate,
		movieDetail.PosterPath,
		movieDetail.Overview,
		fmt.Sprintf("%f", movieDetail.Popularity),
		fmt.Sprintf("%f", movieDetail.VoteAverage),
		strconv.Itoa(movieDetail.VoteCount),
		genreString,
		strconv.Itoa(movieDetail.Budget),
		movieDetail.ImdbID,
		strconv.Itoa(movieDetail.Revenue),
		strconv.Itoa(movieDetail.Runtime),
		movieDetail.Status,
		companyString,
		countryString,
	}
	// using a mutex will ensure that only one goroutine/thread can write to the file at a time
	// when a goroutine needs to access a shared resource it will "lock" the mutex, which blocks other goroutines for accessing it
	// this part of the program is called the critical section
	// when a goroutine is doen with the writer, it unlocks the writer for use by other goroutines
	mu.Lock()
	writer.Write(row) // Writing to CSV inside the goroutine
	mu.Unlock()

	// fmt.Printf("Page %d processed and written to CSV\n", page)
}

func main() {
	movieIDs, err := ReadMovieIDs("../pipeline/data/raw_data/csv/tmdb/movie_ids.json")
	if err != nil {
		log.Fatal("Error reading movie ids", err)
	}
	// for _, id := range movieIDs {
	// 	print(id)
	// }
	// movieIDs := []int{2, 3, 3, 5, 6}
	csv_path := "../pipeline/data/raw_data/csv/tmdb/tmdb_movies.csv"

	file, err := os.Create(csv_path)
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
		"Genres", "Budget", "ImdbID", "Revenue", "Runtime", "Status",
		"ProductionCompanies", "ProductionCountries",
	}

	writer.Write(header)

	var wg sync.WaitGroup
	concurrencyLimit := 20 // Set a limit to the number of concurrent requests BEWARE: TMDB only allows a max of 20 per ip
	idChan := make(chan int, concurrencyLimit)
	rateLimiter := time.NewTicker(time.Millisecond * 20) // limit to 50 request per sec by creating ticks 20 ms ticks

	for i := 0; i < concurrencyLimit; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for id := range idChan {
				<-rateLimiter.C // wait for next time slot/tick
				fetchAndWriteMovies(id, token, writer, &wg)
			}
		}()
	}

	for _, id := range movieIDs {
		idChan <- id
	}

	close(idChan)
	wg.Wait()      // Wait for all goroutines to finish
	writer.Flush() // Flush after writing each id
	fmt.Printf("CSV file written successfull to %s\n", csv_path)

}
