# Wowza

This is the containerized UC Berkeley Library installation of the
[Wowza](https://www.wowza.com/) commercial media server.

For the old standalone installation and associated code, see the
[lap/wowza-legacy](https://git.lib.berkeley.edu/lap/wowza-legacy) project.

## Development

1. Build the Docker stack with

   ```sh
   docker-compose build --pull
   ```

2. From the project root directory, start the Docker stack with

   ```sh
   docker-compose up
   ```

To log into the containers with an interactive shell:

- server: 

  ```sh
  docker exec -it -u wowza -w /usr/local/WowzaStreamingEngine wowza-server /bin/bash
  ```
  
- manager:

  ```sh
  docker exec -it -u wowza -w /usr/local/WowzaStreamingEngine wowza-manager /bin/bash
  ```

### Accessing Wowza Streaming Engine Manager

To access Wowza Streaming Engine Manager, use the URL 
[`http://localhost:8088/enginemanager/login.htm?host=http://wowza-server:8087`](http://localhost:8088/enginemanager/login.htm?host=http://wowza-server:8087)
with username and password specified as `$WOWZA_MANAGER_USER` and `$WOWZA_MANAGER_PASSWORD` in [.env](.env)
