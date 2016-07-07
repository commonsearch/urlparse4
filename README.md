# urlparse4

`urlparse4` is a performance-focused replacement for Python's `urlparse` module, using C++ code from Chromium's own URL parser.

It is not production-ready yet.

Many credits go to [gurl-cython](https://github.com/Preetwinder/gurl-cython) for inspiration.

## Differences with Python's `urlparse`

`urlparse4` should be a transparent, drop-in replacement in almost all cases. Still, there are a few differences to be aware of:

 - `urlparse4` is 2-7x faster for most operations (see benchmarks below)
 - `urlparse4` currently doesn't pass CPython's `test_urlparse.py` suite due to edge cases that Chromium's parser manages differently (usually in accordance to the RFCs, which `urlparse` doesn't follow entirely).

## How to test

You must have Docker installed and running. You can run CPython's test suite for `urlparse` like this:

```
make docker_build
make docker_test
```

## Benchmarks

We are testing the following librairies on a sample of 100k URLs from Blink and DMOZ:

 - urlparse4 ;-)
 - [CPython's urlparse](https://github.com/python/cpython/blob/2.7/Lib/urlparse.py)
 - [urlparse2](https://github.com/mwhooker/urlparse2)
 - [YURL](http://github.com/homm/yurl/)
 - [uritools](https://github.com/tkem/uritools)
 - [pygurl / gurl-cython](https://github.com/Preetwinder/gurl-cython)

Each of them is being tested on a few different types of operations (basic urlsplit, relative link resolution, hostname extraction)

Here is how to launch the tests:

```
make docker_build
make docker_benchmark
```

Current results on a 2.2GHz Intel Core i7 MBP (in seconds):

```
Benchmark results on 104300 URLs x 10 times, in seconds:

Name              Sum        Mean               Median             90%
----------------  ---------  -----------------  -----------------  -----------------

urlsplit:
----              ----       ----               ----               ----
urlparse4         1.733489   1.66202205177e-06  1.99999999984e-06  2.00000000006e-06
pygurl            2.133428   2.04547267498e-06  2.00000000028e-06  2.99999999953e-06
uritools          2.544093   2.43920709492e-06  2.00000000028e-06  3.00000000042e-06
yurl              3.906837   3.74576893576e-06  3.00000000131e-06  4.99999999981e-06
urlparse2         3.958966   3.79574880153e-06  3.00000000308e-06  4.99999999981e-06
urlparse          3.994541   3.82985714286e-06  3.00000000308e-06  5.00000000159e-06

urljoin_sibling:
----              ----       ----               ----               ----
urlparse4         2.44908    2.34811121764e-06  2.00000000206e-06  2.99999999953e-06
pygurl            2.260171   2.16699041227e-06  1.9999999985e-06   2.99999999953e-06
uritools          10.556071  1.0120873442e-05   9.0000000057e-06   1.29999999992e-05
yurl              11.996895  1.15022962608e-05  1.00000000032e-05  1.49999999977e-05
urlparse2         14.528771  1.39297900288e-05  1.29999999956e-05  1.69999999997e-05
urlparse          9.375126   8.98861553212e-06  8.00000000822e-06  1.19999999981e-05

hostname:
----              ----       ----               ----               ----
urlparse4         1.909207   1.83049568553e-06  1.99999999495e-06  2.00000000916e-06
pygurl            1.654586   1.58637200384e-06  1.99999999495e-06  2.00000000916e-06
uritools          3.458205   3.31563279003e-06  3.00000000664e-06  4.00000000411e-06
yurl              3.917813   3.7562924257e-06   3.9999999899e-06   4.00000000411e-06
urlparse2         4.631981   4.44101725791e-06  4.00000000411e-06  5.99999999906e-06
urlparse          4.708039   4.51393959731e-06  4.00000000411e-06  5.99999999906e-06
```

Some libraries are included in the benchmark code but disabled for various reasons:

 - [urlparse3](https://pypi.python.org/pypi/urlparse3/) (Raises on valid URLs)
 - [slimurl](https://github.com/mosquito/slimurl) (Too slow)
 - [cyuri](https://github.com/mitghi/cyuri) (Segfaults on some URLs)

Feel free to submit pull requests to add new ones!

## Feedback

We'd love to hear your feedback! Feel free to look at the issues on GitHub and open new ones if needed :)
