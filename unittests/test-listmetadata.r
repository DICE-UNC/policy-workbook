listMetadata {
# retrieve metadata for a file
  *Q1 = select META_DATA_ATTR_NAME, META_DATA_ATTR_VALUE where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *Nam = *R1.META_DATA_ATTR_NAME;
    *Val = *R1.META_DATA_ATTR_VALUE;
    writeLine ("stdout", "*Nam    *Val");
  }
}
INPUT *File="test", *Coll="/lifelibZone/home/rwmoore/Class-INLS624/rules"
OUTPUT ruleExecOut
