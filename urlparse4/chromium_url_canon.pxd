from libcpp cimport bool
from mozilla_url_parse cimport Component, Parsed


cdef extern from "../vendor/gurl/url/url_canon.h" namespace "url":
    cdef cppclass CharsetConverter:
        CharsetConverter()
