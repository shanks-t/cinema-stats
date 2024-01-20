function(input, output, session) {
  # Reactive value to store the scale type
  scaleType <- reactiveVal("Linear Scale")

  # Observe the toggleScale button click
  observeEvent(input$toggleScale, {
    # Toggle the scale type between "log" and "linear"
    currentScale <- scaleType()
    scaleType(ifelse(currentScale == "Linear Scale", "Log Scale", "Linear Scale"))
  })

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
      {
        if (scaleType() == "Log Scale") {
          scale_y_log10(labels = scales::label_comma(accuracy = 1), breaks = c(1, 10, 100, 1000, 10000, 100000))
        } else {
          scale_y_continuous(labels = scales::label_comma(accuracy = 1), breaks = scales::pretty_breaks(n = 10))
        }
      } +
      labs(
        title = paste(scaleType(), "Genre Distribution for", input$dataSource),
        x = "Genre",
        y = "Count"
      ) +
      theme(axis.text.y = element_text(size = 13), axis.text.x = element_text(size = 13, angle = 45, hjust = 1)) # Rotate x-axis labels for better readability
  })
}
