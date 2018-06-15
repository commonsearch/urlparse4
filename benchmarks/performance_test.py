from urlparse4 import urlsplit, urljoin
from timeit import default_timer as timer

import argparse


encode = False

try:
    if argv[1] == "encode":
        encode = True
except IndexError:
    print("encode is not defined, continue with the program...")

if encode:
    urlsplit_time = 0

    for i in range(5):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:

                start = timer()

                a = urlsplit(url.encode())

                end = timer()

                urlsplit_time += end - start

    print("the urlsplit time with encode in python is", urlsplit_time / 5, "seconds")


    urljoin_time = 0

    for i in range(5):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:

                start = timer()

                a = urljoin(url.encode(), "/asd".encode())

                end = timer()

                urljoin_time += end - start

    print("the urljoin time with encode in python is", urljoin_time / 5, "seconds")
