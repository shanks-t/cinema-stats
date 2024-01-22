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
