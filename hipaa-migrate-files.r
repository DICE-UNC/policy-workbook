migrateFiles {
# hipaa-migrate-files.r
# Migrate files that have the attribute VIRUS_SCAN_PASSED
  *Q1 = select DATA_NAME, COLL_NAME where META_DATA_ATTR_NAME = "VIRUS_SCAN_PASSED";
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Coll = *Q1.COLL_NAME;
    *Path = *Coll/*File;
    *Q2 = select META_DATA_ATTR_VALUE where DATA_NAME = "*File" and COLL_NAME = "*Coll" and META_DATA_ATTR_NAME = "VIRUS_SCAN_PASSED";
    foreach (*R2 in *Q2) {
      *Val = *R2.META_DATA_ATTR_VALUE;
 #  Remove the metadata attribute
     *Str1 = "VIRUS_SCAN_PASSED=*Val";
     msiString2KeyValPair(*Str1, *kvp1);
     msiRemoveKeyValuePairsFromObj(*kvp1, *Path, "-d");
# Insert a revised attribute
      *Str2 = "VIRUS_SCAN_PASS=*Val";
      msiString2KeyValPair(*Str2, *kvp2);
       msiAssociateKeyValuePairsToObj(*kvp2, *Path, "-d");
# Move the file to the archive
    }
    *Dest = "/UNC-HIPAA/home/HIPAA/Archive/" ++ *File;
    msiDataObjRename(*Path,*Dest,"0", *Status);
  }
}
INPUT null
OUTPUT ruleExecOut

