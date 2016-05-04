metadataCheck {
# testlistmetadata.r
# create a list of all metadata used in a collection
  *Coll = "/$rodsZoneClient/home/$userNameClient%";
  *Metanum.total = str(0);
  *Q = select order(META_DATA_ATTR_NAME), count(META_DATA_ATTR_ID) where COLL_NAME like '*Coll';
  foreach (*R in *Q) {
    *Metaname = *R.META_DATA_ATTR_NAME;
    *Num = *R.META_DATA_ATTR_ID;
    *Metanum.total = str(int(*Metanum.total) + int(*Num));
    *Metanum.*Metaname = *Num;
  }
  foreach (*Metaname in *Metanum) {
    if (*Metaname != "total") {
      *C1 = *Metanum.*Metaname;
      *C2 = *Metaname;
      if (strlen(*C2) < 8) {*C2 = *C2 ++ "\t";}
      if (strlen(*C2) < 16) {*C2 = *C2 ++ "\t";}
      if (strlen(*C2) < 24) {*C2 = *C2 ++ "\t";}
      writeLine ("stdout", "*C2    *C1");
    }
  }
  *C1 = *Metanum.total;
  *C2 = "total\t\t\t";
  writeLine ("stdout", "*C2    *C1");
}
INPUT null 
OUTPUT ruleExecOut
