myTestRule {
# rda-metastrip.r
# Input parameters are:
#  Path to data file
#  Optional flag - not used 
# Output parameter is:
#  Status
  *Path="/$rodsZoneClient/home/$userNameClient/" ++ *Path;
  checkPathInput (*Path);
  # Delete the AVUs
  msiStripAVUs(*Path,"",*Status);
  writeLine("stdout","Removed metadata from *Path");
}
INPUT *Path=$"Rules/sample.email"
OUTPUT ruleExecOut
