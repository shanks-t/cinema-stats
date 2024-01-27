motivationHTML <- function() {
    tagList(
        div(
            class = "centered-text",
            h1("Overview"),
            p("My motivation for this project was to explore the world of movie data and look into the different ratings between popular movie ratings sites."),
            div(
                class = "source-item",
                p("I tried to get my hands on as much movie data as I could. In total, I was able to source quite a few movie records:"),
                div(
                    class = "source-item",
                    strong("Rotten Tomatoes:"),
                    "143,258"
                ),
                div(
                    class = "source-item",
                    strong("Metacritic:"),
                    "14,213"
                ),
                div(
                    class = "source-item",
                    strong("IMDb:"),
                    "667,364"
                ),
                div(
                    class = "source-item",
                    strong("TMDb:"),
                    "882,145"
                ),
            )
        )
    )
}


sourceSystemsHTML <- function() {
    tagList(
        div(
            class = "centered-text",
            h1("Source Systems"),
            div(
                class = "source-item",
                strong("Metacritic and Rotten Tomatoes:"),
                " Datasets were downloaded from Kaggle."
            ),
            div(
                class = "source-item",
                strong("IMDb:"),
                " Had a 'non-commercial' dataset that comprised 7 normalized tables."
            ),
            div(
                class = "source-item",
                strong("TMDb:"),
                " Has a freely available API and it's really dope!"
            )
        )
    )
}

methodologyHTML <- function() {
    tagList(
        div(
            class = "centered-text",
            h1("Ratings Comparisons"),
            p("Because IMDb and TMDb provided the most comprehensive records, I decided to visualize differences in scores between these two systems."),
            p("IMDb uses a \"Weighted Average Ratings\", where some votes (critics, movie professionals) count more than others (regular people like you and me). IMDb publishes weighted vote averages rather than raw data averages."),
            tags$blockquote(
                tags$em(
                    "\"The simplest way to explain it is that although we accept and consider all votes received by users, not all votes have the same impact (or \"weight\") on the final rating.",
                    "When unusual voting activity is detected, an alternate weighting calculation may be applied in order to preserve the reliability of our system.",
                    "To ensure that our rating mechanism remains effective, we do not disclose the exact method used to generate the rating.\""
                )
            ),
            p("TMDb seems to be more straightforward with their ratings. You can see for every movie the average rating along with the distribution of scores."),
            p("So I chose to look at box plots of the difference between these two ratings: TMDb - IMDb. Movies with a higher score represent favorability for the average voter. Movies with a lower score show that critics and movie professionals favor this movie over the average moviegoer.")
        )
    )
}
