#!/bin/bash

if !(podman container exists postgres-db && [ "$(podman inspect -f {{.State.Status}} postgres-db)" == "running" ]); then
    echo "Starting Postgres containers"
    podman-compose -f ~/dev/github.com/ucldk/databases/postgres-compose.yml up -d
fi

podman cp Test_data postgres-db:/tmp/
podman cp 0-show-db-contents.sql postgres-db:/tmp/
podman cp 1-subqueries.sql postgres-db:/tmp/

podman exec postgres-db dropdb --force --if-exists day3_assignments
podman exec postgres-db psql -d postgres -c "CREATE DATABASE day3_assignments"
podman exec -w /tmp/Test_data postgres-db psql -d day3_assignments -f dfu-03-education-db.sql
podman exec -w /tmp/Test_data postgres-db psql -d day3_assignments -f extra-data.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
podman exec -w /tmp postgres-db psql -d day3_assignments -f 1-subqueries.sql