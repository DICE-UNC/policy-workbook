myTestRule {
# dmp-set-public.r
# Input parameters are:
#  Recursion flag
#    default
#    recursive  - valid if access level is set to inherit
#  Access Level
#    null
#    read
#    write
#    own
#    inherit
#  User name or group name who will have ACL changed
#  Path or file that will have ACL changed
  *Home="/$rodsZoneClient/home/$userNameClient/";
  *Path= *Home ++ *RelativeCollection;
  checkCollInput (*Path);
  msiSetACL("recursive", "inherit", "anonymous",*Path);
  msiSetACL("default", "read", "anonymous", *Path);
  writeLine("stdout”, “Set inheritance on *Path and access to anonymous");
}
INPUT  *RelativeCollection="sensor"
OUTPUT ruleExecOut
