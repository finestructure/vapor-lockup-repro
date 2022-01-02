ARCH := $(shell arch)

db-up:
	docker run --name repro-db -e POSTGRES_DB=spi_dev -e POSTGRES_USER=spi_dev -e POSTGRES_PASSWORD=xxx -p 7432:5432 -d postgres:13.5-alpine

db-down:
	docker rm -f repro-db

migrate:
	echo y | swift run Run migrate

reset-db: db-down db-up migrate

run:
	swift run Run serve

docker-build:
ifeq ($(ARCH),arm64)
	docker build -t pg-dump-repro -f Dockerfile.arm .
else
	docker-compose build
endif

docker-run:
	docker-compose up

routes:
	swift run Run routes

post:
	# while true ; do env title=$$(date +'%Y%m%d-%H%M%S') rester restfiles/post.restfile ; done
	env title=$$(date +'%Y%m%d-%H%M%S') rester --loop 0 restfiles/post.restfile

get:
	while true ; do rester restfiles/get.restfile ; sleep 1 ; done
	# rester --loop 0 restfiles/get.restfile

dump:
	time PGPASSWORD=xxx pg_dump --no-owner -Fc -h localhost -p 7432 -U spi_dev spi_dev > local_db.dump
	@ls -lh local_db.dump
