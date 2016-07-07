from libcpp.string cimport string
from libcpp cimport bool
from mozilla_url_parse cimport Component, Parsed


cdef extern from "../vendor/gurl/url/gurl.h":
    cdef cppclass GURL:
        GURL()
        GURL(const string & url_string)
        GURL(const char * canonical_spec,
             size_t canonical_spec_len,
             const Parsed parsed,
             bool is_valid)

        bool is_valid()
        bool is_empty()
        bool IsStandard()
        string spec()
        GURL Resolve(const string & relative)
        string possibly_invalid_spec()

        bool has_scheme()
        bool has_username()
        bool has_password()
        bool has_host()
        bool has_port()
        bool has_path()
        bool has_query()
        bool has_ref()

        string scheme()
        string username()
        string password()
        string host()
        string port()
        string path()
        string query()
        string ref()

        Parsed parsed_for_possibly_invalid_spec()
        # GURL ReplaceComponents(const Replacements[char] replacements)
