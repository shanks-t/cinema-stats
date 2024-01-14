import polars as pl
import pandas as pd
import numpy as np
import os
import gzip
import polars as pl
import pyarrow.parquet as pq
import boto3
from botocore.exceptions import NoCredentialsError


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

def convert_tsv_to_parquet(file_path: str , file_type: str, parquet_dir: str) -> str:

    parquet_file_name = os.path.basename(file_path).replace(file_type, '.parquet')
    parquet_file_path = os.path.join(parquet_dir, parquet_file_name)

    df = pl.read_csv(file_path, separator='\t', has_header=True, ignore_errors=True)
    df.write_parquet(parquet_file_path)

    return parquet_file_path

def unzip_gzipped_file(gzip_file_path, output_dir):
    """
    Unzips a gzipped file.

    :param gzip_file_path: Path to the gzipped file.
    :param output_dir: Directory to store the unzipped file.
    :return: Path of the unzipped file.
    """
    os.makedirs(output_dir, exist_ok=True)
    tsv_file_name = os.path.basename(gzip_file_path).replace('.gz', '')
    tsv_file_path = os.path.join(output_dir, tsv_file_name)

    with gzip.open(gzip_file_path, 'rb') as gz_file:
        with open(tsv_file_path, 'wb') as tsv_file:
            tsv_file.write(gz_file.read())

    return tsv_file_path

def upload_file_to_s3(file_path, bucket_name, s3_key):
    """
    Uploads a file to an S3 bucket.

    :param file_path: Path to the file to upload.
    :param bucket_name: Name of the S3 bucket.
    :param s3_key: S3 key for the uploaded file.
    """
    s3 = boto3.client('s3')

    try:
        s3.upload_file(file_path, bucket_name, s3_key)
        print(f"File {file_path} uploaded to s3://{bucket_name}/{s3_key}")
    except NoCredentialsError:
        print("Credentials not available for AWS S3.")
        

def convert_to_parquet(file_path: str) -> pl.DataFrame:
    return pl.from_arrow(pq.read_table(file_path))
