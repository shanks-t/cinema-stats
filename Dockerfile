FROM rocker/shiny as builder

# Install system dependencies required by R packages
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libglpk-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    R -e "install.packages(c('DBI', 'ggplot2', 'aws.s3', 'duckdb'))"


FROM  rocker/shiny
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=builder /usr/local/lib/R/library /usr/local/lib/R/library
COPY ./app /srv/shiny-server/

# Expose the port the app runs on
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/', host = '0.0.0.0', port = 3838)"]
# comment the above CMD and uncomment the below to keep the container running so that you can inspect files etc in the container
# CMD ["tail", "-f", "/dev/null"]
