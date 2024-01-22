dashboardPage(
  dashboardHeader(title = "Cinema Stats"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Analysis", tabName = "data_analysis", icon = icon("chart-line")),
      menuItem("Ratings Comparison", tabName = "ratings_comparison", icon = icon("star"))
      # Add more menu items for additional pages
    ),
    div(
      style = "display: inline-block;",
      actionButton("toggleScale", "Toggle Scale (Log/Linear)", style = "margin-right: 10px;"),
      conditionalPanel(
        condition = "input.dataSource === 'TMDb'",
        actionButton("toggleUnreleased", "Toggle Show Unreleased")
      )
    )
    # Add more sidebar elements here
  ),
  dashboardBody(
    tabItems(
      # First Page
      tabItem(
        tabName = "data_analysis",
        selectInput("dataSource", "Select Data Source",
          choices = c("IMDb", "Metacritic", "Rotten Tomatoes", "TMDb"),
          selected = "IMDb"
        ),
        plotOutput("genreHistogram"),
        plotOutput("timeSeriesPlot") # Add this line for the time series plot
      ),
      # Second Page
      tabItem(
        tabName = "ratings_comparison",
        fluidRow(
          column(4, textInput("movieSearch", "Search Movie by Title", placeholder = "Enter movie title")),
          column(4, actionButton("searchButton", "Search", icon = icon("search"))),
          column(4, uiOutput("movieSelect")) # Dropdown for selecting a movie
        ),
        DTOutput("ratingsTable")
        # Add more tabItems for additional pages
      )
    )
  )
)
