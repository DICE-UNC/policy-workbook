curlGetStr {
# hipaa-issue-url.r
# get string from a URL
  msiCurlGetStr(*url, *Buffer);
  writeLine("stdout", str(*Buffer)++" returned string");
}
INPUT *url="http://myurl"
OUTPUT ruleExecOut
