testCollInput {
  testcheckCollInput (*Coll);
}
testcheckCollInput (*Coll) {
  *Q = select count(COLL_ID) where COLL_NAME = '*Coll';
  foreach (*R in *Q) {*Result = *R.COLL_ID;}
  if(*Result == "0" ) {
    writeLine("stdout", "Input path *Coll is not a collection");
    fail;
  }
  else {
    writeLine("stdout", "Input path *Coll is a collection");
  }
}
INPUT *Coll="/$rodsZoneClient/home/$userNameClient/test"
OUTPUT ruleExecOut
