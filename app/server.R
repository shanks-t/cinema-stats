

duck <- "/Users/treyshanks/data_engineering/cinema-stats/pipeline/data/staging/data.duckdb"

server <- function(input, output, session) {
    # Reactive expression to handle the database query
    reactiveData <- reactive({
        # Temporary file to store the downloaded Parquet file
        temp_parquet <- tempfile(fileext = ".parquet")

        # Download the Parquet file from S3
        save_object("s3://cinema-stats/parquet/name.basics.parquet", file = temp_parquet)

        # Connect to DuckDB
        con <- dbConnect(duckdb::duckdb(), ":memory:")
        on.exit(dbDisconnect(con, shutdown=TRUE), add = TRUE)

        # Register the S3 file as a table in DuckDB
        dbExecute(con, sprintf("CREATE VIEW s3_data AS SELECT * FROM read_parquet('%s')", temp_parquet))

        # Prepare the query using the input year
        query <- sprintf("SELECT birthYear, COUNT(*) as count 
                          FROM s3_data 
                          WHERE birthYear = '%s' 
                          GROUP BY birthYear", input$yearInput)

        # Execute the query and store the result
        data <- dbGetQuery(con, query)

        # Return the data
        return(data)
    })

    # Render the plot
    output$birthYearPlot <- renderPlot({
        data <- reactiveData()

        # Check if data is not empty
        if(nrow(data) > 0){
            ggplot(data, aes(x = birthYear, y = count)) +
              geom_bar(stat = "identity") +
              theme_minimal() +
              xlab("Birth Year") +
              ylab("Number of Actors") +
              ggtitle("Number of Actors Born in the Selected Year")
        } else {
            ggplot() + 
              ggtitle("No data for the selected year")
        }
    })
}
