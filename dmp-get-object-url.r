curlGetObj {
# dmp-get-object-url.r
  msiCurlGetObj(*url, *destObj, *written);
  writeLine("stdout", str(*written)++" bytes written");
}
INPUT *url="http://www.textfiles.com/art/ferrari.art",*destObj="/zone/home/rods/file.art"
OUTPUT ruleExecOut
