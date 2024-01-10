import polars as pl
import pandas as pd
import numpy as np


def read_tsv_with_polars(file_path, column_names, column_types, null_values=['\\N']):
    """
    Reads a TSV file into a Polars DataFrame with specified column names and types.

    Parameters:
    file_path (str): Path to the TSV file.
    column_names (list): List of column names.
    column_types (list): List of Polars data types for the columns.
    null_values (list, optional): List of strings to be treated as null values. Defaults to ['\\N'].

    Returns:
    pl.DataFrame: Polars DataFrame with the TSV data.
    """
    # Set the format string lengths for display
    pl.Config.set_fmt_str_lengths(50)

    # Read the TSV file
    df = pl.read_csv(
        file_path,
        separator='\t',
        has_header=False,
        new_columns=column_names,
        dtypes=column_types,
        ignore_errors=True,
        null_values=null_values,
        skip_rows=1
    )

    return df

ratings_df = read_tsv_with_polars("./raw_data/title.ratings.tsv", ['const', 'averageRating', 'numVotes'], [pl.Utf8, pl.Float32, pl.Int32])

column_names = ['const', 'titleType', 'primaryTitle', 'originalTitle', 'isAdult', 
                'startYear', 'endYear', 'runtimeMinutes', 'genres']

# Define column types
# Adjust these based on the actual data in each column
column_types = [pl.Utf8, pl.Utf8, pl.Utf8, pl.Utf8, pl.Int32, 
                pl.Int32, pl.Int32, pl.Int32, pl.Utf8]

basics_df = read_tsv_with_polars('./raw_data/title.basics.tsv', column_names, column_types)

filter_condition = basics_df['titleType'] == "movie"

movies = basics_df.filter(filter_condition)

movie_ratings = movies.join(ratings_df, on="const", how="inner")

movie_ratings.write_parquet('./processed_data/movies_with_ratings_lambda.parquet')