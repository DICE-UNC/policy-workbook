checkAllSIPS {
  racGlobalSet ();
# Policy52
# rac-checkAllSIPS
# check all SIPS for compliance with preservation policies
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "*Coll analyzed for compliance on *Tim");
  *S0 = 0;  *S1 = 0; *S2 = 0; *S3 = 0; *S4 = 0;
  *S5 = 0; *S6 = 0; *S7 = 0; *S8 = 0;
  *Q1 = select DATA_NAME where COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Path = "*Coll/*File";
    *Q2 = select count(META_DATA_ATTR_ID) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = "Audit-Comply";
    foreach (*R2 in *Q2) {
      *Num = *R2.META_DATA_ATTR_ID;
      if (*Num == "0") {
         *S0 = *S0 + 1;
         writeLine ("stdout", "    Compliance not checked for *Path");
      } else {
        *Q3 = select META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = "Audit-Comply";
        foreach (*R3 in *Q3) {
          *Val = *R3.META_DATA_ATTR_VALUE;
          if (*Val == "1" ) { *S1 = *S1 + 1; }
          if (*Val == "2" ) {
            *S2 = *S2 + 1;
            writeLine ("stdout", "    Virus check failed for *Path");
          }
          if (*Val == "3" ) {
            *S3 = *S3 + 1;
            writeLine ("stdout", "    Protected data check failed for *Path");
          }
          if (*Val == "4" ) {
            *S4 = *S4 + 1;
            writeLine ("stdout", "    Format check failed for *Path");
          }
          if (*Val == "5" ) {
            *S5 = *S5 + 1;
            writeLine ("stdout", "    Metadata check failed for *Path");
          }
          if (*Val == "6" ) {
            *S6 = *S6 + 1;
            writeLine ("stdout", "    Vocabulary check failed for *Path");
          }
          if (*Val == "7" ) {
            *S7 = *S7 + 1;
            writeLine ("stdout", "    Integrity check failed for *Path");
          }
          if (*Val == "8" ) {
            *S8 = *S8 + 1;
            writeLine ("stdout", "    Duplication check failed for *Path");
          }
        }
      }
    }
  }
  writeLine ("stdout", "Totals for SIP compliance check");
  writeLine ("stdout", "    Virus check failed for *S2 files");
  writeLine ("stdout", "    Protected data check failed for *S3 files");
  writeLine ("stdout", "    Format check failed for *S4 files");
  writeLine ("stdout", "    Metadata check failed for *S5 files");
  writeLine ("stdout", "    Vocabulary check failed for *S6 files");
  writeLine ("stdout", "    Integrity check failed for *S7 files");
  writeLine ("stdout", "    Duplication check failed for *S8 files");
  racSaveFile ("Archive-SAPA", *Archive);
}
racGlobalSet = maing
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_DIPS = "DIPS"
GLOBAL_EMAIL = "rwmoore@renci.org"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_METADATA = "Metadata"
GLOBAL_OWNER = "rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_RULES = "Rules"
GLOBAL_SIPS = "SIPS"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_VERSIONS = "Versions"
maing{}
racSaveFile (*File, *Rep) {
# policy function to write standard out to *File in collection GLOBAL_REPORTS
  *Colh = GLOBAL_ACCOUNT ++ "/*Rep";
  *Coll = "*Colh/" ++ GLOBAL_REPORTS;
  *Path = "*Coll/*File";
  *Res = GLOBAL_STORAGE;
  *Per = GLOBAL_OWNER;
  isColl (*Coll, "stdout", *Status);
  *DesColl = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_VERSIONS;
  isColl (*DesColl, "stdout", *Status);
# check for presence of output file
  *Q1 = select count(DATA_ID) where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) { *N = *R1.DATA_ID; }
  if (*N == "0") {
    *Flags = "destRescName=*Res++++forceFlag=";
     msiDataObjCreate(*Path, *Flags, *L_FD);
  } else {
    *Flags = "objPath=*Path++++openFlags=O_RDWR";
    msiDataObjOpen (*Flags, *L_FD);
  }
  msiDataObjWrite(*L_FD, "stdout", *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiFreeBuffer ("stdout");
  msiDataObjRepl(*Path, "updateRepl=++++verifyChksum=", *Stat);
  msiSetACL("default", "own", *Per, *Path);
# add attribute for Audit-Date to the file
  msiGetSystemTime (*Tim, "unix");
# check that Archive-Report is defined on collection
  racVerifyAuditReport (*Colh, *Rep, *Tim);
# set the Audit-Date on a file
  racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim);
# Copy report into Reports/Versions and increment the version number
  racVersionFile (*File, *Rep, *Coll);
}

racSetAuditDateFile (*File, *Rep, *Colh, *Coll, *Tim) {
# policy function to set the Audit-Date attribute on a file
  *Path = "*Coll/*File";
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  *Q4 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colh and META_COLL_ATTR_NAME = *Att;
  foreach (*R4 in *Q4) {*P = *R4.META_COLL_ATTR_VALUE;}
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

racVerifyAuditReport (*Coll, *Rep, *Tim) {
# policy function to check that Archive-Report is defined on collection *Coll
  *Period = str (int(GLOBAL_AUDIT_PERIOD) * 86400);
  *Att = "Archive-Report";
  if (*Rep == GLOBAL_REPOSITORY) { *Att = "Repository-Report"; }
  *Q3 = select count(META_COLL_ATTR_ID) where COLL_NAME = *Coll and META_COLL_ATTR_NAME = *Att;
  foreach (*R3 in *Q3) {*Num1 = *R3.META_COLL_ATTR_ID;}
  if (*Num1 == "0" ) {
# add default update period to collection
    addAVUMetadataToColl (*Coll, *Att, *Period, "", *Stat);
  }
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
racWriteManifest( *OutFile, *Rep, *Source ) {
# create manifest file
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep/" ++ GLOBAL_MANIFESTS;
  *Res = GLOBAL_STORAGE;
  isColl (*Coll, "stdout", *Status);
  isData (*Coll, *OutFile, *Status);
  *Lfile = "*Coll/*OutFile";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
    msiDataObjClose (*L_FD, *Status);
  }
# update manifest file with information from *Source
  msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
  msiDataObjLseek(*L_FD, "0", "SEEK_END", *Status);
  msiDataObjWrite(*L_FD, *Source, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiDataObjRepl(*Lfile, "updateRepl=++++verifyChksum=", *Stat);
}

INPUT *Archive=$"Archive-A"
OUTPUT ruleExecOut
