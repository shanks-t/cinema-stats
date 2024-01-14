from dagster import Definitions, load_assets_from_modules
from . import imdb
from dagster_duckdb import DuckDBResource

all_assets = load_assets_from_modules([imdb])

defs = Definitions(
    assets=all_assets,
        resources={
        "duckdb": DuckDBResource(
            database="data/staging/data.duckdb",  # required
        )
    },
)
