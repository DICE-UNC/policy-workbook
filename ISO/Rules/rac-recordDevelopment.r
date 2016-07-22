recordDevelopment = main13
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
main13 {
# rac-recordDevelopment
# Policy13
  msiGetSystemTime (*Time, "unix");
  msiAddKeyVal(*KV1, "Repository-Course", "*Course:*Time");
  msiAssociateKeyValuePairsToObj (*KV1, *Name, "-u");
  *Date = timestrf(datetime(double(*Time)), "%Y %m %d");
  writeLine ("stdout", "Set course completion for *Name for course *Course on *Date");
  racWriteManifest ("Archive-SEA", GLOBAL_REPOSITORY, "stdout");
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
INPUT *Name=$"rwmoore", *Course=$"iRODS"
OUTPUT ruleExecOut
