saveManifests {
racGlobalSet ();
# Policy55
# rac-saveManifests.r
# version all manifests and start new manifest files
  msiGetSystemTime (*Tim, "human");
  *Colla = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  writeLine ("stdout", "Versioned all manifests in *Colla and removed on *Tim");
  *Coll = "*Colla/" ++ GLOBAL_MANIFESTS;
  *Q1 = select DATA_NAME where COLL_NAME = *Coll;
  foreach (*R1 in *Q1 ) {
    *File = *R1.DATA_NAME;
    racVersionFile (*File, GLOBAL_REPOSITORY, *Coll);
# delete manifest
    *Path = "*Coll/*File";
    msiDataObjUnlink ("objPath=*Path++++forceFlag=", *Stat);
    writeLine ("stdout", "  Versioned *Path");
  }
  racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
  msiFreeBuffer ("stdout");
# process manifests in *Archive
  *Q2 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colla and META_COLL_ATTR_NAME = 'Repository-Archives';
  foreach (*R2 in *Q2) {
    *Archive = *R2.META_COLL_ATTR_VALUE;
    *Collb = GLOBAL_ACCOUNT ++ "/*Archive";
    writeLine ("stdout", "Versioned all manifests in *Collb and removed on *Tim");
    *Coll = "*Collb/" ++ GLOBAL_MANIFESTS;
    *Q3 = select DATA_NAME where COLL_NAME = *Coll;
    foreach (*R3 in *Q3 ) {
      *File = *R3.DATA_NAME;
      racVersionFile (*File, *Archive, *Coll);
# delete manifest
      *Path = "*Coll/*File";
      msiDataObjUnlink ("objPath=*Path++++forceFlag=", *Stat);
      writeLine ("stdout", "  Versioned *Path");
    }
    racWriteManifest ("Archive-PAA", *Archive, "stdout");
    msiFreeBuffer ("stdout");
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
INPUT null
OUTPUT ruleExecOut
  
