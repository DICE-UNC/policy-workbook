myTestRule {
# test-metaloadpipe.r
#Input parameter is:
#  Path name of file containing metadata
#    Format of file is
#    C-collection-name |Attribute |Value |Units
#    Path-name-for-file |Attribute |Value
#Example
#    /lifelibZone/home/rwmoore/foo1 |Test |34
#Output parameter is:
#  Status
  *Path= "/$rodsZoneClient/home/$userNameClient/" ++ *Coll;
  writeLine ("stdout", "*Path");
  msiLoadMetadataFromDataObj(*Path,*Status);
  writeLine("stdout", "*Status Loaded metadata from file *Path");
}
INPUT *Coll="Class-INLS624/rules/metapipe1"
OUTPUT ruleExecOut
