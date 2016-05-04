testRule {
# illustrate query on metadata attributes
  *Coll = "/$rodsZoneClient/home/$userNameClient/Rules";
  *AttName = "Class";
  *Q = select DATA_NAME where COLL_NAME = '*Coll' and META_DATA_ATTR_NAME = '*AttName';
  foreach (*R in *Q) {
    *File = *R.DATA_NAME;
    writeLine ("stdout", "File *File has attribute *AttName");
  }
}
INPUT null
OUTPUT ruleExecOut
