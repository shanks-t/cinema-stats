fluidPage(
  titlePanel("Movie Data Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataSource", "Select Data Source",
        choices = c("IMDb", "Metacritic", "Rotten Tomatoes", "TMDb"),
        selected = "IMDb"
      ),
      actionButton("toggleScale", "Toggle Scale (Log/Linear)"),
      conditionalPanel(
        condition = "input.dataSource === 'TMDb'",
        actionButton("toggleUnreleased", "Toggle Show Unreleased")
      )
    ),
    mainPanel(
      plotOutput("genreHistogram"),
      plotOutput("timeSeriesPlot") # Add this line for the time series plot
    )
  )
)
