server <- function(input, output, session) {
  duck <- "/Users/treyshanks/data_engineering/cinema-stats/pipeline/data/staging/data.duckdb"
  con <- dbConnect(duckdb::duckdb(), ":memory:")

  data <- reactive({
    data <- dbGetQuery(con, "SELECT genre, releaseDateTheaters, audienceScore, boxOffice, tomatoMeter FROM
                       read_parquet('/Users/treyshanks/data_engineering/cinema-stats/pipeline/data/raw_data/parquet/rotten_tomatoes_movies.parquet')
                       WHERE audienceScore IS NOT NULL and boxOffice IS NOT NULL")
    return(data)
  })
  # Update genreInput choices
  observe({
    data <- data()
    updateSelectizeInput(session, "genreInput",
      choices = c("All", unique(data$genre))
    )
  })

  # Update yearInput choices
  observe({
    data <- data()
    years <- format(as.Date(data$releaseDateTheaters), "%Y")
    updateSelectInput(session, "yearInput",
      choices = c("All", unique(years))
    )
  })

  reactiveData <- reactive({
    # Start with the base query
    query <- "SELECT genre, releaseDateTheaters, audienceScore, boxOffice, tomatoMeter FROM
              read_parquet('/Users/treyshanks/data_engineering/cinema-stats/pipeline/data/raw_data/parquet/rotten_tomatoes_movies.parquet')
              WHERE audienceScore IS NOT NULL and boxOffice IS NOT NULL and releaseDateTheaters IS NOT NULL"

    # Dynamically add filtering based on inputs
    if (input$genreInput != "All") {
      query <- paste0(query, " AND genre = '", input$genreInput, "'")
    }
    if (input$yearInput != "All") {
      query <- paste0(query, " AND strftime(CAST(releaseDateTheaters AS DATE), '%Y') = '", input$yearInput, "'")
    }

    # Execute the query
    data <- dbGetQuery(con, query)
    return(data)
  })

  aggregatedData <- reactive({
    data <- reactiveData() # Assuming this gets your original data

    data %>%
      mutate(
        year = year(as.Date(releaseDateTheaters)),
        boxOfficeNumeric = as.numeric(gsub("[^0-9.]", "", boxOffice)) # Remove non-numeric characters and convert
      ) %>%
      group_by(year) %>%
      summarise(totalBoxOffice = sum(boxOfficeNumeric, na.rm = TRUE))
  })


  # Render the appropriate plot based on user selection
  output$mainPlot <- renderPlot({
    data <- reactiveData()
    agg <- aggregatedData()
    switch(input$plotType,
      "Histogram of Audience Scores" = {
        ggplot(data, aes(x = audienceScore)) +
          geom_histogram()
      },
      "Scatter Plot of Box Office vs. TomatoMeter" = {
        ggplot(data, aes(x = boxOffice, y = tomatoMeter)) +
          geom_point() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
      },
      "Bar Plot of Movie Counts by Genre" = {
        ggplot(data, aes(x = genre)) +
          geom_bar() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
      },
      "Time Series of Box Office" = {
        ggplot(agg, aes(x = year, y = totalBoxOffice)) +
          geom_line()
      }
    )
  })
}
