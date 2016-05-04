myTestRule {
# dmp-set-public.r
#Set public access on a collection and turn on inheritance
  *Home="/$rodsZoneClient/home/$userNameClient/";
  *Path= *Home ++ *RelativeCollection;
  checkCollInput (*Path);
  msiSetACL("recursive", "inherit", "anonymous",*Path);
  msiSetACL("default", "read", "anonymous", *Path);
  writeLine("stdout", "Set inheritance on *Path and access to anonymous");
}
INPUT  *RelativeCollection="sub1"
OUTPUT ruleExecOut
