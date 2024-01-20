fluidPage(
  titlePanel("Movie Genre Distribution"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataSource", "Select Data Source",
        choices = c("IMDb", "Metacritic", "Rotten Tomatoes", "TMDb"),
        selected = "IMDb"
      ),
      actionButton("toggleScale", "Toggle Scale (Log/Linear)")
    ),
    mainPanel(
      plotOutput("genreHistogram")
    )
  )
)
