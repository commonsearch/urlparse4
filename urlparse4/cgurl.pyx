from urlparse4.mozilla_url_parse cimport Component, Parsed, ParseStandardURL, ParseFileURL, ParseFileSystemURL, ParseMailtoURL, ParsePathURL, ExtractScheme
from urlparse4.chromium_gurl cimport GURL
from urlparse4.chromium_url_constant cimport *
from urlparse4.chromium_url_util_internal cimport CompareSchemeComponent
from urlparse4.chromium_url_util cimport IsStandard

import six
from six.moves.urllib.parse import urlparse as stdlib_urlparse
from six.moves.urllib.parse import urlsplit as stdlib_urlsplit
from six.moves.urllib.parse import urljoin as stdlib_urljoin
from six.moves.urllib.parse import urlunsplit as stdlib_urlunsplit
from collections import namedtuple

cimport cython


uses_params = ['', 'ftp', 'hdl', 'prospero', 'http', 'imap',
           'https', 'shttp', 'rtsp', 'rtspu', 'sip', 'sips',
           'mms', 'sftp', 'tel']


# class _NetlocResultMixinBase(object):
#     """Shared methods for the parsed result objects containing a netloc element"""
#     __slots__ = ()
#
#     @property
#     def username(self):
#         return self._userinfo[0]
#
#     @property
#     def password(self):
#         return self._userinfo[1]
#
#     @property
#     def hostname(self):
#         hostname = self._hostinfo[0]
#         if not hostname:
#            return None
#         # Scoped IPv6 address may have zone info, which must not be lowercased
#         # like http://[fe80::822a:a8ff:fe49:470c%tESt]:1234/keys
#         separator = '%' if isinstance(hostname, str) else b'%'
#         hostname, percent, zone = hostname.partition(separator)
#         return hostname.lower() + percent + zone
#
#     @property
#     def port(self):
#         port = self._hostinfo[1]
#         if port is not None:
#             try:
#                 port = int(port, 10)
#             except ValueError:
#                 message = f'Port could not be cast to integer value as {port!r}'
#                 raise ValueError(message) from None
#             if not ( 0 <= port <= 65535):
#                 raise ValueError("Port out of range 0-65535")
#         return port
#
#
# class _NetlocResultMixinStr(_NetlocResultMixinBase, _ResultMixinStr):
#     __slots__ = ()
#
#     @property
#     def _userinfo(self):
#         netloc = self.netloc
#         userinfo, have_info, hostinfo = netloc.rpartition('@')
#         if have_info:
#             username, have_password, password = userinfo.partition(':')
#             if not have_password:
#                 password = None
#         else:
#             username = password = None
#         return username, password
#
#     @property
#     def _hostinfo(self):
#         netloc = self.netloc
#         _, _, hostinfo = netloc.rpartition('@')
#         _, have_open_br, bracketed = hostinfo.partition('[')
#         if have_open_br:
#             hostname, _, port = bracketed.partition(']')
#             _, _, port = port.partition(':')
#         else:
#             hostname, _, port = hostinfo.partition(':')
#         if not port:
#             port = None
#         return hostname, port
#
#
# class _NetlocResultMixinBytes(_NetlocResultMixinBase, _ResultMixinBytes):
#     __slots__ = ()
#
#     @property
#     def _userinfo(self):
#         netloc = self.netloc
#         userinfo, have_info, hostinfo = netloc.rpartition(b'@')
#         if have_info:
#             username, have_password, password = userinfo.partition(b':')
#             if not have_password:
#                 password = None
#         else:
#             username = password = None
#         return username, password
#
#     @property
#     def _hostinfo(self):
#         netloc = self.netloc
#         _, _, hostinfo = netloc.rpartition(b'@')
#         _, have_open_br, bracketed = hostinfo.partition(b'[')
#         if have_open_br:
#             hostname, _, port = bracketed.partition(b']')
#             _, _, port = port.partition(b':')
#         else:
#             hostname, _, port = hostinfo.partition(b':')
#         if not port:
#             port = None
#         return hostname, port


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

cdef void parse_url_helper(bytes url, Parsed * parsed, Component url_scheme):
    if CompareSchemeComponent(url, url_scheme, kFileScheme):
        ParseFileURL(url, len(url), parsed)
    elif CompareSchemeComponent(url, url_scheme, kFileSystemScheme):
        ParseFileSystemURL(url, len(url), parsed)
    elif IsStandard(url, url_scheme):
        ParseStandardURL(url, len(url), parsed)
    elif CompareSchemeComponent(url, url_scheme, kMailToScheme):
        """
        Discuss: Is this correct?
        """
        ParseMailtoURL(url, len(url), parsed)
    else:
        """
        TODO:
        trim or not to trim?
        """
        ParsePathURL(url, len(url), True, parsed)


def unicode_handling(str):
    cdef bytes bytes_str
    if isinstance(str, unicode):
        bytes_str = <bytes>(<unicode>str).encode('utf8')
    else:
        bytes_str = str
    return bytes_str


# https://github.com/python/cpython/blob/master/Lib/urllib/parse.py#L373
def _splitparams(bytes url):
    """
    This function can be converted to C to further enhance the performance
    """
    cdef int i
    if '/'  in url:
        i = url.find(';', url.rfind('/'))
        if i < 0:
            return url, ''
    else:
        i = url.find(';')
    return url[:i], url[i+1:]


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

SplitResult = namedtuple('SplitResult', 'scheme netloc path query fragment')
ParseResult = namedtuple('ParseResult', 'scheme netloc path params query fragment')

class SplitResultNamedTuple(SplitResult):
    __slots__ = ()

class ParsedResultNamedTuple(ParseResult):
    __slots__ = ()


def parse_url(bytes url, input_scheme, decoded=False, allow_params=False):
    """
    This function uses methods from GURL-chromium to parse the urls
    which will return the result for urlparse and urljoin
    """
    cdef Parsed parsed
    cdef Component url_scheme

    if not ExtractScheme(url, len(url), &url_scheme):
        original_url = url.decode('utf-8') if decoded else url
        if allow_params:
            return stdlib_urlparse(original_url, input_scheme)
        return stdlib_urlsplit(original_url, input_scheme)

    parse_url_helper(url, &parsed, url_scheme)

    scheme, netloc, path, query, ref = (slice_component(url, parsed.scheme).lower(),
                                        build_netloc(url, parsed),
                                        slice_component(url, parsed.path),
                                        slice_component(url, parsed.query),
                                        slice_component(url, parsed.ref))
    if scheme == '' and input_scheme != '':
        scheme = input_scheme

    if allow_params:
        if scheme in uses_params and ';' in url:
            url, params = _splitparams(url)
        else:
            params = ''

    if decoded:
        scheme, netloc, path, query, ref = (<unicode>scheme.decode('utf-8'),
                                            <unicode>netloc.decode('utf-8'),
                                            <unicode>path.decode('utf-8'),
                                            <unicode>query.decode('utf-8'),
                                            <unicode>ref.decode('utf-8'))
        if allow_params:
            return ParseResult(scheme, netloc, path, params, query, ref)
        return SplitResult(scheme, netloc, path, query, ref)

    if allow_params:
        return ParseResult(scheme, netloc, path, <bytes>(<unicode>params).encode('utf8'), query, ref)

    return SplitResult(scheme, netloc, path, query, ref)

def urlparse(url, scheme='', allow_fragments=True):
    """
    This function intends to replace urlparse from urllib
    using urlsplit function from urlparse4 itself.
    Can this function be further enhanced?
    """
    decode = not isinstance(url, bytes)
    url = unicode_handling(url)
    return parse_url(url, scheme, decode, True)


def urlsplit(url, scheme='', allow_fragments=True):
    """
    This function intends to replace urljoin from urllib,
    which uses Urlparse class from GURL Chromium
    """
    decode = not isinstance(url, bytes)
    url = unicode_handling(url)
    return parse_url(url, scheme, decode)

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
