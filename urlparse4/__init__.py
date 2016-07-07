# https://github.com/python/cpython/blob/2.7/Lib/urlparse.py

from urlparse import *
from collections import namedtuple as __namedtuple

import pygurl as __pygurl

__urlsplit_result_namedtuple = __namedtuple('result', ['scheme', 'netloc', 'path', 'query', 'fragment', 'username', 'password', 'hostname', 'port'])


class __ResultMixin(object):
    """Shared methods for the parsed result objects."""

    @property
    def username(self):
        netloc = self.netloc
        if "@" in netloc:
            userinfo = netloc.rsplit("@", 1)[0]
            if ":" in userinfo:
                userinfo = userinfo.split(":", 1)[0]
            return userinfo
        return None

    @property
    def password(self):
        netloc = self.netloc
        if "@" in netloc:
            userinfo = netloc.rsplit("@", 1)[0]
            if ":" in userinfo:
                return userinfo.split(":", 1)[1]
        return None

    @property
    def hostname(self):
        netloc = self.netloc.split('@')[-1]
        if '[' in netloc and ']' in netloc:
            return netloc.split(']')[0][1:].lower()
        elif ':' in netloc:
            return netloc.split(':')[0].lower()
        elif netloc == '':
            return None
        else:
            return netloc.lower()

    @property
    def port(self):
        netloc = self.netloc.split('@')[-1].split(']')[-1]
        if ':' in netloc:
            port = netloc.split(':')[1]
            if port:
                port = int(port, 10)
                # verify legal port
                if (0 <= port <= 65535):
                    return port
        return None


class __SplitResult(__namedtuple('SplitResult', 'scheme netloc path query fragment'), __ResultMixin):

    __slots__ = ()

    def geturl(self):
        return urlunsplit(self)


def urlsplit(url):  # , scheme='', allow_fragments=True):
    res = __pygurl.ParseStandard(url)

    netloc = res.host
    if res.port:
        netloc += ":" + str(res.port)
    if res.username and res.password:
        netloc = "%s:%s@%s" % (res.username, res.password, netloc)

    return __SplitResult(
        res.scheme.lower(),
        netloc,
        res.path,
        res.query,
        res.ref
    )


def urljoin(base, url):  # , allow_fragments=True):
    return __pygurl.URL(base).Resolve(url)
