testTemplate {
# check file exists
  *Coll = "/lifelibZone/home/rwmoore/Archive-A";
  *Q3 = select META_COLL_ATTR_VALUE where COLL_NAME = *Coll and META_COLL_ATTR_NAME = "Archive-AIPTemplate";
  foreach (*R3 in *Q3) {
    *File = *R3.META_COLL_ATTR_VALUE;
    *Ca = "*Coll/Reports";
    writeLine ("stdout", "*Ca, *File");
    *Q4 = select count(DATA_ID) where COLL_NAME = *Ca and DATA_NAME = *File;
    foreach (*R4 in *Q4) {
      *N = *R4.DATA_ID;
      writeLine ("stdout", "*N");
      if (*N == "0") {
        *Msg = "Missing *File in *Ca";
        writeLine ("stdout", "*Msg");
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
