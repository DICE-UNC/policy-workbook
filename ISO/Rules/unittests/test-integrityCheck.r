testIntegrityCheck = maint
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_SIPS = "SIPS"
maint {
# check integrity of a SIP
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racIntegrityCheck (*File, *Coll, *Archive, *S7);
  writeLine ("stdout", "Status for integrity check is *S7");
}
racIntegrityCheck (*File, *Coll, *Archive, *S7) {
#  Policy function to check integrity of a SIP
  *Chk = "";
  *Q1 = select DATA_CHECKSUM where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *Chk = *R1.DATA_CHECKSUM; }
  msiDataObjChksum ("*Coll/*File", "forceChksum=", *Chksum);
  if (*Chk != *Chksum) { *S7 = "1"; }
  else {
    *S7 = "2";
  }
}
INPUT *Archive=$"Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
