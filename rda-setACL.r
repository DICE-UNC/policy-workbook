myTestRule {
# rda-setACL.r
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
  checkUserInput (*User, $rodsZoneClient);
  checkFileInput (*File);
  *Home="/$rodsZoneClient/home/$userNameClient/";
  *Coll= *Home ++ *RelativeCollection;
  checkCollInput (*Coll);
  *Path = "*Coll/*File";
  checkPathInput (*Path);
  msiSetACL("default", *Acl,*User,*Path);
  writeLine("stdout", "Set owner access for *User on file *Path");
}
INPUT *User="public", *RelativeCollection="test", *File="foo1", *Acl = "write"
OUTPUT ruleExecOut
