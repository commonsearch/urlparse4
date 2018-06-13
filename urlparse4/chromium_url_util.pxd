from libcpp.string cimport string
from libcpp cimport bool
from mozilla_url_parse cimport Component, Parsed


cdef extern from "../vendor/gurl/url/url_til.h" namespace "url":
    cdef bool IsStandard(const char* spec, const Component& scheme);
