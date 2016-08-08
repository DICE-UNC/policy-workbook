verifyIntegrityArchive {
  racGlobalSet ();
# Policy64
# rac-verifyIntegrityArchive.r
# record files with a bad checksum and replace the bad files
# check to make sure the collection exists before moving on
  msiGetSystemTime (*Tim, "human");
  *Coll = GLOBAL_ACCOUNT ++ "/*Archive";
  writeLine("stdout", "Verify checksums for files in *Coll on *Tim");
  *Res = GLOBAL_STORAGE;
#============== loop over all the files in the collection ===============
  *q2 = select DATA_NAME, COLL_NAME, DATA_CHECKSUM, DATA_REPL_NUM where COLL_NAME like '*Coll%';
  foreach(*r2 in *q2) {
    *Name = *r2.DATA_NAME;
    *Colln = *r2.COLL_NAME;
    *Path = "*Colln/*Name";
    *Chk = *r2.DATA_CHECKSUM;
    *Replnum = *r2.DATA_REPL_NUM;
    msiDataObjChksum("*Path", "forceChksum=++++replNum=*Replnum", *Chkf);
    if(*Chk == "") {
      *Chk = *Chkf;
      writeLine ("stdout", "    File *Path for replica *Replnum was missing a checksum, created new value");
    }
    if (*Chk != *Chkf && *Chk != "") {
      writeLine ("stdout", "    Deleted *Path for replica *Replnum which has a bad checksum");
      msiDataObjUnlink("objPath=*Path++++replNum=*Replnum", *Status);
    }
  }
  if (errorcode(msiRunRebalance(*Res)) < 0) {
    writeLine("stdout", "ERROR: Rebalance for *Res replication resource Failed");
  }
  else {
    writeLine("stdout", "Rebalance for *Res replication resource complete");
  }
  racWriteManifest ("Archive-INTA", *Archive, "stdout");
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
