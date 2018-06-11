# https://github.com/python/cpython/blob/2.7/Lib/urlparse.py

import six

if six.PY2:
    from urlparse import *
else:
    from urllib.parse import *


_original_urlsplit = urlsplit
_original_urljoin = urljoin

from cgurl import urlsplit, urljoin
