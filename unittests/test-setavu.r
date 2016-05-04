testSetAVU {
# call the msiSetAVU microservice
  *Path = "/lifelibZone/home/rwmoore/Rules/test-write.r";
  msiSetAVU("-d", *Path, "test", "value", "unit");
  writeLine ("stdout", "add metadata to *Path");
}
INPUT null
OUTPUT ruleExecOut
