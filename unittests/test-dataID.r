testID {
# check whether a replica has the same DATA_ID as the original
  *Q1 = select DATA_ID, DATA_REPL_NUM where DATA_NAME = 'foo1.txt' and COLL_NAME = '/$rodsZoneClient/home/$userNameClient'
  foreach (*R1 in *Q1) {
    *N = *R1.DATA_REPL_NUM;
    *I = *R1.DATA_ID;
    writeLine("stdout", "Replica number *N, Data ID *I");
  }
}
INPUT null
OUTPUT ruleExecOut
