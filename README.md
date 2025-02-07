# postgres-exporter

## Preparations

- Create a PostgreSQL user with **pg_monitor** role and extension **pg_stat_statements**
```sql
CREATE USER postgres_exporter WITH PASSWORD '<EXPORTER_PASSWORD>';
GRANT pg_monitor TO postgres_exporter;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

- Replace the variables in the `postgres_exporter.env` file with your own values.

## Use different ports

- Modify the `EXPORTER_PORT` variable in the `postgres_exporter.env` file (for Docker Compose).
- Modify the `EXPORTER_PORT` variable in the `install.sh` script (for manual installation).
