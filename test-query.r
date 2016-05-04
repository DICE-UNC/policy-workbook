testQuery {
# Rule to retrieve files that have "rule" in the name
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    if (*File like '\*.r') {
      writeLine("stdout", "*File is a rule");
    }
  }
}
INPUT null
OUTPUT ruleExecOut
