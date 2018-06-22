from libcpp cimport bool


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
