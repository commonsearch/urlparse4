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
urlparse4         1.755267       1.68290220518e-06  1.99999999984e-06  2.00000000006e-06
pygurl            1.952765       1.87225790988e-06  1.99999999984e-06  2.00000000028e-06
uritools          2.564707       2.45897123682e-06  2.00000000028e-06  3.00000000042e-06
yurl              3.803354       3.64655225312e-06  3.00000000131e-06  4.99999999981e-06
urlparse2         4.042676       3.87600767018e-06  3.99999999701e-06  5.00000000159e-06
urlparse          4.107233       3.93790316395e-06  3.99999999701e-06  5.00000000159e-06
cyuri             10.43085       1.00008149569e-05  8.99999999859e-06  1.40000000002e-05

urljoin_sibling:
----              ----           ----               ----               ----
urlparse4         2.35831600001  2.26108916587e-06  2.00000000206e-06  2.99999999953e-06
pygurl            2.156502       2.06759539789e-06  2.00000000206e-06  2.99999999953e-06
uritools          9.931027       9.52159827421e-06  8.99999999859e-06  1.10000000006e-05
yurl              12.335251      1.18267027804e-05  1.10000000006e-05  1.30000000098e-05
urlparse2         13.796022      1.32272502397e-05  1.19999999981e-05  1.60000000022e-05
urlparse          9.533459       9.14042090125e-06  8.00000000822e-06  1.10000000006e-05
cyuri             5.949146       5.70387919463e-06  5.00000000159e-06  7.99999999401e-06

hostname:
----              ----           ----               ----               ----
urlparse4         1.866522       1.7895704698e-06   1.99999999495e-06  2.00000000916e-06
pygurl            1.688137       1.61853978907e-06  1.99999999495e-06  2.00000000916e-06
uritools          3.169007       3.03835762224e-06  2.99999999243e-06  3.9999999899e-06
yurl              3.796674       3.64014765101e-06  3.00000000664e-06  4.00000000411e-06
urlparse2         4.443537       4.26034228188e-06  4.00000000411e-06  5.00000000159e-06
urlparse          4.77568799999  4.57879961648e-06  4.00000000411e-06  5.99999999906e-06
cyuri             11.135898      1.06767957814e-05  9.0000000057e-06   1.5000000019e-05
```

Some libraries are included in the benchmark code but disabled for various reasons:

 - [urlparse3](https://pypi.python.org/pypi/urlparse3/) (Raises on valid URLs)
 - [slimurl](https://github.com/mosquito/slimurl) (Too slow)

Feel free to submit pull requests to add new ones!

## Feedback

We'd love to hear your feedback! Feel free to look at the issues on GitHub and open new ones if needed :)
