# WebHost services

This directory contains the docker compose files for services hosted on the WebHost server.

## Global services

> Created the ``proxy`` network for Traefik and other services to use:

```bash
$ docker network create proxy
```

| Service Name       | Description                                      |  Port  |
|--------------------|--------------------------------------------------|--------|
| Traefik             | Reverse proxy and load balancer                  | 80,443 |
| Portainer          | Docker management node                           |  9000  |

## Individual services

### Directory structure

- Each service has its own subdirectory with a `docker-compose.yml` file.

```
services/
├── Service1/
│   └── docker-compose.yml
├────── .env
├────── folderMounts/
```

### Naming conventions

- Each service's `docker-compose.yml` file should define a unique `container_name` for each container to avoid conflicts.
- They should start with the service name as a prefix and the type of service as a suffix (e.g., `service1-web`, `service1-db`).
- Try consistent naming conventions for types of services:
- - Web servers (API/web interface): `-server`
- - Databases: `-db`
- - Caches: `-cache`
- - Bot services: `-bot`


### Network

- No compose should expose ports to the host unless absolutely necessary. All opened services should be proxied through Traefik.
- All services should be connected to the `proxy` network for Traefik to route traffic to them if needed.

```yml
services:
  service1:
    image: service1:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.service1.rule=Host(`service1.example.com`)"
      - "traefik.http.routers.service1.entrypoints=websecure"
      - "traefik.http.routers.service1.tls=true"
    networks:
      - proxy

networks:
  proxy:
    external: true
```

### Credentials and environment variables

- Compose shouldn't have credentials or sensitive information hardcoded. Use environment variables or Docker secrets instead.
- Use a `.env` file in the service directory to store environment variables.

```.env
ENV_VAR1=value1
```

```yml
services:
  service1:
    image: service1:latest
    env_file:
      - .env

  services2:
    image: service2:latest
    environment:
      - ENV_VAR1=${ENV_VAR1}
```

### Images management

- Images best practices:
  - All the images size should be as small as possible. Prefer Alpine-based images when available.
  - Delete build tools and unnecessary packages in custom Dockerfiles.
  - The WebHost shouldn't build images, we should only use pre-built images from GHCR, Docker Hub, or other registries.
  - Should use the same image tag across services when possible to simplify updates and avoid duplicates (e.g., `postgres`...)

#### List of common images

| Service Type | Image               | Tag        |
|--------------|---------------------|------------|
| MySQL        | mysql               | 8.0        |
| PostgreSQL   | postgres            | 16         |
| Redis        | redis               | 8-alpine   |

### Restart policy

- All the services should specify the `restart` policy, to ensure they are restarted if they crash or the server reboots.

### Common services

A common service is a stack of services that can be shared between multiple services. For example, a common database or cache service for non-critical services.

### Utils

Rename volumes:

```bash
docker volume create --name new-volume-db-data && docker run --rm -it -v old-volume-db-data:/from -v new-volume-db-data:/to alpine ash -c 'cd /from ; cp -av . /to' && docker volume rm old-volume-db-data
```

Where `old_volume_name` is the old volume name and `new_volume_name` is the new volume name.
