from urlparse4.mozilla_url_parse cimport Component, Parsed, ParseStandardURL
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



@cython.freelist(100)
cdef class SplitResult:

    cdef Parsed parsed
    # cdef char * url
    cdef bytes pyurl

    def __cinit__(self, char* url):
        # self.url = url
        self.pyurl = url
        ParseStandardURL(url, len(url), &self.parsed)

    property scheme:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.scheme)

    property path:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.path)

    property query:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.query)

    property fragment:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.ref)

    property username:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.username)

    property password:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.password)

    property port:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.port)

    # Not in regular urlsplit() !
    property host:
        def __get__(self):
            return slice_component(self.pyurl, self.parsed.host)

    property netloc:
        def __get__(self):

            # Nothing at all
            if self.parsed.username.len <= 0 and self.parsed.password.len <= 0 and self.parsed.port.len <= 0:
                return self.host

            # Only port
            elif self.parsed.username.len <= 0 and self.parsed.password.len <= 0 and self.parsed.port.len > 0:
                return self.pyurl[self.parsed.host.begin: self.parsed.host.begin + self.parsed.host.len + 1 + self.parsed.port.len]

            # Only username
            elif self.parsed.username.len > 0 and self.parsed.password.len <= 0 and self.parsed.port.len <= 0:
                return self.pyurl[self.parsed.username.begin: self.parsed.username.begin + self.parsed.host.len + 1 + self.parsed.username.len]

            # Username + password
            elif self.parsed.username.len > 0 and self.parsed.password.len <= 0 and self.parsed.port.len <= 0:
                return self.pyurl[self.parsed.username.begin: self.parsed.username.begin + self.parsed.host.len + 2 + self.parsed.username.len + self.parsed.password.len]

            # Username + port
            elif self.parsed.username.len > 0 and self.parsed.password.len <= 0 and self.parsed.port.len <= 0:
                return self.pyurl[self.parsed.username.begin: self.parsed.username.begin + self.parsed.host.len + 2 + self.parsed.username.len + self.parsed.port.len]

            # Username + port + password
            elif self.parsed.username.len > 0 and self.parsed.password.len > 0 and self.parsed.port.len > 0:
                return self.pyurl[self.parsed.username.begin: self.parsed.username.begin + self.parsed.host.len + 3 + self.parsed.port.len  + self.parsed.username.len  + self.parsed.password.len]

            else:
                raise ValueError



class SplitResultNamedTuple(tuple):

    __slots__ = ()  # prevent creation of instance dictionary

    def __new__(cls, url):
        cls.__sr = SplitResult.__new__(SplitResult, url)
        return tuple.__new__(cls, (
            cls.__sr.scheme.lower(), cls.__sr.netloc, cls.__sr.path, cls.__sr.query, cls.__sr.fragment
        ))

    @property
    def scheme(self):
        return self[0]

    @property
    def port(self):
        if self.__sr.port and int(self.__sr.port) <= 65535:
            return int(self.__sr.port)
        else:
            return None

    @property
    def path(self):
        return self[2]

    @property
    def query(self):
        return self[3]

    @property
    def netloc(self):
        return self[1]

    @property
    def username(self):
        return self.__sr.username or None

    @property
    def password(self):
        return self.__sr.password or None

    @property
    def fragment(self):
        return self[4]

    @property
    def hostname(self):
        return self.__sr.host.lower()

    def geturl(self):
        return stdlib_urlparse.urlunsplit(self)


def urlsplit(url):
    return SplitResultNamedTuple.__new__(SplitResultNamedTuple, url)


cpdef urljoin(bytes base, bytes url, allow_fragments=True):
    if allow_fragments:
        return GURL(base).Resolve(url).spec()
    else:
        return stdlib_urlparse.urljoin(base, url, allow_fragments=allow_fragments)
