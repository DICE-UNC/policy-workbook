metadataCheck {
# dmp-metadata-check-coll.r
# compare the metadata on each file with the metadata on the collection
# retrieve the metadata on the collection
  checkCollInput (*Coll);
  *Q = select META_COLL_ATTR_NAME where COLL_NAME = '*Coll';
  foreach (*R in *Q) {
    *MetaN = *R.META_COLL_ATTR_NAME;
# check that each file also has this metadata attribute
    *Q1 = select DATA_ID, DATA_NAME where COLL_NAME = '*Coll';
    foreach (*R1 in *Q1) {
      *DataId =  *R1.DATA_ID;
      *Q3 = select count(META_DATA_ATTR_ID) where DATA_ID = '*DataId' and META_DATA_ATTR_NAME = '*MetaN';
      foreach (*R3 in *Q3) {*Num = *R3.META_DATA_ATTR_ID;}
      if (*Num == "0") {
        *Name = *R1.DATA_NAME;
        writeLine ("stdout", "*Name missing *MetaN");
      }
    }
  }
}
INPUT *Coll = "/dfcmain/home/rwmoore/Reports"
OUTPUT ruleExecOut
