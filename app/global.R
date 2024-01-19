library(shiny)
library(DBI)
library(duckdb)
library(ggplot2)
library(aws.s3)
library(bslib)
library(tidyverse)
library(dplyr)
library(DT)



# Establish connection to DuckDB
conn <- dbConnect(duckdb::duckdb(), ":memory:")

# Example SQL query to join datasets on movie title
# Modify this query based on your actual table structures and fields
sql_query <- "
SELECT
    title as title,
    stream_year as stream_year,
    theater_year as theater_year,
    runtimeMinutes as runtime,
    director as director,
    genre as genre,
    tomatoMeter as tomatoMeter,
    rating AS rating,
    audienceScore AS audienceScore,
FROM '../dagster/data/raw_data/parquet/rt.parquet'
"

# Load and preprocess data
movies <- dbGetQuery(conn, sql_query)


unique_genres <- movies %>%
    # Assuming genres are separated by commas
    mutate(genre = str_split(genre, ",\\s*")) %>%
    unnest(genre) %>%
    distinct(genre) %>%
    arrange(genre) %>%
    pull(genre)
