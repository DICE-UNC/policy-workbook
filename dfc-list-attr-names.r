listAttrNames {
# dfc-list-attr-names
# list of unique AVU attribute names

  writeLine("stdout","Unique AVU attribute names:");
  *Count = 0;
  *Q1 = select order(META_DATA_ATTR_NAME);

  foreach (*R1 in *Q1) {
    *Name = *R1.META_DATA_ATTR_NAME;
    *Count = *Count + 1;
    writeLine("stdout","*Count)\t*Name");
  }
  writeLine("stdout","");
  writeLine("stdout","Total unique AVU attribute names: *Count");
}
INPUT null
OUTPUT ruleExecOut
