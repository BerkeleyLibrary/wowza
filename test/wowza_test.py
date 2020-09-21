import os
import unittest
import urllib.request


class WowzaTest(unittest.TestCase):

    def test_api_endpoint(self):
        base_url = 'http://localhost:8087/'
        username = os.environ.get('WOWZA_MANAGER_USER', 'wowza')
        password = os.environ.get('WOWZA_MANAGER_PASSWORD')
        self.assertIsNotNone(password, 'WOWZA_MANAGER_PASSWORD not set')

        password_mgr = urllib.request.HTTPPasswordMgr()
        password_mgr.add_password('Wowza', base_url, username, password)
        auth_handler = urllib.request.HTTPDigestAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)

        with opener.open(base_url) as response:
            self.assertEqual(response.status, 200)

    @staticmethod
    def runTests():
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(WowzaTest)
        return unittest.TextTestRunner().run(suite)

