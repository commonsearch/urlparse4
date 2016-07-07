# urlparse4

`urlparse4` is a performance-focused replacement for Python's `urlparse` module, using C++ code from Chromium's own URL parser.

It is not production-ready yet.

Many credits go to [gurl-cython](https://github.com/Preetwinder/gurl-cython) for inspiration.

## Differences with Python's `urlparse`

`urlparse4` should be a transparent, drop-in replacement in almost all cases. Still, there are a few differences to be aware of:

 - `urlparse4` is 2-7x faster for most operations (see benchmarks below)
 - `urlparse4` currently doesn't pass CPython's `test_urlparse.py` suite due to edge cases that Chromium's parser manages differently (usually in accordance to the RFCs, which `urlparse` doesn't follow entirely).
 - `urlparse4` only supports Python 2.7 for now

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
 - [cyuri](https://github.com/mitghi/cyuri)

Each of them is being tested on a few different types of operations (basic urlsplit, relative link resolution, hostname extraction)

Here is how to launch the tests:

```
make docker_build
make docker_benchmark
```

Current results on a 2.2GHz Intel Core i7 MBP (in seconds):

```
Benchmark results on 104300 URLs x 10 times, in seconds:

Name              Sum            Mean               Median             90%
----------------  -------------  -----------------  -----------------  -----------------

urlsplit:
----              ----           ----               ----               ----
urlparse4         1.681858       1.61251965484e-06  1.99999999984e-06  2.00000000006e-06
pygurl            2.031712       1.94795014382e-06  1.99999999984e-06  2.00000000028e-06
uritools          2.638991       2.53019271333e-06  2.00000000028e-06  3.00000000042e-06
yurl              3.910247       3.74903835091e-06  3.00000000131e-06  4.99999999981e-06
urlparse2         3.756782       3.60190028763e-06  2.99999999953e-06  4.00000000056e-06
urlparse          3.862006       3.70278619367e-06  3.00000000308e-06  4.99999999803e-06
cyuri             9.912275       9.50361936721e-06  8.00000000112e-06  1.30000000027e-05

urljoin_sibling:
----              ----           ----               ----               ----
urlparse4         2.008453       1.92565004794e-06  2.00000000206e-06  2.00000000206e-06
pygurl            2.193427       2.10299808245e-06  2.00000000206e-06  2.99999999953e-06
uritools          10.575344      1.01393518696e-05  9.99999999607e-06  1.20000000052e-05
yurl              13.213052      1.26683144775e-05  1.19999999981e-05  1.60000000022e-05
urlparse2         14.239327      1.36522790029e-05  1.19999999981e-05  1.69999999997e-05
urlparse          9.25991500001  8.87815436242e-06  8.00000000822e-06  1.10000000006e-05
cyuri             5.742724       5.50596740172e-06  5.00000000159e-06  7.00000001075e-06

hostname:
----              ----           ----               ----               ----
urlparse4         1.883982       1.80631064237e-06  1.99999999495e-06  2.00000000916e-06
pygurl            1.67332099999  1.60433461169e-06  1.99999999495e-06  2.00000000916e-06
uritools          3.31632199999  3.17959923297e-06  3.00000000664e-06  4.00000000411e-06
yurl              3.853319       3.69445733461e-06  3.00000000664e-06  4.00000000411e-06
urlparse2         4.641513       4.45015627996e-06  4.00000000411e-06  5.99999999906e-06
urlparse          5.122682       4.91148801534e-06  4.00000000411e-06  5.99999999906e-06
cyuri             11.108649      1.06506701822e-05  9.0000000057e-06   1.5999999988e-05
```

Some libraries are included in the benchmark code but disabled for various reasons:

 - [urlparse3](https://pypi.python.org/pypi/urlparse3/) (Raises on valid URLs)
 - [slimurl](https://github.com/mosquito/slimurl) (Too slow)

Feel free to submit pull requests to add new ones!

## Feedback

We'd love to hear your feedback! Feel free to look at the issues on GitHub and open new ones if needed :)
