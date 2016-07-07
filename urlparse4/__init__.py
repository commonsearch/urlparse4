# https://github.com/python/cpython/blob/2.7/Lib/urlparse.py

from urlparse import *

_original_urlsplit = urlsplit
_original_urljoin = urljoin

from gurl import urlsplit

import pygurl as __pygurl

def urljoin(base, url, allow_fragments=True):
    if allow_fragments:
        joined = __pygurl.URL(base).Resolve(url)
        # if joined.endswith("/") and not url.endswith("/") and ((url.startswith("//") and url.count("/") in (2, 3))):
        #     return joined[:-1]
        return joined
    else:
        return _original_urljoin(base, url, allow_fragments=allow_fragments)
