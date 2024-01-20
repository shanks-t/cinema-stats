library(shiny)
library(DBI)
library(duckdb)
library(ggplot2)
library(aws.s3)
library(bslib)
library(tidyverse)

# Establish connection to DuckDB
con <- dbConnect(duckdb::duckdb(), ":memory:")

# # Example SQL query to join datasets on movie title
# # Modify this query based on your actual table structures and fields
# sql_query <- "
# SELECT
#     title as title,
#     stream_year as stream_year,
#     theater_year as theater_year,
#     runtimeMinutes as runtime,
#     director as director,
#     genre as Genre,
#     tomatoMeter as tomatoMeter,
#     rating AS rating,
#     boxOffice as BoxOffice,
#     audienceScore AS audienceScore,
# FROM '../dagster/data/raw_data/parquet/rt.parquet'
# "

# # Load and preprocess data
# all_movies <- dbGetQuery(conn, sql_query)
