# Conventions

This machine will hold all the services in production, so a few conventions can be applied

> No testing container should be put in this VM

## Naming conventions

Any service name will always be in lower-case
Any service should start either with "wp-", "server-" or "bot-"
If it's the main service then just the name of it should comes next
Ex: bot-cril
If it's a secondary service (Database ...) then just add a keyword (db-) then the name of the service
Ex: bot-db-cril

## Ports conventions

All the services are managed by a reverse proxy on the hypervisor, so we're kind of free about how we use the ports
By convention:

Wordpress services: 4000 - 4999
Websites: 8000 - 8999
Bots: 5000-5999
Others: 6000-6999

Portainer agent is using the 9001

At the end all the ports will be read from the hypervisor receiving only Https (443)
