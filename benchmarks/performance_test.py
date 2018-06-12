from urlparse4 import urlsplit, urljoin
from timeit import default_timer as timer

from sys import argv

encode = False

try:
    if argv[1] == "encode":
        encode = True
except IndexError:
    print("encode is not defined, continue with the program...")

if encode:
    total = 0

    for i in range(50):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:

                start = timer()

                a = urlsplit(url.encode())

                end = timer()

                total += end - start

    print("the urlsplit time with encode in python is", total / 50, "seconds")


    total2 = 0

    for i in range(50):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:

                start = timer()

                a = urljoin(url.encode(), "/asd".encode())

                end = timer()

                total2 += end - start

    print("the urljoin time with encode in python is", total2 / 50, "seconds")

else:
    total = 0
    for i in range(50):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:

                start = timer()

                a = urlsplit(url)

                end = timer()

                total += end - start

    print("the urlsplit time without encoding in python is", total / 50, "seconds")


    total2 = 0
    for i in range(50):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:

                start = timer()

                a = urljoin(url, "/asd")

                end = timer()

                total2 += end - start

    print("the urljoin time without encoding in python is", total2 / 50, "seconds")
