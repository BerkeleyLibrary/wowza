# Tests

The tests in this directory are intended to be run against a live Wowza server located
at `localhost`, with the REST API available at port `8087`. The directory is copied to
`/home/wowza/test` in the container.

## Testing locally

The test can be run locally against a Wowza server running in a container. To start the
server, you can either use `docker-compose up` to start the entire development stack,
or `docker run` to start just the server. Both the server and tests require the
`WOWZA_MANAGER_PASSWORD` environment variable to be set. 

### Starting the server

From the project root directory, in one terminal:

```sh
docker run -e WOWZA_MANAGER_PASSWORD=wowza -p 127.0.0.1:8087:8087/tcp wowza
```

### Running the tests

From the project root directory, in another terminal:

```sh
WOWZA_MANAGER_PASSWORD=wowza python3 -m unittest -v test/wowza_test.py
```

## Testing in a container

Alternatively, you can run the tests and server in the same container (as the Jenkins build
does). Note that this does not require exposing any ports to the host.

```
docker run -e WOWZA_MANAGER_PASSWORD=wowza wowza /home/wowza/test/run_tests.py
```

Remember to rebuild the `wowza` container before testing, to make sure your latest
additions to the test suite are included.
 
