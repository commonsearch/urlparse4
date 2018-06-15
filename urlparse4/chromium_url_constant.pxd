from libcpp.string cimport string
from libcpp cimport bool
from mozilla_url_parse cimport Component, Parsed


cdef extern from "../vendor/gurl/url/url_constants.h" namespace "url":

    extern const char kAboutBlankURL[];

    extern const char kAboutScheme[];
    extern const char kBlobScheme[];

    extern const char kContentScheme[];
    extern const char kDataScheme[];
    extern const char kFileScheme[];
    extern const char kFileSystemScheme[];
    extern const char kFtpScheme[];
    extern const char kGopherScheme[];
    extern const char kHttpScheme[];
    extern const char kHttpsScheme[];
    extern const char kJavaScriptScheme[];
    extern const char kMailToScheme[];
    extern const char kWsScheme[];
    extern const char kWssScheme[];

    extern const char kStandardSchemeSeparator[];
