metadataCheck {
# testlistmetadata.r
# create a list of all metadata used in a collection
  *Coll = "/$rodsZoneClient/home/%";
  *Metanum.total = str(0);
  *Q = select count(META_DATA_ATTR_NAME) where COLL_NAME like '*Coll';
  foreach (*R in *Q) {
    *Metaname = *R.META_DATA_ATTR_NAME;
  }
  writeLine("stdout" , "Total number of metadata attributes is *Metaname");
  *Q1 = select count(DATA_NAME) where COLL_NAME like '*Coll';
  foreach (*R1 in *Q1) {
    *Num = *R1.DATA_NAME;
  }
  writeLine ("stdout", "Number of files is *Num");
}
INPUT null 
OUTPUT ruleExecOut
