testAtt {
# test whether metadata attributes are copied on file copy
  *Path = "/lifelibZone/home/rwmoore/test/file1";
  *Dest = "/lifelibZone/home/rwmoore/sub1/file1";
  msiDataObjCopy (*Path, *Dest, "forceFlag=", *Status);
}
INPUT null
OUTPUT ruleExecOut
