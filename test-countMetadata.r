countMetadata {
#test-countMetadata.r
# count usage for all metadata in home collection
  *Coll = "/$rodsZoneClient/home/$userNameClient%";
  *Q1 = select count(META_DATA_ATTR_ID),order(META_DATA_ATTR_NAME) where COLL_NAME like '*Coll';
  foreach (*R1 in *Q1) {
    *Num = *R1.META_DATA_ATTR_ID;
    *Name = *R1.META_DATA_ATTR_NAME;
    *C1 = *Name;
    *l = strlen(*Name);
    if (*l < 8) {*C1 = *C1 ++ "\t";}
    if (*l < 16) {*C1 = *C1 ++ "\t";}
    writeLine ("stdout", "*C1  *Num");
  }
}
INPUT null
OUTPUT ruleExecOut
