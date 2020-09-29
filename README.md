# Wowza

This is the containerized UC Berkeley Library installation of the
[Wowza](https://www.wowza.com/) commercial media server.

For the old standalone installation and associated code, see the
[lap/wowza-legacy](https://git.lib.berkeley.edu/lap/wowza-legacy) project.

## Structure of this stack

The stack consists of a single container, in which runs both
the Wowza streaming media engine application, and the Wowza
streaming engine manager UI (as in a typical uncontainerized
Wowza installation).

## Development

1. Build the Docker stack with

   ```sh
   docker-compose build --pull
   ```

2. From the project root directory, start the Docker stack with

   ```sh
   docker-compose up
   ```

To log into the container with an interactive shell:

```sh
docker exec -it -u wowza -w /usr/local/WowzaStreamingEngine wowza /bin/bash
```
  
### Accessing Wowza Streaming Engine Manager

To access Wowza Streaming Engine Manager, use the URL 
[`http://localhost:8088/enginemanager/login.htm`](http://localhost:8088/enginemanager/login.htm)
with username and password specified as `$WOWZA_MANAGER_USER` and `$WOWZA_MANAGER_PASSWORD` in [.env](.env)

## Testing

See the [README](test/README.md) in the test directory.
