testImmutability {
#  racGlobalSet ();
# Policy58
# rac-testImmutability.r
# Verify that replacing a replica or migrating a file does not affect persistent identifiers
# track impact on DATA_NAME, DATA_COLL_NAME, DATA_CHECKSUM, DATA_ID, Audit-Handle
# create file, replicate, print out state, delete replica, replace replica, print out state
# migrate file, print out state
#  msiGetSystemTime (*Tim, "human");
#  *Coll = GLOBAL_ACCOUNT;
  *File = "testRACfile";
#  *Path = "*Coll/*File";
  *Flags = "forceFlag=";
#  msiDataObjCreate (*Path, *Flags, *L_FD);
#  writeLine ("stdout", "Testing immutability of persistent file names on *Tim");
#  msiDataObjWrite (*L_FD, "stdout", *Wlen);
#  msiDataObjClose (*L_FD, *Status);
#  msiDataObjRepl (*Path, "updateRepl=++++verifyChksum=", *Stat);
#  addAVUMetadata (*Path, "Audit-Handle", "123456789", "", *St);
#  printStat ("initial", *File, *Coll);
# now delete a replica
#  *Flags1 = "objPath=*Path++++replNum=1++++forceflag=";
#  msiDataObjUnlink (*Flags1, *Stat);
#  if (*Stat != 0) { writeLine ("stdout", "      Attempt to delete a replica failed"); }
#  printStat ("replica delete", *File, *Coll);
# now replace replica
#  msiDataObjRepl (*Path, "updateRepl=++++verifyChksum=", *Stat);
#  printStat ("replica create", *File, *Coll);
# now migrate file
#  msiDataObjPhymv (*Path, "demoResc", "", "", "null", *stat);
#  if (*stat != 0) { writeLine ("stdout", "    Attempt to migrate a file failed"); }
#  printStat ("file migrated", *File, *Coll);
#  racWriteManifest ("Archive-RAA", GLOBAL_REPOSITORY, "stdout");
}
printStat (*Pass, *File, *Coll) {
#  print stats to stdout
  *Path = "*Coll/*File";
  *Q1 = select DATA_ID, DATA_CHECKSUM, DATA_COLL_NAME where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *Id = *R1.DATA_ID;
    *Cks = *R1.DATA_CHECKSUM;
    *Cn = *R1.DTA_COLL_NAME;
    writeLine ("stdout", "  For *Pass *Path, DATA_ID = *Id, DATA_CHECKSUM = *Cks, DATA_COLL_NAME = *Cn");
  }
  *Q2 = select META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = "Audit-Handle";
  foreach (*R2 in *Q2) {
    *H = *R2.META_DATA_ATTR_VALUE;
    writeLine ("stdout", "  For *Path *Path, Audit-Handle = *H");
  }
}
INPUT null
OUTPUT ruleExecOut
