metadataCheck {
# testlistmetadata.r
# create a list of all metadata used in a collection for each type of data
  *List = list(".gz", ".nc", ".dcx", ".ore");
  *Coll = "/$rodsZoneClient/home/$userNameClient%";
  foreach (*L in *List) {
    writeLine ("stdout", "Metadata usage for file type *L");
    *Nam.total = str(0);
    *Q = select order(META_DATA_ATTR_NAME), count(META_DATA_ATTR_ID) where COLL_NAME like '*Coll' and DATA_NAME like '%*L';
    foreach (*R in *Q) {
      *Metaname = *R.META_DATA_ATTR_NAME;
      *Num = *R.META_DATA_ATTR_ID;
      *Nam.total = str(int(*Nam.total) + int(*Num));
      *Nam.*Metaname = *Num;
    }
    foreach (*Metaname in *Nam) {
      if (*Metaname != "total") {
        *C1 = *Nam.*Metaname;
        *C2 = *Metaname;
        if (strlen(*C2) < 8) {*C2 = *C2 ++ "\t";}
        if (strlen(*C2) < 16) {*C2 = *C2 ++ "\t";}
        if (strlen(*C2) < 24) {*C2 = *C2 ++ "\t";}
        writeLine ("stdout", "*C2    *C1");
      }
    }
    *C1 = *Nam.total;
    *C2 = "total\t\t\t";
    writeLine ("stdout", "*C2    *C1");
    foreach (*Metaname in *Nam ) {
      *Nam.*Metaname = str(0);
    }
  }
}
INPUT null 
OUTPUT ruleExecOut
