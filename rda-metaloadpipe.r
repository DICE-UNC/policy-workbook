myTestRule {
# rda-metaloadpipe.r
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
  checkPathInput (*Path);
  msiLoadMetadataFromDataObj(*Path,*Status);
  writeLine("stdout", "Loaded metadata from file *Path");
}
INPUT *Coll=$"Rules/metapipe"
OUTPUT ruleExecOut
