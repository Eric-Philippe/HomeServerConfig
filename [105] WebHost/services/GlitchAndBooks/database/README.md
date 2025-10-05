# Glitch & Books Database

All the dabase is used with the help of TypeORM on a PostgreSQL database.

## Why it's not in the docker compose file ?

My main goal with docker here was to be able to transfer and launch the prod' version of my project, staying with the same databse.
I did not feel the need to have a local database for dev' purposes, so I just used the same database for both dev' and prod' !

## Links

- [TypeORM](https://typeorm.io/#/)
- [PostgreSQL](https://www.postgresql.org/)
- [Docker](https://www.docker.com/)

## How to use it ?

Check the .server/.env.example file to see how to configure your database.
