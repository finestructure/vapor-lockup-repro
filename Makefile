db-up:
	docker run --name repro-db -e POSTGRES_DB=spi_dev -e POSTGRES_USER=spi_dev -e POSTGRES_PASSWORD=xxx -p 7432:5432 -d postgres:11.6-alpine

db-down:
	docker rm -f repro-db

migrate:
	echo y | swift run Run migrate

reset-db: db-down db-up migrate

run:
	swift run Run serve
