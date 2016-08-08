setRole {
  racGlobalSet ();
# rac-setRole.r
# Policy9
# For a specified user, set their repository role
# Define attribute Repository_role with value from 
# "Archive-manager", "Archive-archivist", "Archive-admin", "Archive-IT"
  msiGetSystemTime (*Tim, "human");
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
  writeLine ("stdout", "Set repository role for a staff member on *Tim");
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
    writeLine ("stdout", "  Added role *Val to *Name");
  } else {
    writeLine ("stdout", "  Valid role was not specified, INPUT had value *Val");
    writeLine ("stdout", "  Entry must be one of *Roles");
  }
  racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
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
INPUT *Name=$"rwmoore", *Val=$"Archive-manager"
OUTPUT ruleExecOut
