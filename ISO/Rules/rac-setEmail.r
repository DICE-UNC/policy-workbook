setEmail = main44
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
main44 {
# rac-setEmail.r
# Policy44
# set Archive-Email on the GLOBAL_ACCOUNT/*Archive collection
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive";
  isColl(*Coll, "stdout", *Status);
  if (*Status == 0) {
    if (*Email != "") {
      addAVUMetadataToColl (*Coll, "Archive-Email", *Email, "", *Stat);
      if (*Stat == "0" ) {writeLine ("stdout", "Added E-mail address to Archive-Email, *Email, for *Coll");}
    }
  }
}
INPUT *Email=$"rwmoore@renci.org", *Archive=$"Archive-A"
OUTPUT ruleExecOut
