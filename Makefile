db-up:
	docker run --name repro-db -e POSTGRES_DB=spi_dev -e POSTGRES_USER=spi_dev -e POSTGRES_PASSWORD=xxx -p 7432:5432 -d postgres:11.6-alpine

db-down:
	docker rm -f repro-db

migrate:
	echo y | swift run Run migrate

reset-db: db-down db-up migrate

run:
	swift run Run serve

routes:
	swift run Run routes

post:
	env title=$$(date +'%Y%m%d-%H%M%S') rester --loop 0 restfiles/post.restfile

get:
	rester --loop 0 restfiles/get.restfile

dump:
	PGPASSWORD=xxx pg_dump --no-owner -Fc -h localhost -p 7432 -U spi_dev spi_dev > local_db.dump
