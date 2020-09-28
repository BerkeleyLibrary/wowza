#!/usr/bin/env python3
import os
import sys
import urllib.request
import xml.etree.ElementTree as et
from functools import cached_property
from urllib.parse import urljoin


class WowzaClient:
    base_url: str = 'http://localhost:8087/'

    def __init__(self, out=sys.stdout):
        self.out = out

    @cached_property
    def url_opener(self):
        username = os.environ.get('WOWZA_MANAGER_USER', 'wowza')
        password = os.environ.get('WOWZA_MANAGER_PASSWORD')
        assert password is not None, 'WOWZA_MANAGER_PASSWORD not set'
        password_mgr = urllib.request.HTTPPasswordMgr()
        password_mgr.add_password('Wowza', WowzaClient.base_url, username, password)
        auth_handler = urllib.request.HTTPDigestAuthHandler(password_mgr)
        opener = urllib.request.build_opener(auth_handler)
        return opener

    def open(self, url):
        return self.url_opener.open(url)

    def get(self, url):
        with self.open(url) as response:
            return response.read().decode('utf-8')

    def get_xml(self, url):
        body = self.get(url)
        return et.fromstring(body)

    def list_applications(self):
        apps_url = urljoin(WowzaClient.base_url, '/v2/servers/_defaultServer_/vhosts/_defaultVHost_/applications')
        apps_root = self.get_xml(apps_url)

        for app in apps_root.findall('./Application'):
            app_id = app.attrib['id']
            app_href = app.attrib['href']
            app_url = urljoin(WowzaClient.base_url, app_href)
            app_root = self.get_xml(app_url)
            storage_dirs = (sd.text for sd in app_root.findall('.//StreamConfig/StorageDir'))
            print("%s\t%s" % (app_id, ', '.join(storage_dirs)), file=self.out)


def main():
    if len(sys.argv) > 2:
        sys.exit('Usage: list-applications.py [output-file]')
    elif len(sys.argv) == 2:
        output_file = sys.argv[1]
        with open(output_file) as out:
            WowzaClient(out).list_applications()
    else:
        WowzaClient().list_applications()


if __name__ == "__main__":
    main()
