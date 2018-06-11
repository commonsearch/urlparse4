from urlparse4 import urlsplit, urljoin
from timeit import default_timer as timer

total = 0

with open('benchmarks/urls/chromiumUrls.txt') as f:
    for url in f:

        start = timer()

        a = urlsplit(url)

        end = timer()

        total += end - start

print("the total time is", total, "seconds")
