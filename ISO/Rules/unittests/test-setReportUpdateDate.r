setReportUpdateDate = main2
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_OWNER = "rwmoore"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_VERSIONS = "Versions"
main2 {
# rac-setReportUpdateDate.re
# Policy2
# check whether a file has been put into GLOBAL_ACCOUNT/GLOBAL_REPOSITORY/GLOBAL_REPORTS and version the file
  msiSplitPath (*Path, *Coll, *File);
  racFindRep (*Coll, *Rep);
  if (*Rep != "") {
# Create a version in GLOBAL_VERSIONS
    *Colh = GLOBAL_ACCOUNT ++ "/*Rep";
    msiDataObjChksum(*Path, "forceChksum=", *Chksum);
    msiGetSystemTime (*Tim, "unix");
    racVersionFile(*File, *Rep, *Coll);
# verify Archive-Report is set for the collection
    racVerifyAuditReport (*Colh, *Rep, *Tim)
# add attribute for Audit-Date to the file
    racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim)
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
racVerifyAuditReport (*Coll, *Rep, *Tim) {
# policy function to check that Archive-Report or Repository-Report is defined on collection *Coll
  *Period = str (int(GLOBAL_AUDIT_PERIOD) * 86400);
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  writeLine ("stdout", "Att *Att, Coll *Coll, Rep *Rep");
  *Q3 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Att;
  foreach (*R3 in *Q3) {*Num1 = *R3.META_COLL_ATTR_ID;}
  if (*Num1 == "0" ) {
# add default update period to collection
    addAVUMetadataToColl (*Coll, *Att, *Period, "", *Stat);
  }
  writeLine ("stdout", "Num1 *Num1, Period *Period");
}
racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim) {
# policy function to set the Audit-Date attribute on a file
  *Path = "*Coll/*File";
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  writeLine ("stdout", "Att *Att, File *File, Rep *Rep, Colh *Colh, Coll *Coll");
  *P = "0";
  *Q4 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colh and META_COLL_ATTR_NAME = *Att;
  foreach (*R4 in *Q4) {*P = *R4.META_COLL_ATTR_VALUE;}
  writeLine ("stdout", "P *P");
  *T = str (double (*Tim) + double(*P));
# check that no metadata exists on file for 'Audit-Date'
  *Q5 = select count (META_DATA_ATTR_ID) where COLL_NAME = *Coll and DATA_NAME = *File and META_DATA_ATTR_NAME
 = 'Audit-Date';
  foreach (*R5 in *Q5) { *N = *R5.META_DATA_ATTR_ID; }
  if (*N != "0" ) {
    *Q6 = select META_DATA_ATTR_VALUE, META_DATA_ATTR_UNITS where COLL_NAME = *Coll and DATA_NAME = *File and
META_DATA_ATTR_NAME = 'Audit-Date';
    foreach (*R6 in *Q6) {
      *V = *R6.META_DATA_ATTR_VALUE;
      *U = *R6.META_DATA_ATTR_UNITS;
      deleteAVUMetadata (*Path, "Audit-Date", *V, *U, *Status);
    }
# no delete of Audit-Date from versioned file is needed since copy does not copy metadata.
  }
  addAVUMetadata (*Path, "Audit-Date", *T, "", *Stat);
}
racVersionFile (*File, *Rep, *Coll) {
# policy function to version a file
  *Path = "*Coll/*File";
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
  msiDataObjRepl(*Pathver, "updateRepl=++++verifyChksum=", *Stat);
  *Per = GLOBAL_OWNER;
  msiSetACL("default", "own", *Per, *Pathver);
}
INPUT *Path="/lifelibZone/home/rwmoore/Archive-A/Reports/Archive-AU.docx"
OUTPUT ruleExecOut
