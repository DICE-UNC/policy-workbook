verifyIntegrity = main29
GLOBAL_ACCOUNT = "/lifelibZone/home/rwmoore"
GLOBAL_ARCHIVES = "Archives"
GLOBAL_REPORTS = "Reports"
GLOBAL_REPOSITORY = "Repository"
GLOBAL_STORAGE = "LTLResc"
GLOBAL_MANIFESTS = "Manifests"
main29 {
# Policy26
# rac-verifyIntegrity.r
# record files with a bad checksum and replace the bad files
# check to make sure the collection exists before moving on
  *Coll = GLOBAL_ACCOUNT ++ "/" ++ GLOBAL_REPOSITORY;
  writeLine("stdout", "Verify checksums for files in Archives");
  checkCollInput(*Coll);
  *Res = GLOBAL_STORAGE;
  checkRescInput (*Res, $rodsZoneClient);
  *Day = "*Days" ++ "d";
  delaycheck ("Archive-RCA", *Res, *Coll, *Day, *NumReplicas);
}
delaycheck (*OutFile, *Res, *Colh, *Day, *NumReplicas) {
  delay ("<PLUSET>1s</PLUSET><EF>*Day</EF>") {
    msiGetSystemTime (*Tim, "human");
    *Q1 = select META_COLL_ATTR_VALUE where COLL_NAME = *Colh and META_COLL_ATTR_NAME = 'Repository-Archives';
    foreach (*R1 in *Q1) {
      *C = *R1.META_COLL_ATTR_VALUE;
      *Coll = GLOBAL_ACCOUNT ++ "/*C/" ++ GLOBAL_ARCHIVES;
      writeLine ("stdout", "On date *Tim, verify checksums in collection *Coll");
#============== loop over all the files in the collection ===============
      *q2 = select DATA_NAME, COLL_NAME, DATA_CHECKSUM, DATA_REPL_NUM where COLL_NAME like '*Coll%';
      foreach(*r2 in *q2) {
        *Name = *r2.DATA_NAME;
        *Colln = *r2.COLL_NAME;
        *Path = "*Colln/*Name";
        *Chk = *r2.DATA_CHECKSUM;
        *Replnum = *r2.DATA_REPL_NUM;
        msiDataObjChksum("*Path", "forceChksum=++++replNum=*Replnum", *Chkf);
        if(*Chk == "0") {
          *Chk = *Chkf;
          writeLine ("stdout", "    File *Path for replica *Replnum was missing a checksum, created new value");
        }
        if (*Chk != *Chkf) {
          writeLine ("stdout", "    Deleted *Path for replica *Replnum which has a bad checksum");
          msiDataObjUnlink("objPath=*Path++++replNum=*Replnum", *Status);
        }
      }
      if (errorcode(msiRunRebalance(*Resource)) < 0) {
        writeLine("stdout", "ERROR: Rebalance for *Resource replication resource Failed");
      }
      else {
        writeLine("stdout", "Rebalance for *Resource replication resource complete");
      }
      racWriteManifest (*OutFile, GLOBAL_REPOSITORY, "stdout");
    }
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
INPUT *Days=$365, *NumReplicas=$2
OUTPUT ruleExecOut
