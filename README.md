# urlparse4

`urlparse4` is an "almost drop-in", performance-focused replacement for Python's `urlparse` module.

It is not production-ready yet.

We are currently using mainly [gurl-cython](https://github.com/Preetwinder/gurl-cython) behind the scenes, though that may change in the near future.

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

Name              Sum            Mean               Median             90%
----------------  -------------  -----------------  -----------------  -----------------

urlsplit:
----              ----           ----               ----               ----
urlparse4         3.541994       3.39596740173e-06  2.99999999998e-06  4.00000000012e-06
pygurl            2.035517       1.95159827421e-06  2.00000000028e-06  2.00000000028e-06
urlparse2         4.035211       3.86885043145e-06  3.99999999878e-06  4.99999999981e-06
urlparse          4.060927       3.89350623202e-06  3.99999999878e-06  4.99999999981e-06
uritools          2.495982       2.39307957814e-06  2.00000000206e-06  2.99999999953e-06
yurl              3.788329       3.63214669223e-06  2.99999999953e-06  4.00000000056e-06

urljoin_sibling:
----              ----           ----               ----               ----
urlparse4         2.382332       2.28411505273e-06  2.00000000206e-06  2.99999999953e-06
urlparse2         14.987754      1.43698504314e-05  1.29999999992e-05  1.80000000043e-05
urlparse          9.526042       9.1333096836e-06   8.00000000112e-06  1.19999999981e-05
uritools          10.266307      9.84305560882e-06  8.99999999859e-06  1.20000000052e-05
pygurl            2.30582700001  2.2107641419e-06   1.99999999495e-06  2.99999999243e-06
yurl              11.902723      1.14120067114e-05  1.10000000006e-05  1.40000000073e-05

hostname:
----              ----           ----               ----               ----
urlparse4         4.098633       3.92965771812e-06  4.00000000411e-06  4.00000000411e-06
urlparse2         4.83505700001  4.63572099713e-06  4.00000000411e-06  5.99999999906e-06
urlparse          4.831789       4.63258772771e-06  4.00000000411e-06  5.99999999906e-06
uritools          3.468532       3.32553403644e-06  3.00000000664e-06  4.00000000411e-06
pygurl            1.681864       1.61252540747e-06  1.99999999495e-06  2.00000000916e-06
yurl              3.790205       3.63394534995e-06  3.00000000664e-06  4.00000000411e-06

```

## Feedback

We'd love to hear your feedback! Feel free to looks at the issues on GitHub and open new ones if needed :)