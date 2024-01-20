function(input, output, session) {
  # Reactive value to store the scale type
  scaleType <- reactiveVal("Linear Scale")
  showUnreleased <- reactiveVal(FALSE)

  # Observe the toggleScale button click
  observeEvent(input$toggleScale, {
    # Toggle the scale type between "log" and "linear"
    currentScale <- scaleType()
    scaleType(ifelse(currentScale == "Linear Scale", "Log Scale", "Linear Scale"))
  })

  observeEvent(input$toggleUnreleased, {
    # Toggle the state between TRUE and FALSE
    showUnreleased(!showUnreleased())
  })

  # Function to generate the file path based on the data source
  getFilePath <- function(dataSource) {
    switch(dataSource,
      "IMDb" = "../dagster/data/raw_data/parquet/imdb.movies.parquet",
      "Metacritic" = "../dagster/data/raw_data/parquet/meta.parquet",
      "Rotten Tomatoes" = "../dagster/data/raw_data/parquet/rt.parquet",
      "TMDb" = "../dagster/data/raw_data/parquet/tmdb.parquet"
    )
  }

  # Reactive expression to fetch data and plot bar chart
  output$genreHistogram <- renderPlot({
    req(input$dataSource)
    filePath <- getFilePath(input$dataSource)
    sqlQuery <- sprintf("SELECT genre FROM '%s' WHERE genre IS NOT NULL", filePath)
    data <- dbGetQuery(con, sqlQuery)

    data |>
      mutate(genre = str_replace_all(genre, ";", ",")) |>
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


  releases <- reactive({
    req(input$dataSource)
    filePath <- getFilePath(input$dataSource)
    if (input$dataSource == "TMDb") {
      statusFilter <- if (showUnreleased()) "AND Status != 'Released'" else "AND Status == 'Released'"
      sqlQuery <- sprintf("SELECT Status, year, COUNT(year) as num_releases FROM '%s' WHERE year IS NOT NULL %s GROUP BY Status, year", filePath, statusFilter)
    } else {
      sqlQuery <- sprintf("SELECT year, COUNT(year) as num_releases FROM '%s' WHERE genre IS NOT NULL AND year IS NOT NULL GROUP BY year", filePath)
    }
    release_data <- dbGetQuery(con, sqlQuery)
  })

  # Plot for movie releases per year
  output$timeSeriesPlot <- renderPlot({
    release_data <- releases() # Call the reactive expression

    if (input$dataSource == "TMDb") {
      status <- if (showUnreleased()) "Unreleased Movies" else "Number of Movie Releases per Year"
      # Plot for TMDb data (categorical plot)
      ggplot(release_data, aes(x = year, y = num_releases, color = Status)) +
        geom_line() +
        scale_x_continuous(breaks = round(seq(min(release_data$year), max(release_data$year), length.out = 8))) +
        labs(
          title = status,
          x = "year",
          y = "Number of Movies",
        ) +
        theme(axis.text.y = element_text(size = 13), axis.text.x = element_text(size = 13, hjust = 1)) +
        scale_color_brewer(palette = "Set1")
    } else {
      ggplot(release_data, aes(x = year, y = num_releases)) +
        geom_line() +
        scale_x_continuous(breaks = round(seq(min(release_data$year), max(release_data$year), length.out = 8))) +
        labs(
          title = "Number of Movie Releases per Year",
          x = "Year",
          y = "Number of Releases"
        ) +
        theme(axis.text.y = element_text(size = 13), axis.text.x = element_text(size = 13, hjust = 1))
    }
  })
}
