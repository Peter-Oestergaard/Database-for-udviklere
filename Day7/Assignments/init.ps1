$projectname="day7-assignment"

Write-Output "Making sure containers are running"
docker compose --project-name $projectname up -d

docker compose --project-name $projectname cp DDL postgres:/tmp/
docker compose --project-name $projectname cp DML postgres:/tmp/

docker compose --project-name $projectname exec postgres dropdb --force --if-exists "newssite"
docker compose --project-name $projectname exec postgres psql -d postgres -c "CREATE DATABASE newssite"
docker compose --project-name $projectname exec -w /tmp/DDL postgres psql -d "newssite" -f schema.sql
docker compose --project-name $projectname exec -w /tmp/DML postgres psql -d "newssite" -f seed.sql