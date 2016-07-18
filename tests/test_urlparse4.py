# https://github.com/python/cpython/blob/40dac3272231773af0015fc35df5353783d77c4e/Lib/test/test_urlparse.py
import sys
import os
sys.path.insert(-1, os.path.dirname(os.path.dirname(__file__)))

from test import test_support
import unittest
import urlparse4 as urlparse


urlsplit_testcases = [
    ["mailto:webtechs@oltn.odl.state.ok.us", ("mailto", "webtechs@oltn.odl.state.ok.us", "", "", "")],
    ["mailto:mailto:webtechs@oltn.odl.state.ok.us", ("mailto", "mailto:webtechs@oltn.odl.state.ok.us", "", "", "")],
    ["http://a@example.com:80", ("http", "a@example.com:80", "", "", "")],

]

urljoin_testcases = [
    [("", "http://example.com"), "http://example.com"]
]


class UrlParse4TestCase(unittest.TestCase):

    def test_urlsplit(self):
        for case in urlsplit_testcases:
            self.assertEqual(urlparse.urlsplit(case[0]), case[1])

    def test_urljoin(self):
        for case in urljoin_testcases:
            self.assertEqual(urlparse.urljoin(*case[0]), case[1])
