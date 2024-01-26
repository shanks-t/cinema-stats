library(shiny)
library(DBI)
library(duckdb)
library(ggplot2)
library(aws.s3)
library(bslib)
library(tidyverse)
library(shinydashboard)
library(DT)

# Establish connection to DuckDB
con <- dbConnect(duckdb::duckdb(), ":memory:")

# tmdb <- "../dagster/data/raw_data/parquet/tmdb.parquet"
sqlQuery <- sprintf("SELECT genre FROM '../dagster/data/raw_data/parquet/tmdb.parquet' WHERE genre IS NOT NULL")
data <- dbGetQuery(con, sqlQuery)

genre_options <- data |>
    mutate(genre = str_replace_all(genre, ";", ",")) |>
    mutate(genre = str_split(genre, ",\\s*")) |>
    unnest(genre) |>
    distinct(genre) |>
    arrange(genre)

print(genre_options)
