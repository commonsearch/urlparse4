from libcpp.string cimport string


cdef extern from "../vendor/gurl/url/url_canon_stdstring.h" namespace "url":
    cdef cppclass StdStringCanonOutput:
        StdStringCanonOutput()
        StdStringCanonOutput(string* str)
        void Complete()
        void Resize(int sz)
