# shinyUI(fluidPage(
#   titlePanel("Movie Ratings Comparison"),
#   sidebarLayout(
#     sidebarPanel(
#       selectInput("movie", "Select a Movie:", choices = unique(movie_data$title)),
#       checkboxGroupInput("sources", "Select Sources:", choices = c("TMDB", "IMDB", "Rotten Tomatoes", "Metacritic"))
#     ),
#     mainPanel(
#       tabsetPanel(
#         type = "tabs",
#         tabPanel("Bar Chart", plotOutput("barChart")),
#         tabPanel("Box Plot", plotOutput("boxPlot")),
#         tabPanel("Data Table", DTOutput("dataTable"))
#       )
#     )
#   )
# ))

ui <- fluidPage(
  titlePanel("Movie browser"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "y",
        label = "Y-axis:",
        choices = c(
          "IMDB rating" = "rating",
          "IMDB number of votes" = "runtime",
          "Critics Score" = "director",
          "Audience Score" = "audienceScore",
          "Runtime" = "runtime"
        ),
        selected = "audienceScore"
      ),
      selectInput(
        inputId = "x",
        label = "X-axis:",
        choices = c(
          "IMDB rating" = "rating",
          "IMDB number of votes" = "runtime",
          "Critics Score" = "director",
          "Audience Score" = "audienceScore",
          "Runtime" = "runtime"
        ),
        selected = "director"
      ),
      selectInput(
        inputId = "z",
        label = "Color by:",
        choices = c(
          "Critics Rating" = "director",
          "Audience Rating" = "audienceScore"
        ),
        selected = "director"
      ),
      checkboxGroupInput(
        inputId = "selected_genre",
        label = "Select movie genre(s):",
        choices = unique_genres,
        selected = "Feature Film"
      )
    ),
    mainPanel(
      plotOutput(outputId = "scatterplot"),
    )
  )
)
