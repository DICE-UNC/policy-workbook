setIPR = main33
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_STORAGE = "LTLResc"
main33 {
# Policy33
# rac-setIPR.r
# set the attribute Audit-IPR with the name of the account
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep";
  addAVUMetadataToColl (*Coll, "Audit-IPR", *Acc, "", *Status);
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "On *Tim set IPR rights for *Acc to *Coll");
  racWriteManifest ("Archive-IPA", *Rep, "stdout");
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
# update manifest file with information from stdout
  msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
  msiDataObjLseek(*L_FD, "0", "SEEK_END", *Status);
  msiDataObjWrite(*L_FD, *Source, *Wlen);
  msiDataObjClose(*L_FD, *Status);
  msiDataObjChksum(*Lfile, "forceChksum=", *Chksum);
  msiDataObjRepl(*Lfile, "updateRepl=++++verifyChksum=", *Stat);
  msiFreeBuffer("stdout");
}
INPUT *Acc=$"rwmoore", *Rep=$"Archive-A"
OUTPUT ruleExecOut
