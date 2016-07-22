setPublicAccess = main23
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPOSITORY = "Repository"
main23 {
# rac-setPublicAccess.r
# Policy23
# set inheritance and public access on GLOBAL_REPOSITORY collection
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  msiSetACL ("recursive", "inherit", "anonymous", *Coll);
  msiSetACL ("default", "read", "anonymous", *Coll);
  writeLine ("stdout", "Set public access recursively for collection *Coll");
}
INPUT null
OUTPUT ruleExecOut
