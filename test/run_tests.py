#!/usr/bin/env python3

# -*- coding: utf-8 -*-
"""run_tests.py

To be used as a Docker command when running the Wowza server and tests in a
standalone container. This script runs the tests in ``wowza_test.py``  and
generates JUnit-compatible xml reports.
"""

import os
import pathlib
import sys

from tests import wowza_test


APP_ROOT = pathlib.Path('/opt/app/')
REPORTS_DIR = APP_ROOT / 'artifacts' / 'unittest'
TIMEOUT_SECONDS = 60


def log(msg):
    print(msg, file=sys.stderr)


def ensure_reports_dir():
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    return REPORTS_DIR


def main():
    reports_dir = ensure_reports_dir()
    report_file = reports_dir / 'wowza_test.xml'

    log(f"Writing test report to {report_file}")
    result = wowza_test.WowzaTest.runTestsWithXMLReport(report_file)
    if not result.wasSuccessful():
        exit(1)


if __name__ == "__main__":
    main()
