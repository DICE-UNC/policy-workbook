from HTMLParser import HTMLParser
from urlparse import urljoin
import sys

f = open(sys.argv[1], "r")
prefix = sys.argv[2]

html = f.read()

class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for attr in attrs:
            (a, v) = attr
            if a == "href":
		v = urljoin(prefix, v)
		print v

parser = MyHTMLParser()

parser.feed(html)
