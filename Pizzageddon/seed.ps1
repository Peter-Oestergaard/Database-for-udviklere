docker cp DDL postgres-db:/tmp/
docker cp DML postgres-db:/tmp/
docker cp SQL postgres-db:/tmp/

docker exec postgres-db dropdb --force --if-exists pizzageddon
docker exec postgres-db psql -d postgres -c "CREATE DATABASE pizzageddon"
docker exec -w /tmp/DDL postgres-db psql -d pizzageddon -f schema.sql
docker exec -w /tmp/DML postgres-db psql -d pizzageddon -f seed.sql
docker exec -w /tmp/SQL postgres-db psql -d pizzageddon -f queries.sql