storeReportVersion = main1
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_VERSIONS = "Versions"
GLOBAL_OWNER = "rwmoore"
main1 {
# test-storeReportVersion.r
# Policy1
# check whether a file has been put into GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_REPORTS and version the file
  msiSplitPath (*Path, *Coll, *File);
  racFindRep (*Coll, *Rep);
  if (*Rep != "") {
# Create a version in GLOBAL_VERSIONS
    msiDataObjChksum(*Path, "forceChksum=", *Chksum);
    racVersionFile(*File, *Rep);
  }
}
racFindRep (*Coll, *Rep) {
# policy function to identify the repository referenced by the path name
  *Colla = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY ++ "/" ++ GLOBAL_REPORTS;
  *Rep = "";
  if (*Coll == *Colla) { *Rep = GLOBAL_REPOSITORY; }
  else {
    *Colt = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
    *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colt and META_COLL_ATTR_NAME = "Repository-Archives"
    foreach (*R1 in *Q1) {
      *Nam = *R1.META_COLL_ATTR_VALUE;
      *C = GLOBAL_ACCOUNT ++ "/*Nam/" ++ GLOBAL_REPORTS;
      if (*Coll == *C) {
        *Rep = *Nam;
        break;
      }
    }
  }
}
racVersionFile (*File, *Rep) {
# Create the backup collection.  If this fails it is probably due to the collection already
# existing.  Ignore that error.
    *DesColl = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_VERSIONS;
    *err = errorcode(msiCollCreate(*DesColl, "1", *status));
# Copy report into Versions and increment the version number
    *Q2 = select DATA_NAME where COLL_NAME = '*DesColl' and DATA_NAME like '*File..%';
    *Num = 0;
    foreach (*R2 in *Q2) {
      *Ver = *R2.DATA_NAME;
      *Vend = int(substr(*Ver, strlen(*File)+2, strlen(*Ver)));
      if (*Vend > *Num) {*Num = *Vend;}
    }
    *Numinc = *Num + 1;
    *Vers = *File ++ ".." ++ "*Numinc";
    *Pathver = *DesColl ++ "/" ++ *Vers;
    msiDataObjCopy(*Path, *Pathver, "verifyChksum=", *Status);
    *Per = GLOBAL_OWNER;
    msiSetACL("default", "own", *Per, *Pathver);
}
INPUT *Path=$"/lifelibZone/home/rwmoore/Repository/Reports/Archive-MS.docx"
OUTPUT ruleExecOut
