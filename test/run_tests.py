#!/usr/bin/env python3

# -*- coding: utf-8 -*-
"""run_tests.py

To be used as a Docker command when running the Wowza server and tests in a
standalone container. This script:

1. starts the Wowza server using ``bin/docker-entrypoint-server.sh``
2. waits for the server to start (as indicated by the ``REST API: ready``
   message in the server's output)
3. runs the tests in ``wowza_test.py``
4. stops the server
"""

import os
import pathlib
import subprocess
import sys

import wowza_test

TIMEOUT_SECONDS = 60

os.environ['WOWZA_MANAGER_PASSWORD'] = 'wowza'  # TODO: is this a good idea?

project_dir = pathlib.Path(__file__).parent.parent.absolute()
server_sh = project_dir / 'bin' / 'docker-entrypoint-server.sh'


def log(msg):
    print(msg, file=sys.stderr)


def start_server():
    log(f"Starting Wowza server with %s" % server_sh)
    process = subprocess.Popen(server_sh, stdout=subprocess.PIPE, encoding='utf8')
    for line in process.stdout:
        if 'REST API: ready' in line:
            log("Wowza server started")
            break
    return process


def main():
    process = start_server()
    status = process.poll()
    try:
        if status is not None:
            log(f"%s exited with %d" % (server_sh, status))
            exit(1)

        result = wowza_test.WowzaTest.runTests()
        if not result.wasSuccessful():
            exit(1)

    finally:
        log("Stopping Wowza server")
        process.terminate()
        process.wait(TIMEOUT_SECONDS)
        log("Wowza server stopped")


if __name__ == "__main__":
    main()
