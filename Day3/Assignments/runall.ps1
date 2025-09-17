docker inspect postgres-db *> $null
$container_exists=$?

if ($container_exists) {
    Write-Output "Postgres exists"
    $container_state = docker inspect -f '{{.State.Status}}' postgres-db
    if ($container_state -eq "running") {
        Write-Output "Postgres running"
    } else {
        Write-Output "Postgres not running"
        Write-Output "Starting Postgres containers"
        docker compose -f $env:USERPROFILE/dev/github.com/ucldk/databases/postgres-compose.yml up -d
    }
} else {
    Write-Output "Postgres does not exist"
    Write-Output "Starting Postgres containers"
    docker compose -f $env:USERPROFILE/dev/github.com/ucldk/databases/postgres-compose.yml up -d
}


# Copy .sql files to container
docker cp Test_data postgres-db:/tmp/
docker cp 0-show-db-contents.sql postgres-db:/tmp/
docker cp 1-subqueries.sql postgres-db:/tmp/
docker cp 2-views.sql postgres-db:/tmp/
docker cp 3-functions.sql postgres-db:/tmp/
docker cp 4-stored-procedures.sql postgres-db:/tmp/
docker cp 5-transactions.sql postgres-db:/tmp/
docker cp 5-transactions-pizzageddon.sql postgres-db:/tmp/

# Recreate database
function recreate_db {
    docker exec postgres-db dropdb --force --if-exists day3_assignments
    docker exec postgres-db psql -d postgres -c "CREATE DATABASE day3_assignments" -q
    # Initialize database
    docker exec -w /tmp/Test_data postgres-db psql -d day3_assignments -f dfu-03-education-db.sql *> $null
}
recreate_db
Write-Output "################"
Write-Output "First assignment"
Write-Output "################"
docker exec -w /tmp/Test_data postgres-db psql -d day3_assignments -f extra-data.sql -q
#docker exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
docker exec -w /tmp postgres-db psql -d day3_assignments -f 1-subqueries.sql

Write-Output "#################"
Write-Output "Second assignment"
Write-Output "#################"
Write-Output "Resetting database (removing the extra data for the first assignment)"
recreate_db
#docker exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
docker exec -w /tmp postgres-db psql -d day3_assignments -f 2-views.sql -q

Write-Output "################"
Write-Output "Third assignment"
Write-Output "################"
#docker exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
docker exec -w /tmp postgres-db psql -d day3_assignments -f 3-functions.sql -q

Write-Output "#################"
Write-Output "Fourth assignment"
Write-Output "#################"
Write-Output "Resetting database (removing the updates from the third assignment)"
recreate_db
#docker exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
docker exec -w /tmp postgres-db psql -d day3_assignments -f 4-stored-procedures.sql -q

Write-Output "################"
Write-Output "Fifth assignment"
Write-Output "################"
docker exec -w /tmp postgres-db psql -d day3_assignments -f 0-show-db-contents.sql
docker exec -w /tmp postgres-db psql -d day3_assignments -f 5-transactions.sql -q

Push-Location ..\..\Day2\Pizzageddon\
    docker cp DDL postgres-db:/tmp/
    docker cp DML postgres-db:/tmp/
    docker cp SQL postgres-db:/tmp/

    docker exec postgres-db dropdb --force --if-exists pizzageddon
    docker exec postgres-db psql -d postgres -c "CREATE DATABASE pizzageddon" -q
    docker exec -w /tmp/DDL postgres-db psql -d pizzageddon -f schema.sql -q
    docker exec -w /tmp/DML postgres-db psql -d pizzageddon -f seed.sql -q
Pop-Location

docker exec -w /tmp postgres-db psql -d pizzageddon -f 5-transactions-pizzageddon.sql -q
