setAccess = main31
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
main31 {
# rac-setAccess.r
# Policy31
# set access control on collection, turn on inheritance
  msiGetSystemTime (*Tim, "unix");
  writeLine ("stdout", "On *Tim, change access controls");
#  *Coll = GLOBAL_ACCOUNT ++ "/*RelColl";
  *Coll = "/lifelibZone/home/rwmoore/Archive-A";
  writeLine ("stdout", "*Coll");
  msiSetACL ("recursive", "inherit", "", *Coll);
}
INPUT *RelColl="Archive-A"
OUTPUT ruleExecOUt
