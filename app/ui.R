fluidPage(
  titlePanel("Movie Genre Distribution"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataSource", "Select Data Source",
        choices = c("IMDb", "Metacritic", "Rotten Tomatoes", "TMDb"),
        selected = "IMDb"
      ),
    ),
    mainPanel(
      plotOutput("genreHistogram")
    )
  )
)
