#!/bin/bash

podman cp DDL postgres-db:/tmp/
podman cp DML postgres-db:/tmp/
podman cp SQL postgres-db:/tmp/

podman exec postgres-db dropdb --force --if-exists pizzageddon
podman exec postgres-db psql -d postgres -c "CREATE DATABASE pizzageddon"
podman exec -w /tmp/DDL postgres-db psql -d pizzageddon -f schema.sql
podman exec -w /tmp/DML postgres-db psql -d pizzageddon -f seed.sql
podman exec -w /tmp/SQL postgres-db psql -d pizzageddon -f queries.sql