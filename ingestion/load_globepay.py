"""
uv run python ingestion/load_globepay.py
"""

import duckdb

with duckdb.connect("deel_test.duckdb") as con:
    con.execute("CREATE SCHEMA IF NOT EXISTS globepay")

    con.execute("""
        CREATE OR REPLACE TABLE globepay.raw_acceptance_report AS
        SELECT * FROM read_csv(
            'data/globepay/acceptance_report.csv',
            header = TRUE,
            columns = {
                'external_ref': 'VARCHAR',
                'status': 'BOOLEAN',
                'source': 'VARCHAR',
                'ref': 'VARCHAR',
                'date_time': 'TIMESTAMPTZ',
                'state': 'VARCHAR',
                'cvv_provided': 'BOOLEAN',
                'amount': 'DECIMAL(18, 2)',
                'country': 'VARCHAR',
                'currency': 'VARCHAR',
                'rates': 'JSON'
            }
        )
    """)

    con.execute("""
        CREATE OR REPLACE TABLE globepay.raw_chargeback_report AS
        SELECT * FROM read_csv(
            'data/globepay/chargeback_report.csv',
            header = TRUE,
            columns = {
                'external_ref': 'VARCHAR',
                'status': 'BOOLEAN',
                'source': 'VARCHAR',
                'chargeback': 'BOOLEAN'
            }
        )
    """)
