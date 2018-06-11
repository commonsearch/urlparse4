import six

if six.PY2:
    from urlparse import *
else:
    from urllib.parse import *
    from urllib.parse import Quoter, _ALWAYS_SAFE


_original_urlsplit = urlsplit
_original_urljoin = urljoin

from cgurl import urlsplit, urljoin
