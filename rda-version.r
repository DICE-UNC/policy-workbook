myTestRule {
# rda-version.r
# Input parameters are:
#   Source stage area path 
#   Destination save path
# Output parameter is:
#    Status Integer code for status of operation
  *Stage = "/$rodsZoneClient/home/$userNameClient/" ++ *Source; 
  *Archive = "/$rodsZoneClient/home/$userNameClient/" ++ *Dest;
  checkCollInput (*Stage);
  checkCollInput (*Archive);
  *Q1 = select DATA_NAME where COLL_NAME = '*Stage';
  foreach (*R1 in *Q1) {
    *D = *R1.DATA_NAME;
    *SourceFile = *Stage ++ "/" ++ *D;
    *DestFile = "*Archive/*D";
    msiDataObjCopy(*SourceFile, *DestFile, "forceFlag=", *Status);
    msiSetACL("default", "own", $userNameClient, *DestFile);
    writeLine("stdout","File *SourceFile copied to *Archive with status *Status");
  }
}
INPUT *SourceFile="stage", *Dest="SaveVersions"
OUTPUT ruleExecOut, *Status

