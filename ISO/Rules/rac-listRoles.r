listRoles {
  racGlobalSet ();
# rac-listRoles.r
# Policy10
# count the number of persons in each repository role and list their names
  *Roles = list("Archive-manager", "Archive-archivist", "Archive-admin", "Archive-IT");
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "Generate list of staff and their roles on *Tim");
  *Att = "Repository-Role";
  foreach (*R in *Roles) {
    *Q1 = select count(USER_ID) where META_USER_ATTR_NAME = *Att and META_USER_ATTR_VALUE = *R;
    foreach (*R1 in *Q1) {
      *Num = *R1.USER_ID;
      writeLine("stdout", "  For role *R there are *Num staff members");
      *Q2 = select USER_NAME, USER_TYPE where META_USER_ATTR_NAME = *Att and META_USER_ATTR_VALUE = *R;
      foreach (*R2 in *Q2) {
        *Name = *R2.USER_NAME;
        *Access = *R2.USER_TYPE;
        writeLine("stdout","      *Name    *Access");
      }
    }
  }
  *Rep = GLOBAL_REPOSITORY;
  racWriteManifest ("Archive-SEA", *Rep, "stdout");
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
INPUT null
OUTPUT ruleExecOut
