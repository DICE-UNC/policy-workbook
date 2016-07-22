setAccess = main31
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_MANIFESTS = "Manifests"
GLOBAL_STORAGE = "LTLResc"
main31 {
# rac-setAccess.r
# Policy31
# set access control on collection, turn on inheritance
  msiGetSystemTime (*Tim, "human");
  writeLine ("stdout", "On *Tim, change access controls");
  *Coll = GLOBAL_ACCOUNT ++ "/*Rep";
  msiSetACL ("recursive", "inherit", "", *Coll);
  msiSetACL ("default", *Perm, *Acc, *Coll);
  writeLine ("stdout", "  Set *Perm  access recursively for account *Acc for collection *Coll");
  racWriteManifest (*Rep, "Archive-TA", "stdout");
}
racWriteManifest( *Rep, *OutFile, *Source ) {
# create manifest file holding the date of each periodic notification
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
INPUT *Acc=$"rwmoore", *Perm=$"own", *Rep=$"Archive-A"
OUTPUT ruleExecOut
