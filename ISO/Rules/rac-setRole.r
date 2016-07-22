setRole = main9
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
main9 {
# rac-setRole.r
# Policy9
# For a specified user, set their repository role
# Define attribute Repository_role with value from 
# "Archive-manager", "Archive-archivist", "Archive-admin", "Archive-IT"
  *Att = "Repository-Role";
# verify role name
  *Roles = list( "Archive-manager", "Archive-archivist", "Archive-admin", "Archive-IT");
  *Found = 0;
  foreach (*R in *Roles) {
    if (*R == *Val) {
      *Found = 1;
      break;
    }
  }
  if (*Found == 1) {
    *Q1 = select count(META_USER_ATTR_ID) where USER_NAME = *Name and META_USER_ATTR_NAME = *Att;
    foreach (*R1 in *Q1) {*Num = *R1.META_USER_ATTR_ID;}
    if (*Num != "0") {
      *Q2 = select META_USER_ATTR_VALUE where USER_NAME = *Name and META_USER_ATTR_NAME = *Att;
      foreach (*R2 in *Q2) {
        *R = *R2.META_USER_ATTR_VALUE;
        msiAddKeyVal(*Keyval0, *Att, *R);
        msiRemoveKeyValuePairsFromObj (*Keyval0, *Name, "-u");
      }
    }
    msiAddKeyVal(*Keyval, *Att, *Val);
    msiAssociateKeyValuePairsToObj(*Keyval, *Name, "-u");
    writeLine ("stdout", "Added role *Val to *Name");
    racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
  } else {
    writeLine ("stdout", "Valid role was not specified, INPUT had value *Val");
    writeLine ("stdout", "Entry must be one of *Roles");
  }
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
INPUT *Name=$"rwmoore", *Val=$"Archive-manager"
OUTPUT ruleExecOut
