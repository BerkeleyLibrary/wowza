#!/usr/bin/env python3
import json
import urllib.request
from functools import cached_property


class Tag:
    def __init__(self, data: dict):
        self.data = data

    @cached_property
    def name(self):
        return self.data['name']

    @cached_property
    def digest(self):
        return self.digest_for('amd64')

    def digest_for(self, architecture):
        for image in self.data['images']:
            if image['architecture'] == architecture:
                return image['digest']


def get_tags():
    tags_url = 'https://hub.docker.com/v2/repositories/wowzamedia/wowza-streaming-engine-linux/tags/?page_size=1000'
    with urllib.request.urlopen(tags_url) as response:
        data = response.read()
        encoding = response.info().get_content_charset('utf-8')
        doc = json.loads(data.decode(encoding))
        return list(Tag(result) for result in doc['results'])


def get_latest_version():
    tags = get_tags()
    latest_tag = next(tag for tag in tags if tag.name == 'latest')
    assert latest_tag is not None, 'No latest tag found'

    latest_digest = latest_tag.digest
    latest_version_tag = next(tag for tag in tags if tag.name != 'latest' and tag.digest == latest_digest)
    assert latest_version_tag is not None, f'No versioned tag found for digest %s' % latest_digest

    return latest_version_tag.name


def main():
    latest_version = get_latest_version()
    print(latest_version)


if __name__ == "__main__":
    main()
