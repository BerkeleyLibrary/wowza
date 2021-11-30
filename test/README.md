# Tests

The tests in this directory are intended to be run against a live Wowza server located
at `localhost`, with the REST API available at port `8087`. The directory is copied to
`/opt/app/test` in the container.

## Testing against a running container

The test can be run against a Wowza server running in a container.

### Starting the server

From the project root directory, in one terminal:

```sh
docker-compose up
```

### Running the tests

From the project root directory, in another terminal, you can:

- run the tests on the host (requires installing the [`xmlrunner`](https://pypi.org/project/xmlrunner/) module with `pip3`):

  ```sh
  WOWZA_MANAGER_PASSWORD=wowza python3 -m unittest discover -p "*_test.py"
  ```

- run the tests in-container with the server:

  ```sh
  docker-compose exec wowza python3 -m unittest discover -s /opt/app -p "*_test.py"
  ```

## Testing in a standalone container

Alternatively, you can run the tests and server in the same container (as the Jenkins build
does). Note that this does not require exposing any ports to the host.

```sh
docker-compose run wowza /opt/app/test/run_tests.py
```

In this case, remember to rebuild the `wowza` container before testing, to make sure your latest
additions to the test suite are included.
 
