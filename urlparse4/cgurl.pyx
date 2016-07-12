from urlparse4.mozilla_url_parse cimport Component, Parsed, ParseStandardURL, ParseFileURL
from chromium_gurl cimport GURL
import urlparse as stdlib_urlparse
cimport cython

cdef bytes slice_component(bytes pyurl, Component comp):
    if comp.len <= 0:
        return b""

    return pyurl[comp.begin:comp.begin + comp.len]


cdef bytes cslice_component(char * url, Component comp):
    if comp.len <= 0:
        return b""

    # TODO: check if std::string brings any speedups
    return url[comp.begin:comp.begin + comp.len]


cdef bytes build_netloc(bytes url, Parsed parsed):

    if parsed.host.len <= 0:
        return b""

    # Nothing at all
    elif parsed.username.len <= 0 and parsed.password.len <= 0 and parsed.port.len <= 0:
        return url[parsed.host.begin: parsed.host.begin + parsed.host.len]

    # Only port
    elif parsed.username.len <= 0 and parsed.password.len <= 0 and parsed.port.len > 0:
        return url[parsed.host.begin: parsed.host.begin + parsed.host.len + 1 + parsed.port.len]

    # Only username
    elif parsed.username.len > 0 and parsed.password.len <= 0 and parsed.port.len <= 0:
        return url[parsed.username.begin: parsed.username.begin + parsed.host.len + 1 + parsed.username.len]

    # Username + password
    elif parsed.username.len > 0 and parsed.password.len > 0 and parsed.port.len <= 0:
        return url[parsed.username.begin: parsed.username.begin + parsed.host.len + 2 + parsed.username.len + parsed.password.len]

    # Username + port
    elif parsed.username.len > 0 and parsed.password.len <= 0 and parsed.port.len > 0:
        return url[parsed.username.begin: parsed.username.begin + parsed.host.len + 2 + parsed.username.len + parsed.port.len]

    # Username + port + password
    elif parsed.username.len > 0 and parsed.password.len > 0 and parsed.port.len > 0:
        return url[parsed.username.begin: parsed.username.begin + parsed.host.len + 3 + parsed.port.len  + parsed.username.len  + parsed.password.len]

    else:
        raise ValueError


# @cython.freelist(100)
# cdef class SplitResult:

#     cdef Parsed parsed
#     # cdef char * url
#     cdef bytes pyurl

#     def __cinit__(self, char* url):
#         # self.url = url
#         self.pyurl = url
#         if url[0:5] == b"file:":
#             ParseFileURL(url, len(url), &self.parsed)
#         else:
#             ParseStandardURL(url, len(url), &self.parsed)

#     property scheme:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.scheme)

#     property path:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.path)

#     property query:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.query)

#     property fragment:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.ref)

#     property username:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.username)

#     property password:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.password)

#     property port:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.port)

#     # Not in regular urlsplit() !
#     property host:
#         def __get__(self):
#             return slice_component(self.pyurl, self.parsed.host)

#     property netloc:
#         def __get__(self):
#             return build_netloc(self.pyurl, self.parsed)


class SplitResultNamedTuple(tuple):

    __slots__ = ()  # prevent creation of instance dictionary

    def __new__(cls, bytes url):

        cdef Parsed parsed

        if url[0:5] == b"file:":
            ParseFileURL(url, len(url), &parsed)
        else:
            ParseStandardURL(url, len(url), &parsed)

        def _get_attr(self, prop):
            if prop == "scheme":
                return self[0]
            elif prop == "netloc":
                return self[1]
            elif prop == "path":
                return self[2]
            elif prop == "query":
                return self[3]
            elif prop == "fragment":
                return self[4]
            elif prop == "port":
                if parsed.port.len > 0:
                    port = int(slice_component(url, parsed.port))
                    if port <= 65535:
                        return port

            elif prop == "username":
                return slice_component(url, parsed.username) or None
            elif prop == "password":
                return slice_component(url, parsed.password) or None
            elif prop == "hostname":
                return slice_component(url, parsed.host).lower()


        cls.__getattr__ = _get_attr

        return tuple.__new__(cls, (
            slice_component(url, parsed.scheme).lower(),
            build_netloc(url, parsed),
            slice_component(url, parsed.path),
            slice_component(url, parsed.query),
            slice_component(url, parsed.ref)
        ))

    def geturl(self):
        return stdlib_urlparse.urlunsplit(self)


def urlsplit(url):
    return SplitResultNamedTuple.__new__(SplitResultNamedTuple, url)

def urljoin(bytes base, bytes url, allow_fragments=True):
    if allow_fragments:
        return GURL(base).Resolve(url).spec()
    else:
        return stdlib_urlparse.urljoin(base, url, allow_fragments=allow_fragments)
