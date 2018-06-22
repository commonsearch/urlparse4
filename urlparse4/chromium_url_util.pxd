from libcpp.string cimport string
from libcpp cimport bool
from mozilla_url_parse cimport Component, Parsed
from chromium_url_canon cimport CharsetConverter
from chromium_url_canon_stdstring cimport StdStringCanonOutput


cdef extern from "../vendor/gurl/url/url_util.h" namespace "url":
    cdef bool Canonicalize(const char* spec,
                           int spec_len,
                           bool trim_path_end,
                           CharsetConverter* charset_converter,
                           StdStringCanonOutput* output,
                           Parsed* output_parsed)
