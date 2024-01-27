library(shiny)
library(DBI)
library(duckdb)
library(ggplot2)
library(aws.s3)
library(bslib)
library(tidyverse)
library(shinydashboard)
library(DT)
library(plotly)


# Establish connection to DuckDB
con <- dbConnect(duckdb::duckdb(), ":memory:")

# tmdb <- "../dagster/data/raw_data/parquet/tmdb.parquet"
sqlQuery <- sprintf("SELECT genre FROM '../dagster/data/raw_data/parquet/ratings_all.parquet' WHERE genre IS NOT NULL")
genre_data <- dbGetQuery(con, sqlQuery)

genre_options <- genre_data |>
    mutate(genre = str_replace_all(genre, ";", ",")) |>
    mutate(genre = str_split(genre, ",\\s*")) |>
    unnest(genre) |>
    distinct(genre) |>
    arrange(genre)

dir_sqlQuery <- sprintf("SELECT distinct(director) as director
FROM '../dagster/data/raw_data/parquet/ratings_all.parquet' WHERE director IS NOT NULL
AND imdb_votes > 200 AND tmdb_votes > 200
GROUP BY director
HAVING COUNT(director) >= 10")
dir_data <- dbGetQuery(con, dir_sqlQuery)

dir_options <- dir_data |>
    # # mutate(dir = str_replace_all(dir, ";", ",")) |>
    # # mutate(dir = str_split(dir, ",\\s*")) |>
    # unnest(director) |>
    # distinct(director) |>
    arrange(director)
print(dir_options)
