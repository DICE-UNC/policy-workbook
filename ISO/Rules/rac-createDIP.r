createDIP {
  racGlobalSet ();
# Policy 50
# rac-createDIP.r
# create a metadata file that contains all metadata associated with an AIP
  msiGetSystemTime (*Tim. "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_ARCHIVES;
  *Path = "*Coll/*Aip";
  *Buf = "Create a DIP";
  msiGetDataObjAIP (*Path, *Buf);
  *Dest = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_DIPS;
  isColl (*Dest, "stdout", *Stat);
  *Path = "*Dest/*Aip-meta";
  *Res = GLOBAL_STORAGE;
  *Per = GLOBAL_OWNER;
# create the DIP
  *Dfile = "destRescName=*Res++++forceFlag=";
  msiDataObjCreate(*Path, *Dfile, *L_FD);
  msiDataObjWrite(*L_FD, *Buf, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiFreeBuffer(*Buf);
  msiDataObjRepl(*Path, "updateRepl=++++verifyChksum=", *Stat);
  msiSetACL("default", "own", *Per, *Path);
  racWriteManifest ("Archive-PAA", *Archive, "stdout");
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
INPUT *Archive=$"Archive-A", *Aip=$"rec3"
OUTPUT ruleExecOut
