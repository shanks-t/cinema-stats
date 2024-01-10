from dagster import asset
import polars as pl
import gzip 
import os
import boto3
from botocore.exceptions import NoCredentialsError
from dagster_duckdb import DuckDBResource

tsv_dir = "data/raw_data/tsv"
parquet_dir = "data/raw_data/parquet"
s3_bucket_name = "cinema-stats"



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

def convert_tsv_to_parquet(tsv_file_path, parquet_dir):
    """
    Converts a TSV file to a Parquet file
    """

    parquet_file_name = os.path.basename(tsv_file_path).replace('.tsv', '.parquet')
    parquet_file_path = os.path.join(parquet_dir, parquet_file_name)

    df = pl.read_csv(tsv_file_path, separator='\t', has_header=True, ignore_errors=True)
    df.write_parquet(parquet_file_path)

    return parquet_file_path

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


@asset
def name_basics_tsv():
    gzip_file_path = "data/raw_data/gzip/name.basics.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)

@asset(
        deps=["name_basics_tsv"]
)
def name_basics_parquet():
    tsv_file_path = "data/raw_data/tsv/name.basics.tsv"
    convert_tsv_to_parquet(tsv_file_path, parquet_dir)

@asset(
        deps=["name_basics_parquet"]
)
def name_basics_s3():
    parquet_file_path = f"{parquet_dir}/name.basics.parquet"
    s3_key = "parquet/name.basics.parquet"
    upload_file_to_s3(parquet_file_path, s3_bucket_name, s3_key)

@asset(deps=["name_basics_s3"])
def name_basics_duckdb(duckdb: DuckDBResource):
    table_name = "name_basics"
    parquet_file_path = f"{parquet_dir}/name.basics.parquet"
    query = f"""
      create table if not exists {table_name} as
      select * from read_parquet('{parquet_file_path}');
    """

    with duckdb.get_connection() as conn:
      conn.execute(query)
      
####

@asset
def title_akas_tsv():
    gzip_file_path = "data/raw_data/gzip/title.akas.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)

@asset(
        deps=["title_akas_tsv"]
)
def title_akas_parquet():
    tsv_file_path = "data/raw_data/tsv/title.akas.tsv"
    convert_tsv_to_parquet(tsv_file_path, parquet_dir)

####
    
@asset
def title_basics_tsv():
    gzip_file_path = "data/raw_data/gzip/title.basics.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_basics_tsv"]
)
def title_basics_parquet():
    tsv_file_path = "data/raw_data/tsv/title.basics.tsv"
    convert_tsv_to_parquet(tsv_file_path, parquet_dir)

####
    
@asset
def title_crew_tsv():
    gzip_file_path = "data/raw_data/gzip/title.crew.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_crew_tsv"]
)
def title_crew_parquet():
    tsv_file_path = "data/raw_data/tsv/title.crew.tsv"
    convert_tsv_to_parquet(tsv_file_path, parquet_dir)

####
    
@asset
def title_ratings_tsv():
    gzip_file_path = "data/raw_data/gzip/title.ratings.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_ratings_tsv"]
)
def title_ratings_parquet():
    tsv_file_path = "data/raw_data/tsv/title.ratings.tsv"
    convert_tsv_to_parquet(tsv_file_path, parquet_dir)

#####

@asset
def title_principals_tsv():
    gzip_file_path = "data/raw_data/gzip/title.principals.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_principals_tsv"]
)
def title_principals_parquet():
    tsv_file_path = "data/raw_data/tsv/title.principals.tsv"
    convert_tsv_to_parquet(tsv_file_path, parquet_dir)