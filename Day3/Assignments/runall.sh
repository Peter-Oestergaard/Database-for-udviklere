#!/bin/bash

if !(podman container exists postgres-db && [ "$(podman inspect -f {{.State.Status}} postgres-db)" == "running" ]); then
    echo "Starting Postgres containers"
    podman-compose -f ~/dev/github.com/ucldk/databases/postgres-compose.yml up -d
fi

# Copy .sql files to container
podman cp Test_data postgres-db:/tmp/
podman cp 0-show-db-contents.sql postgres-db:/tmp/
podman cp 1-subqueries.sql postgres-db:/tmp/
podman cp 2-views.sql postgres-db:/tmp/
podman cp 3-functions.sql postgres-db:/tmp/
podman cp 4-stored-procedures.sql postgres-db:/tmp/
podman cp 5-transactions.sql postgres-db:/tmp/
podman cp 5-transactions-pizzageddon.sql postgres-db:/tmp/

# Recreate database
recreate_db() {
    podman exec postgres-db dropdb --force --if-exists day3_assignments
    podman exec postgres-db psql -d postgres -c "CREATE DATABASE day3_assignments" -q
    # Initialize database
    podman exec -w /tmp/Test_data postgres-db psql -d day3_assignments -f dfu-03-education-db.sql &>/dev/null
}
recreate_db

echo "################"
echo "First assignment"
echo "################"
podman exec -w /tmp/Test_data postgres-db psql -d day3_assignments -f extra-data.sql -q
#podman exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 1-subqueries.sql

echo "#################"
echo "Second assignment"
echo "#################"
echo "Resetting database (removing the extra data for the first assignment)"
recreate_db
#podman exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 2-views.sql -q

echo "################"
echo "Third assignment"
echo "################"
#podman exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 3-functions.sql -q

echo "#################"
echo "Fourth assignment"
echo "#################"
echo "Resetting database (removing the updates from the third assignment)"
recreate_db
#podman exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 4-stored-procedures.sql -q

echo "################"
echo "Fifth assignment"
echo "################"
podman exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 5-transactions.sql -q
pushd ../../Day2/Pizzageddon/ &>/dev/null
    podman cp DDL postgres-db:/tmp/
    podman cp DML postgres-db:/tmp/
    podman cp SQL postgres-db:/tmp/

    podman exec postgres-db dropdb --force --if-exists pizzageddon
    podman exec postgres-db psql -d postgres -c "CREATE DATABASE pizzageddon" -q
    podman exec -w /tmp/DDL postgres-db psql -d pizzageddon -f schema.sql -q
    podman exec -w /tmp/DML postgres-db psql -d pizzageddon -f seed.sql -q
popd &>/dev/null
podman exec -w /tmp postgres-db psql -d pizzageddon -f 5-transactions-pizzageddon.sql -q