# Test project to reproduce a lockup in Vapor

The issue was first observed when backing up the SPI database during operation. Running `pg_dump` would cause the site to return 500s.

This project reproduces the issue with the default Vapor app template and its Todo table.

The `Makefile` contains some basic commands we'll use to trigger the lockup.

## Prerequisites

- docker to bring up the local PG database
- `rester`, a [API scripting tool](https://github.com/finestructure/rester)

Installation of Rester either via

```
git clone https://github.com/finestructure/rester
cd rester
swift build -c release
```

or

```
brew install mint
mint install finestructure/rester
```

## Triggering the error

It should suffice to run three processes in three terminal windows:

```
make db-up migrate
make run
```

to bring up the server

```
make get
```

to start a request loop that continuously fetches batches of 50 todos.

```
make post & ; make post & ; make post & ; make post & ; make post & ; make post & ; make post & ; make post & ; make post & ; make post & ; make post & ; make post &
```

to start a barrage of post requests adding new Todos. Depending on the machine the error may require additional or fewer `make post` jobs.

The error should manifest itself by first one and then the other terminals running into timeouts:

```
🎬  todos started ...

❌  Error: request timed out: todos
make: *** [get] Error 1
```

At this point everything comes to a standstill and even opening the *static* page localhost:8080/ in a browser (which should simply display "It works!" without any db access) hangs and does not load.

If forcing the error proves to be problematic, running

```
make dump
```

to `pg_dump` the database in parallel to the read and write jobs should do the trick.
