#!/bin/bash

dbcont=day7-assignment_postgres_1
dbname=newssite

if !(podman container exists $dbcont && [ "$(podman inspect -f {{.State.Status}} $dbcont)" == "running" ]); then
    echo "Creating containers"
    ./up.sh
fi

podman cp DDL $dbcont:/tmp/
podman cp DML $dbcont:/tmp/

podman exec $dbcont dropdb --force --if-exists $dbname
podman exec $dbcont psql -d postgres -c "CREATE DATABASE $dbname"
podman exec -w /tmp/DDL $dbcont psql -d $dbname -f schema.sql
podman exec -w /tmp/DML $dbcont psql -d $dbname -f seed.sql