testReplicaNumber {
# check whether a file is replicated
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  *Q1 = select DATA_RESC_HIER, DATA_REPL_NUM where DATA_NAME = *File and COLL_NAME = *Coll;
  foreach (*R1 in *Q1) {
    *N = *R1.DATA_REPL_NUM;
    *S = *R1.DATA_RESC_HIER;
    writeLine ("stdout", "Replica number *N at Storage *S");
  }
}
INPUT *File="foo1"
OUTPUT ruleExecOut
