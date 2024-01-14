from dagster import asset
import polars as pl
from dagster_duckdb import DuckDBResource
from .utils.functions import convert_tsv_to_parquet, unzip_gzipped_file, upload_file_to_s3


tsv_dir = "data/raw_data/tsv"
parquet_dir = "data/raw_data/parquet"
s3_bucket_name = "cinema-stats"

@asset
def name_basics_tsv():
    gzip_file_path = "data/raw_data/gzip/name.basics.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)

@asset(
        deps=["name_basics_tsv"]
)
def name_basics_parquet():
    file_path = "data/raw_data/tsv/name.basics.tsv"
    convert_tsv_to_parquet(file_path, ".tsv", parquet_dir)

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
    file_path = "data/raw_data/tsv/title.akas.tsv"
    convert_tsv_to_parquet(file_path, ".tsv", parquet_dir)

####
    
@asset
def title_basics_tsv():
    gzip_file_path = "data/raw_data/gzip/title.basics.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_basics_tsv"]
)
def title_basics_parquet():
    file_path = "data/raw_data/tsv/title.basics.tsv"
    convert_tsv_to_parquet(file_path, ".tsv", parquet_dir)

####
    
@asset
def title_crew_tsv():
    gzip_file_path = "data/raw_data/gzip/title.crew.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_crew_tsv"]
)
def title_crew_parquet():
    file_path = "data/raw_data/tsv/title.crew.tsv"
    convert_tsv_to_parquet(file_path, ".tsv", parquet_dir)

####
    
@asset
def title_ratings_tsv():
    gzip_file_path = "data/raw_data/gzip/title.ratings.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_ratings_tsv"]
)
def title_ratings_parquet():
    file_path = "data/raw_data/tsv/title.ratings.tsv"
    convert_tsv_to_parquet(file_path, ".tsv", parquet_dir)

#####

@asset
def title_principals_tsv():
    gzip_file_path = "data/raw_data/gzip/title.principals.tsv.gz"
    unzip_gzipped_file(gzip_file_path, tsv_dir)
@asset(
        deps=["title_principals_tsv"]
)
def title_principals_parquet():
    file_path = "data/raw_data/tsv/title.principals.tsv"
    convert_tsv_to_parquet(file_path, ".tsv", parquet_dir)