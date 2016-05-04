setInheritance {
# test-setInheritance.r
  *Home="/$rodsZoneClient/home/$userNameClient/";
  *Path= *Home ++ *RelativeCollection;
  checkCollInput (*Path);
  msiSetACL("recursive", "inherit", "$userNameClient",*Path);
  writeLine("stdout", "Set inheritance on *Path");
}
INPUT  *RelativeCollection=$"sensor"
OUTPUT ruleExecOut
