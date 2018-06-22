from urlparse4.mozilla_url_parse cimport *
from urlparse4.chromium_gurl cimport GURL
from urlparse4.chromium_url_constant cimport *
from urlparse4.chromium_url_util_internal cimport CompareSchemeComponent
from urlparse4.chromium_url_util cimport Canonicalize
from urlparse4.chromium_url_canon_stdstring cimport StdStringCanonOutput
from urlparse4.chromium_url_canon cimport CharsetConverter

import six
from six.moves.urllib.parse import urlsplit as stdlib_urlsplit
from six.moves.urllib.parse import urljoin as stdlib_urljoin
from six.moves.urllib.parse import urlunsplit as stdlib_urlunsplit
from six.moves.urllib.parse import urlparse as stdlib_urlparse
from six.moves.urllib.parse import urlunparse as stdlib_urlunparse

cimport cython
from libcpp.string cimport string
from libcpp cimport bool


uses_params = [scheme.encode('utf-8') for scheme in ['', 'ftp', 'hdl',
                                                     'prospero', 'http', 'imap',
                                                     'https', 'shttp', 'rtsp',
                                                     'rtspu', 'sip', 'sips',
                                                     'mms', 'sftp', 'tel']]


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


cdef bytes unicode_handling(str):
    cdef bytes bytes_str
    if isinstance(str, unicode):
        bytes_str = <bytes>(<unicode>str).encode('utf8')
    else:
        bytes_str = <bytes>str
    return bytes_str

cdef void parse_url(char* url, Parsed * parsed, string * output_url):
    cdef StdStringCanonOutput * output = new StdStringCanonOutput(output_url)
    cdef bool is_valid_ = Canonicalize(url, len(url), True, NULL, output, parsed)
    output.Complete()

cdef object extra_attr(obj, prop, bytes url, Parsed parsed, decoded, params=False):
    if prop == "scheme":
        return obj[0]
    elif prop == "netloc":
        return obj[1]
    elif prop == "path":
        return obj[2]
    elif params and prop == "params":
        return obj[3]
    elif prop == "query":
        if params:
            return obj[4]
        return obj[3]
    elif prop == "fragment":
        if params:
            return obj[5]
        return obj[4]
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
        if chr(hostname[0]) == '[':
            hostname = hostname[1:-1]
        if decoded:
            return hostname.decode('utf-8')
        return hostname

# https://github.com/python/cpython/blob/master/Lib/urllib/parse.py
cdef object _splitparams(string path):
    """
    this function can be modified to enhance the performance?
    """
    cdef char slash_char = b'/'
    cdef string slash_string = b'/'
    cdef string semcol = b';'
    cdef int i

    if path.find(slash_string) > 0:
        i = path.find(semcol, path.rfind(slash_char))
        if i < 0:
            return path, b''
    else:
        i = path.find(semcol)
    return path.substr(0, i), path.substr(i + 1)


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
    """
    There is some repetition in the class,
    we will need to take care of that!
    """

    __slots__ = ()  # prevent creation of instance dictionary

    def __new__(cls, bytes url, input_scheme, decoded=False):

        cdef Parsed parsed
        cdef string parsed_url = string()

        parse_url(url, &parsed, &parsed_url)

        def _get_attr(self, prop):
            return extra_attr(self, prop, parsed_url, parsed, decoded)

        cls.__getattr__ = _get_attr

        scheme, netloc, path, query, ref = (slice_component(parsed_url, parsed.scheme).lower(),
                                            build_netloc(parsed_url, parsed),
                                            slice_component(parsed_url, parsed.path),
                                            slice_component(parsed_url, parsed.query),
                                            slice_component(parsed_url, parsed.ref))
        if scheme == '' and input_scheme != '':
            scheme = input_scheme

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


class ParsedResultNamedTuple(tuple):
    __slots__ = ()  # prevent creation of instance dictionary

    def __new__(cls, char * url, input_scheme, decoded=False):

        cdef Parsed parsed
        cdef string parsed_url = string()

        parse_url(url, &parsed, &parsed_url)

        def _get_attr(self, prop):
            return extra_attr(self, prop, parsed_url, parsed, decoded, True)

        cls.__getattr__ = _get_attr

        scheme, netloc, path, query, ref = (slice_component(parsed_url, parsed.scheme).lower(),
                                            build_netloc(parsed_url, parsed),
                                            slice_component(parsed_url, parsed.path),
                                            slice_component(parsed_url, parsed.query),
                                            slice_component(parsed_url, parsed.ref))
        if scheme == '' and input_scheme != '':
            scheme = input_scheme

        if scheme in uses_params and ';'.encode('utf-8') in path:
            path, params = _splitparams(path)
        else:
            params = b''

        if decoded:
            return tuple.__new__(cls, (
                <unicode>scheme.decode('utf-8'),
                <unicode>netloc.decode('utf-8'),
                <unicode>path.decode('utf-8'),
                <unicode>params.decode('utf-8'),
                <unicode>query.decode('utf-8'),
                <unicode>ref.decode('utf-8')
            ))

        return tuple.__new__(cls, (scheme, netloc, path, params, query, ref))

    def geturl(self):
        return stdlib_urlunparse(self)

def urlparse(url, scheme='', allow_fragments=True):
    """
    This function intends to replace urlparse from urllib
    using urlsplit function from urlparse4 itself.
    Can this function be further enhanced?
    """
    decode = not isinstance(url, bytes)
    url = unicode_handling(url)
    return ParsedResultNamedTuple.__new__(ParsedResultNamedTuple, url, scheme, decode)

def urlsplit(url, scheme='', allow_fragments=True):
    """
    This function intends to replace urljoin from urllib,
    which uses Urlparse class from GURL Chromium
    """
    decode = not isinstance(url, bytes)
    url = unicode_handling(url)
    return SplitResultNamedTuple.__new__(SplitResultNamedTuple, url, scheme, decode)

def urljoin(base, url, allow_fragments=True):
    """
    This function intends to replace urljoin from urllib,
    which uses Resolve function from class GURL of GURL chromium
    """
    decode = not (isinstance(base, bytes) and isinstance(url, bytes))
    if allow_fragments and base:
        base, url = unicode_handling(base), unicode_handling(url)
        joined_url = GURL(base).Resolve(url).spec()

        if decode:
            return joined_url.decode('utf-8')
        return joined_url

    return stdlib_urljoin(base, url, allow_fragments=allow_fragments)
