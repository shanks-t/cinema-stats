ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("Movie Data Exploration"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("genreInput", "Select Genre", choices = c("All")),
      selectizeInput("yearInput", "Select Year", choices = c("All")),
      selectInput("plotType", "Select Plot Type",
        choices = c(
          "Histogram of Audience Scores",
          "Scatter Plot of Box Office vs. TomatoMeter",
          "Bar Plot of Movie Counts by Genre",
          "Time Series of Box Office"
        )
      )
    ),
    mainPanel(
      plotOutput("mainPlot")
    )
  )
)
