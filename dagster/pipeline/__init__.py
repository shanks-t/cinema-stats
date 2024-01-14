from dagster import Definitions, load_assets_from_modules
from . import assets
from dagster_duckdb import DuckDBResource

all_assets = load_assets_from_modules([assets])

defs = Definitions(
    assets=all_assets,
        resources={
        "duckdb": DuckDBResource(
            database="data/staging/data.duckdb",  # required
        )
    },
)
