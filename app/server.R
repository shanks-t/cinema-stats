# shinyServer(function(input, output) {
#   filtered_data <- reactive({
#     req(input$movie, input$sources)
#     filter_set <- setNames(lapply(input$sources, function(x) TRUE), tolower(input$sources))
#     movie_data |>
#       filter(title == input$movie) |>
#       select(title, imdb_rating, rt_rating) |>
#       pivot_longer(cols = title, names_to = "source", values_to = "value") |>
#       mutate(source = tolower(source), value = ifelse(source %in% names(filter_set), value, NA_real_))
#   })

#   output$barChart <- renderPlot(
#     {
#       data <- filtered_data()
#       ggplot(data, aes(x = source, y = value, fill = source)) +
#         geom_bar(stat = "identity", position = position_dodge()) +
#         theme_minimal() +
#         labs(x = "Source", y = "Rating", title = "Comparative Bar Chart of Movie Ratings")
#     },
#     height = 250
#   )

#   output$boxPlot <- renderPlot(
#     {
#       data <- filtered_data()
#       ggplot(data, aes(x = source, y = value, fill = source)) +
#         geom_boxplot() +
#         theme_minimal() +
#         labs(x = "Source", y = "Rating", title = "Box Plot of Movie Ratings")
#     },
#     height = 250
#   )

#   output$dataTable <- renderDT({
#     datatable(filtered_data(), options = list(pageLength = 5, scrollX = TRUE))
#   })
# })

server <- function(input, output, session) {
  # Create a subset of data filtering for selected title types
  movies_subset <- reactive({
    req(input$selected_genre)
    subset <- filter(movies, genre %in% input$selected_genre)
  })

  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(
      data = movies_subset(),
      aes_string(x = input$x, y = input$y, color = input$z)
    ) +
      geom_point() +
      labs(title = input$selected_genre)
  })
}
