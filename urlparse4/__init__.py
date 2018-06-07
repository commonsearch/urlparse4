# https://github.com/python/cpython/blob/2.7/Lib/urlparse.py

import six

from six.moves.urllib.parse import urlparse, urlsplit, urljoin


_original_urlsplit = urlsplit
_original_urljoin = urljoin

from cgurl import url_split, url_join
