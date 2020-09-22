#!/usr/bin/env python3
import os
import pathlib
import subprocess
import sys

import wowza_test

TIMEOUT_SECONDS = 60

os.environ['WOWZA_MANAGER_PASSWORD'] = 'wowza'  # TODO: is this a good idea?

project_dir = pathlib.Path(__file__).parent.parent.absolute()
server_sh = project_dir / 'bin' / 'docker-entrypoint-server.sh'


def start_server():
    print(f"Starting server with %s" % server_sh, file=sys.stderr)
    process = subprocess.Popen(server_sh, stdout=subprocess.PIPE, encoding='utf8')
    for line in process.stdout:
        if 'REST API: ready' in line:
            break
    return process


def main():
    process = start_server()
    status = process.poll()
    try:
        if status is not None:
            print(f"%s exited with %d" % (server_sh, status), file=sys.stderr)
            exit(1)

        result = wowza_test.WowzaTest.runTests()
        if not result.wasSuccessful():
            exit(1)

    finally:
        process.terminate()
        process.wait(TIMEOUT_SECONDS)


if __name__ == "__main__":
    main()
