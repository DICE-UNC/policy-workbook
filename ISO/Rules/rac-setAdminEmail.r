setAdminEmail = main45
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPOSITORY = "Repository"
main45 {
# rac-setAdminEmail.r
# Policy45
# set Repository-Email on the GLOBAL_ACCOUNT/GLOBAL_REPOSITORY collection
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  isColl(*Coll, "stdout", *Status);
  if (*Status == 0) {
    if (*Email != "") {
      addAVUMetadataToColl (*Coll, "Repository-Email", *Email, "", *Stat);
      if (*Stat == "0" ) {writeLine ("stdout", "Added E-mail address to Repository-Email, *Email, for *Coll");}
    }
  }
}
INPUT *Email=$"rwmoore@renci.org"
OUTPUT ruleExecOut
