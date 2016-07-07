from numpy import median, percentile, mean
from time import clock
import os
import gc
import tabulate
import sys

import urlparse
import urlparse2
from uritools import urisplit as uritools_urisplit
from uritools import urijoin as uritools_urijoin

from yurl import URL as yurl_url
import pygurl

# import urlparse3
# import cyuri

sys.path.insert(-1, os.path.dirname(os.path.dirname(__file__)))
import urlparse4

gc.disable()

REPEATS = 10

URLS = []
for fp in os.listdir("tests/urls/"):
    with open("tests/urls/%s" % fp) as f:
        URLS += f.readlines()

data = []


def benchmark(name, func, debug=False):
    times = []
    for n in range(0, REPEATS):
        for i, url in enumerate(URLS):
            u = url.strip()
            if debug:
                print u
            t = clock()
            func(u)
            times.append(clock() - t)

    row = [name, sum(times), mean(times), median(times), percentile(times, 90)]
    print row
    data.append(row)


def title(name):
    data.append(["", "", "", "", ""])
    data.append(["%s:" % name, "", "", "", ""])
    data.append(["----", "----", "----", "----", "----"])

title("urlsplit")
benchmark("urlparse4", lambda url: urlparse4.urlsplit(url))
benchmark("pygurl", lambda url: pygurl.ParseStandard(url))
benchmark("urlparse2", lambda url: urlparse2.urlsplit(url))
benchmark("urlparse", lambda url: urlparse.urlsplit(url))
benchmark("uritools", lambda url: uritools_urisplit(url))
benchmark("yurl", lambda url: yurl_url(url))

title("urljoin_sibling")
benchmark("urlparse4", lambda url: urlparse4.urljoin(url, "sibling.html?q=1#e=b"))
benchmark("urlparse2", lambda url: urlparse2.urljoin(url, "sibling.html?q=1#e=b"))
benchmark("urlparse", lambda url: urlparse.urljoin(url, "sibling.html?q=1#e=b"))
benchmark("uritools", lambda url: uritools_urijoin(url, "sibling.html?q=1#e=b"))
benchmark("pygurl", lambda url: pygurl.URL(url).Resolve("sibling.html?q=1#e=b"))
benchmark("yurl", lambda url: yurl_url(url) + yurl_url("sibling.html?q=1#e=b"))

# Not very representative because some libraries have functions to access the host directly without parsing the rest.
# Might still be useful for some people!
title("hostname")
benchmark("urlparse4", lambda url: urlparse4.urlsplit(url).hostname)
benchmark("urlparse2", lambda url: urlparse2.urlsplit(url).hostname)
benchmark("urlparse", lambda url: urlparse.urlsplit(url).hostname)
benchmark("uritools", lambda url: uritools_urisplit(url).host)
benchmark("pygurl", lambda url: pygurl.URL(url).host())
benchmark("yurl", lambda url: yurl_url(url).host)

# Segfault: https://github.com/mitghi/cyuri/issues/1
# cyuri_parser = cyuri.uriparser()
# benchmark("cyuri_urlsplit", lambda url: cyuri_parser.components(url), debug=True)

# Breaks on simple URLs like http://1-14th.com/timeline-4-66T.htm
# benchmark("urlparse3_urlsplit", lambda url: urlparse3.parse_url(url))


print
print "Benchmark results on %s URLs x %s times, in seconds:" % (len(URLS), REPEATS)
print
print
print tabulate.tabulate(data, headers=["Name", "Sum", "Mean", "Median", "90%"])
print
