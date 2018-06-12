from urlparse4 import urlsplit, urljoin
from timeit import default_timer as timer

total = 0

with open('urls/chromiumUrls.txt') as f:
    for url in f:

        start = timer()

        a = urlsplit(url.encode())

        end = timer()

        total += end - start

print("the urlsplit time is", total, "seconds")


total2 = 0

with open('urls/chromiumUrls.txt') as f:
    for url in f:

        start = timer()

        a = urljoin(url.encode(), "/asd".encode())

        end = timer()

        total2 += end - start

print("the urljoin time is", total2, "seconds")
