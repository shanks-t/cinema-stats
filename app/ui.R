ui <- fluidPage(
    titlePanel("Actor Birth Year Visualization"),

    # User input for selecting a year
    sidebarLayout(
        sidebarPanel(
            numericInput("yearInput", "Select a Year:", 
                         value = 1990,   # Default value
                         min = 1800,     # Minimum value
                         max = Sys.Date(), # Current year as maximum
                         step = 1)       # Step size for the input
        ),
        mainPanel(
            plotOutput("birthYearPlot")
        )
    )
)
