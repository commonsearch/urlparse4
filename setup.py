from distutils.core import setup, Extension
import os

VERSION = "0.1.2"

extension = Extension(
    name="urlparse4/cgurl",
    sources=["urlparse4/cgurl.pyx",
             "vendor/gurl/base/third_party/icu/icu_utf.cc",
             "vendor/gurl/base/strings/string16.cc",
             "vendor/gurl/base/strings/string_piece.cc",
             "vendor/gurl/base/strings/string_util.cc",
             "vendor/gurl/base/strings/utf_string_conversions.cc",
             "vendor/gurl/base/strings/utf_string_conversion_utils.cc",
             "vendor/gurl/url/gurl.cc",
             "vendor/gurl/url/url_canon_etc.cc",
             "vendor/gurl/url/url_canon_filesystemurl.cc",
             "vendor/gurl/url/url_canon_fileurl.cc",
             "vendor/gurl/url/url_canon_host.cc",
             "vendor/gurl/url/url_canon_internal.cc",
             "vendor/gurl/url/url_canon_ip.cc",
             "vendor/gurl/url/url_canon_mailtourl.cc",
             "vendor/gurl/url/url_canon_path.cc",
             "vendor/gurl/url/url_canon_pathurl.cc",
             "vendor/gurl/url/url_canon_query.cc",
             "vendor/gurl/url/url_canon_relative.cc",
             "vendor/gurl/url/url_canon_stdstring.cc",
             "vendor/gurl/url/url_canon_stdurl.cc",
             "vendor/gurl/url/url_constants.cc",
             "vendor/gurl/url/url_parse_file.cc",
             "vendor/gurl/url/url_util.cc",
             "vendor/gurl/url/third_party/mozilla/url_parse.cc"
             ],
    language="c++",
    extra_compile_args=["-std=gnu++0x", "-I./vendor/gurl/",
                        "-fPIC", "-Ofast", "-pthread", "-w"],
    extra_link_args=["-std=gnu++0x", "-w"],
)


if not os.path.isfile("urlparse4/cgurl.cpp"):
    try:
        from Cython.Build import cythonize
        ext_modules = cythonize(extension, annotate=True)
    except:
        print "urlparse4/gurl.cpp not found and Cython failed to run to recreate it. Please install/upgrade Cython and try again."
        raise
else:
    ext_modules = [extension]
    ext_modules[0].sources = ["urlparse4/cgurl.cpp"]

try:
    import pypandoc
    long_description = pypandoc.convert('README.md', 'rst')
except ImportError:
    long_description = open('README.md').read()

setup(
    name="urlparse4",
    packages=['urlparse4'],
    version=VERSION,
    description="Performance-focused replacement for Python's urlparse module",
    author="Common Search contributors",
    author_email="contact@commonsearch.org",
    license="Apache License, Version 2.0",
    url="https://github.com/commonsearch/urlparse4",
    keywords=["urlparse", "urlsplit", "urljoin", "url", "parser", "urlparser", "parsing", "gurl", "cython", "faster", "speed", "performance"],
    platforms='any',
    classifiers=[
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.7",
        # 'Development Status :: 1 - Planning',
        # 'Development Status :: 2 - Pre-Alpha',
        'Development Status :: 3 - Alpha',
        # 'Development Status :: 4 - Beta',
        # 'Development Status :: 5 - Production/Stable',
        # 'Development Status :: 6 - Mature',
        # 'Development Status :: 7 - Inactive',
        "Environment :: Other Environment",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
        "Topic :: Software Development :: Libraries"
    ],
    long_description=long_description,
    ext_modules=ext_modules,
    include_package_data=True
)
