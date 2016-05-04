checkQuery {
# test if get null result on file not found
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  *File = "Manifest";
  *Q1 = select count(DATA_ID) where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  foreach (*R1 in *Q1) {
    *Num = *R1.DATA_ID;
  }
  writeLine("stdout", "Number is *Num");
}
INPUT null
OUTPUT ruleExecOut
