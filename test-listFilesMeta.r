testlistFilesMeta {
# test-listFilesMeta
# list the files in a collection that have a specified metadata attribute
  *Path = "/$rodsZoneClient/home/$userNameClient/*Relcoll";
  *Q1 = select DATA_NAME where COLL_NAME = '*Path' and META_DATA_ATTR_NAME = '*Meta';
  writeLine ("stdout", "Files in *Path with metadata *Meta");
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    writeLine ("stdout", "*File");
  }
}
INPUT *Relcoll = "test", *Meta = "Class"
OUTPUT ruleExecOut
