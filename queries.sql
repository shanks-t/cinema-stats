create table if not exists {table_name} as
select * from read_parquet('{parquet_file_path}');