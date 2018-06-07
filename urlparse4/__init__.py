# https://github.com/python/cpython/blob/2.7/Lib/urlparse.py

import six
import pyximport

from six.moves.urllib.parse import urlparse, urlsplit, urljoin


_original_urlsplit = urlsplit
_original_urljoin = urljoin

pyximport.install()
from cgurl import urlsplit, urljoin
