import os
import pathlib
import re
import sys
import unittest
import urllib.request
import xml.etree.ElementTree as et
from functools import cached_property

import xmlrunner

from .docker_tag import DockerTag


class WowzaTest(unittest.TestCase):

    # ------------------------------
    # Test runner

    @classmethod
    def runTests(cls):
        return unittest.TextTestRunner().run(cls.all_tests())

    @classmethod
    def runTestsWithXMLReport(cls, report_file):
        with open(report_file, 'wb') as report:
            test_runner = xmlrunner.XMLTestRunner(output=report, failfast=False)
            result = test_runner.run(cls.all_tests())
        return result

    @classmethod
    def all_tests(cls):
        return unittest.defaultTestLoader.loadTestsFromTestCase(cls)

    # ------------------------------
    # Fixture

    wowza_version_re = re.compile('[^ ]+(?= build[^ ]+$)')
    wowza_engine_dir = pathlib.Path('/usr/local/WowzaStreamingEngine')

    base_url: str = 'http://localhost:8087/'

    @cached_property
    def url_opener(self):
        username = os.environ.get('WOWZA_MANAGER_USER', 'wowza')
        password = os.environ.get('WOWZA_MANAGER_PASSWORD')
        self.assertIsNotNone(password, 'WOWZA_MANAGER_PASSWORD not set')
        password_mgr = urllib.request.HTTPPasswordMgr()
        password_mgr.add_password('Wowza', WowzaTest.base_url, username, password)
        auth_handler = urllib.request.HTTPDigestAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)
        return opener

    @cached_property
    def project_root(self):
        p = pathlib.Path(__file__)
        while True:
            if p.name == 'test':
                return p.parent
            self.assertNotEquals(p.name, '', "Unable to locate project root")

    @cached_property
    def apps_dir(self):
        if WowzaTest.wowza_engine_dir.is_dir():
            return WowzaTest.wowza_engine_dir / 'applications'
        return self.project_root() / 'applications'

    def open(self, url):
        return self.url_opener.open(url)

    def get(self, url):
        with self.open(url) as response:
            return response.read().decode('utf-8')

    def get_xml(self, url):
        body = self.get(url)
        return et.fromstring(body)

    def get_wowza_version(self):
        body = self.get(WowzaTest.base_url)
        match = WowzaTest.wowza_version_re.search(body)
        self.assertIsNotNone(match, f"Couldn't get container Wowza version; GET {WowzaTest.base_url} returned {body}")
        return match.group()

    # ------------------------------
    # Tests

    def test_api_endpoint(self):
        with self.open(WowzaTest.base_url) as response:
            self.assertEqual(response.status, 200)

    def test_wowza_version(self):
        container_wowza_version = self.get_wowza_version()
        latest_version_tag = DockerTag.get_latest_version_tag('wowzamedia/wowza-streaming-engine-linux')
        latest_version = latest_version_tag.name

        # TODO: find a way to mark the build unstable rather than failed, if this fails
        # self.assertEqual(container_wowza_version, latest_version)

        if container_wowza_version != latest_version:
            msg = "WARNING: current Wowza version is %s, but latest is %s" % (container_wowza_version, latest_version)
            print(msg, file=sys.stderr)

    def test_applications(self):
        url = WowzaTest.base_url + 'v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications'
        root = self.get_xml(url)

        applications_expected = {f for f in os.listdir(self.apps_dir) if (self.apps_dir / f).is_dir()}

        applications_actual = set()
        for app in root.findall('./Application'):
            applications_actual.add(app.attrib['id'])

        self.assertEqual(len(applications_actual), len(applications_expected))
        self.assertEqual(applications_actual, applications_expected)
