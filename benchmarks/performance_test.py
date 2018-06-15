from urlparse4 import urlsplit, urljoin
from timeit import default_timer as timer

import argparse


def main():
    parser = argparse.ArgumentParser(description='Measure the time of urlsplit and urljoin')

    parser.add_argument('--encode', action='store_true',
                    help='encode the urls (default: False)')
    args = parser.parse_args()

    encode = args.encode

    urlsplit_time = 0

    for i in range(5):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:
                if encode:
                    url = url.encode()

                start = timer()
                a = urlsplit(url)
                end = timer()

                urlsplit_time += end - start

    print("the urlsplit time with encode in python is", urlsplit_time / 5, "seconds")


    urljoin_time = 0

    for i in range(5):
        with open('urls/chromiumUrls.txt') as f:
            for url in f:
                partial_url = "/asd"

                if encode:
                    url = url.encode()
                    partial_url = partial_url.encode()

                start = timer()
                a = urljoin(url, partial_url)
                end = timer()

                urljoin_time += end - start

    print("the urljoin time with encode in python is", urljoin_time / 5, "seconds")


if __name__ == "__main__":
    main()
