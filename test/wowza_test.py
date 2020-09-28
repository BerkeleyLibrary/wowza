import os
import pathlib
import unittest
import urllib.request
import xml.etree.ElementTree as et
from functools import cached_property


class WowzaTest(unittest.TestCase):

    # ------------------------------
    # Test runner

    @staticmethod
    def runTests():
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(WowzaTest)
        return unittest.TextTestRunner().run(suite)

    # ------------------------------
    # Fixture

    wowza_home = pathlib.Path(__file__).parent.parent.absolute()
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
    def apps_dir(self):
        if WowzaTest.wowza_engine_dir.is_dir():
            return WowzaTest.wowza_engine_dir / 'applications'
        return WowzaTest.wowza_home / 'applications'

    def open(self, url):
        return self.url_opener.open(url)

    def get(self, url):
        with self.open(url) as response:
            return response.read().decode('utf-8')

    def get_xml(self, url):
        body = self.get(url)
        return et.fromstring(body)

    # ------------------------------
    # Tests

    def test_api_endpoint(self):
        with self.open(WowzaTest.base_url) as response:
            self.assertEqual(response.status, 200)

    def test_applications(self):
        url = WowzaTest.base_url + 'v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications'
        root = self.get_xml(url)

        applications_expected = {f for f in os.listdir(self.apps_dir) if (self.apps_dir / f).is_dir()}

        applications_actual = set()
        for app in root.findall('./Application'):
            applications_actual.add(app.attrib['id'])

        self.assertEqual(len(applications_actual), len(applications_expected))
        self.assertEqual(applications_actual, applications_expected)
