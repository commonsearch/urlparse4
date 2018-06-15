from urlparse4.mozilla_url_parse cimport Component, Parsed, ParseStandardURL, ParseFileURL, ParseFileSystemURL, ParseMailtoURL, ParsePathURL, ExtractScheme
from urlparse4.chromium_gurl cimport GURL
from urlparse4.chromium_url_constant cimport *
from urlparse4.chromium_url_util_internal cimport CompareSchemeComponent
from urlparse4.chromium_url_util cimport IsStandard

import six
from six.moves.urllib.parse import urljoin as stdlib_urljoin
from six.moves.urllib.parse import urlunsplit as stdlib_urlunsplit

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
    """
    TODO:
    take a look at this function
    """
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

    def __new__(cls, bytes url, decoded=False):

        cdef Parsed parsed
        cdef Component url_scheme

        if not ExtractScheme(url, len(url), &url_scheme):
            """
            TO DO:
            What do we return here
            """
            return False

        if CompareSchemeComponent(url, url_scheme, kFileScheme):
            ParseFileURL(url, len(url), &parsed)
        elif CompareSchemeComponent(url, url_scheme, kFileSystemScheme):
            ParseFileSystemURL(url, len(url), &parsed)
        elif IsStandard(url, url_scheme):
            ParseStandardURL(url, len(url), &parsed)
        elif CompareSchemeComponent(url, url_scheme, kMailToScheme):
            """
            Discuss: Is this correct?
            """
            ParseMailtoURL(url, len(url), &parsed)
        else:
            """
            TODO:
            trim or not to trim?
            """
            ParsePathURL(url, len(url), True, &parsed)


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
                """
                TODO:
                Port can go beyond 0
                """
                if parsed.port.len > 0:
                    port = int(slice_component(url, parsed.port))
                    if port <= 65535:
                        return port

            elif prop == "username":
                username = slice_component(url, parsed.username)
                if decoded:
                    return username.decode('utf-8') or None
                return username or None
            elif prop == "password":
                password = slice_component(url, parsed.password)
                if decoded:
                    return password.decode('utf-8') or None
                return password or None
            elif prop == "hostname":
                """
                hostname should be treated differently from netloc
                """
                hostname = slice_component(url, parsed.host).lower()
                if decoded:
                    return hostname.decode('utf-8')
                return hostname


        cls.__getattr__ = _get_attr

        scheme, netloc, path, query, ref = (slice_component(url, parsed.scheme).lower(),
                                            build_netloc(url, parsed),
                                            slice_component(url, parsed.path),
                                            slice_component(url, parsed.query),
                                            slice_component(url, parsed.ref))

        if decoded:
            return tuple.__new__(cls, (
                <unicode>scheme.decode('utf-8'),
                <unicode>netloc.decode('utf-8'),
                <unicode>path.decode('utf-8'),
                <unicode>query.decode('utf-8'),
                <unicode>ref.decode('utf-8')
            ))

        return tuple.__new__(cls, (scheme, netloc, path, query, ref))

    def geturl(self):
        return stdlib_urlunsplit(self)

def unicode_handling(str):
    cdef bytes bytes_str
    if isinstance(str, unicode):
        bytes_str = <bytes>(<unicode>str).encode('utf8')
    else:
        bytes_str = str
    return bytes_str

def urlsplit(url):
    """
    Use GURL to split the url. Needs to be reviewed!
    """
    decode = False if isinstance(url, bytes) else True
    url = unicode_handling(url)
    return SplitResultNamedTuple.__new__(SplitResultNamedTuple, url, decode)

def urljoin(base, url, allow_fragments=True):
    """
    Use the urljoin function from GURL chromium. Needs to be reviewed!
    """
    decode = False if (isinstance(base, bytes) and isinstance(url, bytes)) else True
    if allow_fragments and base:
        base, url = unicode_handling(base), unicode_handling(url)
        if decode:
            return GURL(base).Resolve(url).spec().decode('utf-8')
        return GURL(base).Resolve(url).spec()

    return stdlib_urljoin(base, url, allow_fragments=allow_fragments)
