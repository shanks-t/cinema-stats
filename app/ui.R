source("html.R")

myCSS <- "
.centered-text {
  text-align: center;
  font-size: 30px; /* Adjust the size as needed */
}
"

dashboardPage(
  dashboardHeader(title = "Cinema Stats"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("book", lib = "font-awesome", class = "fa-thin")),
      menuItem("Data Overview", tabName = "data_analysis", icon = icon("chart-line")),
      menuItem("Ratings Search", tabName = "ratings_search", icon = icon("star")),
      menuItem("Ratings Comparison", tabName = "ratings_comparison", icon = icon("magnifying-glass"))
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
    tags$head(tags$style(HTML(myCSS))),
    tabItems(
      tabItem(
        tabName = "about",
        h2("About This Project"),
        tabsetPanel(
          tabPanel(
            "Motivation",
            motivationHTML()
          ),
          tabPanel(
            "Source Systems",
            sourceSystemsHTML()
          ),
          tabPanel(
            "Methodology",
            methodologyHTML()
          )
        )
      ),
      tabItem(
        tabName = "data_analysis",
        selectInput("dataSource", "Select Data Source",
          choices = c("IMDb", "Metacritic", "Rotten Tomatoes", "TMDb"),
          selected = "IMDb"
        ),
        plotOutput("genreHistogram"),
        fluidRow(
          column(
            12,
            selectInput("genreInputA", "Select a Genre",
              choices = c(genre_options),
              selected = "drama"
            )
          )
        ),
        fluidRow(
          column(
            6,
            plotOutput("timeSeriesGenres")
          ),
          column(
            6,
            plotOutput("timeSeriesReleases")
          )
        )
      ),
      # Second Page
      tabItem(
        tabName = "ratings_search",
        fluidRow(
          column(4, textInput("movieSearch", "Search Movie by Title", placeholder = "Enter movie title")),
          # column(4, actionButton("searchButton", "Search", icon = icon("search")))
          # column(4, uiOutput("movieSelect")) # Dropdown for selecting a movie
        ),
        DTOutput("ratingsTable")
        # Add more tabItems for additional pages
      ),
      tabItem(
        tabName = "ratings_comparison",
        h2("The Difference in Critics Scores and Audience Scores by Genre"),
        fluidRow(
          column(4, textOutput("genreCount")),
          column(4, selectInput("genreInput", "Select a Genre",
            choices = c(genre_options),
            selected = ""
          ))
        ),
        plotlyOutput("genreBoxPlot")
      )
    )
  )
)
