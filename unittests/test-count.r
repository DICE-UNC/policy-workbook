testCount {
# test whether a select count returns an integer
  *Q = select count (COLL_ID) where COLL_NAME = '/lifelibZone/home/test';
  foreach (*R in *Q) { *Num = *R.COLL_ID; }
# if (*Num == 0) {writeLine("stdout", "integer return *Num"); }
  if (*Num == "0") {writeLine ("stdout", "string return *Num"); }
}
INPUT null
OUTPUT ruleExecOut
