testImmutability {
  racGlobalSet ();
# Policy58
# rac-testImmutability.r
# Verify that replacing a replica or migrating a file does not affect persistent identifiers
# track impact on DATA_NAME, DATA_COLL_NAME, DATA_CHECKSUM, DATA_ID, Audit-Handle
# create file, replicate, print out state, delete replica, replace replica, print out state
# migrate file, print out state
  msiGetSystemTime (*Tim, "human");
  *Coll = GLOBAL_ACCOUNT;
  *File = "testRACfile";
  *Path = "*Coll/*File";
  *Flags = "forceFlag=";
  msiDataObjCreate (*Path, *Flags, *L_FD);
  writeLine ("stdout", "Testing immutability of persistent file names on *Tim");
  msiDataObjWrite (*L_FD, "stdout", *Wlen);
  msiDataObjClose (*L_FD, *Status);
  msiDataObjChksum (*Path, "forceChksum=", *Chk);
  addAVUMetadata (*Path, "Audit-Handle", "123456789", "", *St);
  printStat ("initial", *File, *Coll);
# now delete a replica
  *Flags1 = "objPath=*Path++++replNum=1++++forceFlag=";
  msiDataObjUnlink (*Flags1, *Stat);
  if (*Stat != 0) { writeLine ("stdout", "      Attempt to delete a replica failed with *Stat"); }
  printStat ("replica delete", *File, *Coll);
# now replace replica
  msiDataObjRepl (*Path, "updateRepl=++++verifyChksum=", *stat);
  if (*stat != 0) { writeLine ("stdout", "    Attempt to replicate a file failed with *stat"); }
  printStat ("replica create", *File, *Coll);
# now migrate file
  msiDataObjPhymv (*Path, "demoResc", "LTLResc", "", "", *stat);
  if (*stat != 0) { writeLine ("stdout", "    Attempt to migrate a file failed with *stat"); }
  printStat ("file migrated", *File, *Coll);
  msiDataObjUnlink ("objPath=*Path++++forceFlag=", *Stat);
  racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
}
printStat (*Pass, *File, *Coll) {
#  print stats to stdout
  *Path = "*Coll/*File";
  *Q1 = select DATA_ID, DATA_CHECKSUM, DATA_COLL_ID, DATA_REPL_NUM, DATA_RESC_NAME, DATA_PATH where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *Id = *R1.DATA_ID;
    *Cks = *R1.DATA_CHECKSUM;
    *Cn = *R1.DATA_COLL_ID;
    *Rn = *R1.DATA_REPL_NUM;
    *Pt = *R1.DATA_PATH;
    *Drn = *R1.DATA_RESC_NAME;
    writeLine ("stdout", "  For *Pass *Path, DATA_ID = *Id, DATA_COLL_ID = *Cn");
    writeLine ("stdout", "  For *Pass *Path, DATA_CHECKSUM = *Cks");
    writeLine ("stdout", "  For *Pass *Path, DATA_REPL_NUM = *Rn, DATA_RESC_NAME = *Drn");
    writeLine ("stdout", "  For *Pass *Path, DATA_PATH = *Pt");
  }
  *Q2 = select META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = "Audit-Handle";
  foreach (*R2 in *Q2) {
    *H = *R2.META_DATA_ATTR_VALUE;
    writeLine ("stdout", "  For *Pass *Path, Audit-Handle = *H");
  }
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
