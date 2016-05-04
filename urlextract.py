from HTMLParser import HTMLParser
import sys

f = open(sys.argv[1], "r")

html = f.read()
print html

class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        # print "Start tag:", tag
        for attr in attrs:
            (a, v) = attr
            if a == "href":
		print v

parser = MyHTMLParser()

parser.feed(html)
