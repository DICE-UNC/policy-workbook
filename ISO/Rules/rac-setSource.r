setSource {
  racGlobalSet ();
# rac-setSource.r
# Policy39
# set Audit-Source and Audit-Depositor on a file within the GLOBAL_SIPS or GLOBAL_ACHIVES collection
  if (*Type == "AIP" || *Type == "SIP") {
  } else {
    writeLine ("stdout", "allowed values for \*Type are AIP or SIP");
    fail;
  } 
  msiGetSystemTime (*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_SIPS;
  if (*Type == "AIP") { *Coll = GLOBAL_ACCOUNT ++ "/*Archive/" ++ GLOBAL_ARCHIVES; }
  *Path = "*Coll/*File";
  writeLine ("stdout", "Set Audit-Source and Audit-Depositor for *Path on *Tim");
# note that the *File name may be a relative path containing a subcollection
  msiSplitPath (*Path, *C, *F);
  isColl(*C, "stdout", *St);
  isData (*C, *F, *Status);
  if (*Status != "0") {
    if (*Source != "") {
      addAVUMetadata (*Path, "Audit-Source", *Source, "", *Stat);
      if (*Stat == "0" ) {writeLine ("stdout", "  Added source metadata to Audit-Source, *Source, for *Path");}
    }
    if (*Depositor != "") {
      addAVUMetadata (*Path, "Audit-Depositor", *Depositor, "", *Stat);
      if (*Stat == "0" ) {writeLine ("stdout", "  Added depositor metadata to Audit-Depositor, *Depositor, for *Path");}
    }
  }
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

INPUT *Source=$"DFC", *Depositor=$"rwmoore", *File=$"rec1", *Archive=$"Archive-A", *Type=$"SIP"
OUTPUT ruleExecOut
