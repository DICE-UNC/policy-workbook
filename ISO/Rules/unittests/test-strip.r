testStripAVU {
# create a file, add metadata, then remove
  *File = "rec3";
  *Coll = "/$rodsZoneClient/home/$userNameClient/Archive-A/Archives";
  *Path = "*Coll/*File";
  *Res = "res-dfcmain";
  *Flags = "destRescName=*Res++++forceFlag=";
# add metadata
  *Attname = "testName";
  *Attvalue = "testVal";
#  msiAddKeyVal (*Kvp, *Attname, *Attvalue);
#  msiAssociateKeyValuePairsToObj (*Kvp, *Path, "-d");
  *Q1 = select count(META_DATA_ATTR_ID) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = *Attname;
  foreach (*R1 in *Q1) { *Num = *R1.META_DATA_ATTR_ID; }
  writeLine ("stdout", "Found *Num attributes");
  msiStripAVUs (*Path, "data", *Stat);
  writeLine ("stdout", "removed attributes");
  *Q2 = select count(META_DATA_ATTR_ID) where DATA_NAME = *File and COLL_NAME = *Coll and META_DATA_ATTR_NAME = *Attname;
  foreach (*R2 in *Q2) { *Num = *R2.META_DATA_ATTR_ID; }
  writeLine ("stdout", "Found *Num attributes");
}
INPUT null
OUTPUT ruleExecOut
