cdef extern from "../vendor/gurl/url/third_party/mozilla/url_parse.h" namespace "url":
    cdef struct Component:
        int begin
        int len

    cdef struct Parsed:
        int Length()
        Component scheme
        Component username
        Component password
        Component host
        Component port
        Component path
        Component query
        Component ref

    cdef void ParseStandardURL(const char* url, int url_len, Parsed* parsed)
    cdef void ParseFileURL(const char* url, int url_len, Parsed* parsed)
