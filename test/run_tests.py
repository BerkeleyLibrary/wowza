#!/usr/bin/env python3

# -*- coding: utf-8 -*-
"""run_tests.py

To be used as a Docker command when running the Wowza server and tests in a
standalone container. This script:

1. starts the Wowza server using ``bin/start-server.sh``
2. waits for the server to start (as indicated by the ``REST API: ready``
   message in the server's output)
3. runs the tests in ``wowza_test.py``
4. stops the server
"""

import os
import pathlib
import subprocess
import sys

from tests import wowza_test

os.environ['WOWZA_MANAGER_PASSWORD'] = 'wowza'  # TODO: is this a good idea?

APP_ROOT = pathlib.Path('/opt/app/')
SERVER_SH = APP_ROOT / 'bin' / 'start-server.sh'
REPORTS_DIR = APP_ROOT / 'artifacts' / 'unittest'
TIMEOUT_SECONDS = 60


def log(msg):
    print(msg, file=sys.stderr)


def start_server():
    log(f"Starting Wowza server with %s" % SERVER_SH)
    process = subprocess.Popen(SERVER_SH, stdout=subprocess.PIPE, encoding='utf8')
    for line in process.stdout:
        if 'REST API: ready' in line:
            log("Wowza server started")
            break
    return process


def ensure_reports_dir():
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    return REPORTS_DIR


def main():
    process = start_server()
    status = process.poll()
    try:
        if status is not None:
            log(f"%s exited with %d" % (SERVER_SH, status))
            exit(1)

        reports_dir = ensure_reports_dir()
        report_file = reports_dir / 'wowza_test.xml'

        log(f"Writing test report to {report_file}")
        result = wowza_test.WowzaTest.runTestsWithXMLReport(report_file)
        if not result.wasSuccessful():
            exit(1)

    finally:
        log("Stopping Wowza server")
        process.terminate()
        process.wait(TIMEOUT_SECONDS)
        log("Wowza server stopped")


if __name__ == "__main__":
    main()
