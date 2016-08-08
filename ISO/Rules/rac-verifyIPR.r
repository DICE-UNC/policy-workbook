verifyIPR {
  racGlobalSet ();
# rac-verifyIPR.r
# Policy37
# verify access controls are compatible with IPR restrictions
# list non-compatible access controls in Archive-IPA manifest
  msiGetSystemTime (*Tim, "human");
  *Q2a = select USER_ID where USER_NAME = GLOBAL_OWNER;
  foreach (*R2a in *Q2a) {*Uownid = *R2a.USER_ID; }
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep";
  *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Archive-IPR";
  foreach (*R1 in *Q1) {
    *Nam = *R1.META_COLL_ATTR_VALUE;
    *Q2 = select USER_ID where USER_NAME = *Nam;
    foreach (*R2 in *Q2) { *Uid = *R2.USER_ID; }
# remove all other access controls except for GLOBAL_OWNER from *Coll/GLOBAL_ARCHIVES
    *Colt = "*Coll/" ++ GLOBAL_ARCHIVES;
    writeLine ("stdout", "On *Tim,identify access controls other than the IPR owner, *Nam, on collection *Colt");
    writeLine ("stdout", "List persons who have access to the Archives other than the IPR owner");
    *lacc.totalPersons = str(0);
    *Q1 = select COLL_ID, COLL_NAME where COLL_NAME like "*Colt%";
    foreach (*R1 in *Q1) {
      *CollID = *R1.COLL_ID;
      *Colr = *R1.COLL_NAME;
      *Qa = select COLL_ACCESS_USER_ID where COLL_ACCESS_COLL_ID = *CollID;
      foreach (*Ra in *Qa) {
        *Userid = *Ra.COLL_ACCESS_USER_ID;
        if (*Userid != *Uid && *Userid != *Uownid) {
# list access for person from collection
          *Q3 = select USER_NAME where USER_ID = '*Userid';
          foreach (*R3 in *Q3) {*Name = *R3.USER_NAME;}
          if (!contains(*lacc, *Name)) {
            *lacc.*Name = "1";
            *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
          }
        }
      }
    }
    *Q5a = select DATA_ID, DATA_NAME, COLL_NAME where COLL_NAME like "*Colt%";
    foreach (*R5a in *Q5a) {
      *DataID = *R5a.DATA_ID;
      *File = *R5a.DATA_NAME;
      *Colr = *R5a.COLL_NAME;
      *Path = "*Colr/*File";
      *Q6 = select DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = *DataID;
      foreach (*R6 in *Q6) {
        *Userid = *R6.DATA_ACCESS_USER_ID;
        if (*Userid != *Uid && *Userid != *Uownid) {
# list access for person from files
          *Q7 = select USER_NAME where USER_ID = '*Userid';
          foreach (*R7 in *Q7) {*Name = *R7.USER_NAME;}
          if (!contains(*lacc, *Name)) {
            *lacc.*Name = "1";
            *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
          }
        }
      }
    }
    foreach (*L in *lacc) {
      *C1 = *L;
      *C2 = *lacc.*L;
      if (strlen(*C1) < 8) {*C1 = "*C1\t";}
      if (strlen(*C1) < 16) {*C1 = "*C1\t";}
      writeLine("stdout", "*C1   *C2");
    }
  }
  racWriteManifest ("Archive-IPA", *Rep, "stdout");
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
INPUT *Rep=$"Archive-A"
OUTPUT ruleExecOut
