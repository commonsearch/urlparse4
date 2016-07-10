# https://github.com/python/cpython/blob/2.7/Lib/urlparse.py

from urlparse import *

_original_urlsplit = urlsplit
_original_urljoin = urljoin

from cgurl import urlsplit, urljoin
