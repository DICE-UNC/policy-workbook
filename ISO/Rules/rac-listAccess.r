listAccess = main32
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_AUDIT_PERIOD = "365"
GLOBAL_OWNER = "rwmoore"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_VERSIONS = "Versions"
main32 {
# rac-listAccess.r
# Policy32
# list the access permissions on the GLOBAL_ACCOUNT/*Archive collection in report Archive-ALRA
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive";
  writeLine ("stdout", "List persons with access to *Coll");
  writeLine ("stdout", "Name            Number of access permissions");
  *lacc.totalPersons = str(0);
  *Q1 = select COLL_ID where COLL_NAME like "*Coll%";
  foreach (*R1 in *Q1) {
    *CollID = *R1.COLL_ID;
    *Q2 = select COLL_ACCESS_USER_ID, COLL_ACCESS_TYPE where COLL_ACCESS_COLL_ID = *CollID;
    foreach (*R2 in *Q2) {
      *Userid = *R2.COLL_ACCESS_USER_ID;
      *Type = *R2.COLL_ACCESS_TYPE;
      *Q3 = select USER_NAME where USER_ID = '*Userid';
      foreach (*R3 in *Q3) {*Name = *R3.USER_NAME;}
      if (!contains(*lacc, *Name)) {
        *lacc.*Name = "1";
        *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
      }
      *Q4 = select count(USER_NAME) where USER_GROUP_ID = '*Userid';
      foreach (*R4 in *Q4) {
        *Num = *R4.USER_NAME;
        if(int(*Num) > 1) {
          *Q5 = select USER_NAME where USER_GROUP_ID = '*Userid';
          foreach (*R5 in *Q5) {
            *Usg = *R5.USER_NAME;
            if (*Usg != *Name) {
              if (contains(*lacc, *Usg)) {
                *lacc.*Usg = str(int(*lacc.*Usg) + 1);
              } else {
                *lacc.*Usg = "1";
                *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
              } 
            } 
          } 
        } 
      } 
    } 
  }
  *Q5a = select DATA_ID where COLL_NAME like "*Coll%";
  foreach (*R5a in *Q5a) {
    *DataID = *R5a.DATA_ID;
    *Q6 = select DATA_ACCESS_USER_ID, DATA_ACCESS_TYPE where DATA_ACCESS_DATA_ID = *DataID;
    foreach (*R6 in *Q6) {
      *Userid = *R6.DATA_ACCESS_USER_ID;
      *Type = *R6.DATA_ACCESS_TYPE;
      *Q7 = select USER_NAME where USER_ID = '*Userid';
      foreach (*R7 in *Q7) {*Name = *R7.USER_NAME;}
      if (!contains(*lacc, *Name)) {
        *lacc.*Name = "1";
        *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
      }
      *Q8 = select count(USER_NAME) where USER_GROUP_ID = '*Userid';
      foreach (*R8 in *Q8) {
        *Num = *R8.USER_NAME;
        if(int(*Num) > 1) {
          *Q9 = select USER_NAME where USER_GROUP_ID = '*Userid';
          foreach (*R9 in *Q9) {
            *Usg = *R9.USER_NAME;
            if (*Usg != *Name) {
              if (contains(*lacc, *Usg)) {
                *lacc.*Usg = str(int(*lacc.*Usg) + 1);
              } else {
                *lacc.*Usg = "1";
                *lacc.totalPersons = str(int(*lacc.totalPersons) + 1);
              }
            }
          }
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
   racSaveFile ("Archive-ALRA", *Archive);
}
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
