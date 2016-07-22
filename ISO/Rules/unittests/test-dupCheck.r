checkDup = maind
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_AIPS = "AIPS"
GLOBAL_SIPS = "SIPS"
maind {
# test if an AIP already exists
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  racDupCheck (*File, *Coll, *Archive, *S8);
  writeLine ("stdout", "Status for duplicate check is *S8");
}
racDupCheck (*File, *Coll, *Archive, *S8) {
# Policy function to check whether AIP already exists
# AIPs are stored in GLOBAL_ACCOUNT/*Archive/GLOBAL_AIPS
  msiGetSystemTime (*Tim, "human");
  *Ca = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_AIPS;
  *S8 = "0";
  *Q1 = select count (DATA_NAME) where DATA_NAME = *File and COLL_NAME = *Ca;
  foreach (*R1 in *Q1 ) {
    *Num = *R1.DATA_NAME;
    if (*Num == "0") {
      *S8 = "1";
    }
  }
  if (*S8 != "1" ) { *S8 = "2"; }
  addAVUMetadata ("*Coll/*File", "Audit-CheckDup", *S8, *Tim, *Stat);
}
INPUT *Archive=$"Archive-A", *File=$"rec3"
OUTPUT ruleExecOut
