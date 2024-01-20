function(input, output, session) {
  # Function to generate the file path based on the data source
  getFilePath <- function(dataSource) {
    switch(dataSource,
      "IMDb" = "../dagster/data/raw_data/parquet/imdb.movies.parquet",
      "Metacritic" = "path_to_metacritic.parquet",
      "Rotten Tomatoes" = "../dagster/data/raw_data/parquet/rt.parquet",
      "TMDb" = "path_to_tmdb.parquet"
    )
  }

  # Reactive expression to fetch data and plot bar chart
  output$genreHistogram <- renderPlot({
    req(input$dataSource)
    filePath <- getFilePath(input$dataSource)
    sqlQuery <- sprintf("SELECT genre FROM '%s' WHERE genre IS NOT NULL", filePath)
    data <- dbGetQuery(con, sqlQuery)

    # if (!"genres" %in% colnames(data)) {
    #   stop("Column 'genres' not found in the data.")
    # }

    # Split and unnest genres, then plot all genres
    data |>
      mutate(genre = str_split(genre, ",\\s*")) |>
      unnest(genre) |>
      ggplot(aes(x = genre)) +
      geom_bar() +
      labs(
        title = paste("Genre Distribution for", input$dataSource),
        x = "Genre",
        y = "Count"
      ) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotate x-axis labels for better readability
  })
}
