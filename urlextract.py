from HTMLParser import HTMLParser
import sys

f = open(sys.argv[1], "r")

html = f.read()

class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for attr in attrs:
            (a, v) = attr
            if a == "href":
		print v

parser = MyHTMLParser()

parser.feed(html)
