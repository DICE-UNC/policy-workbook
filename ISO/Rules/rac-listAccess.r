listAccess {
  racGlobalSet ();
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
   racWriteManifest ("Archive-ALRA", *Archive, "stdout");
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

INPUT *Archive=$"Archive-A"
OUTPUT ruleExecOut
