testDataName {
# check whether a query on DATA_NAME finds all replicas
# check whether a query on DATA_ID finds all replicas
  *Col = "/$rodsZoneClient/home/$userNameClient/*Relcol";
  *Q1 = select DATA_NAME where COLL_NAME = '*Col';
  writeLine("stdout", "select DATA_NAME");
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    writeLine ("stdout", "Found *File");
  }
  *Q2 = select DATA_ID where COLL_NAME = '*Col';
  writeLine ("stdout", "select DATA_ID");
  foreach (*R2 in *Q2) {
    *Id = *R2.DATA_ID;
    writeLine ("stdout", "Found *Id");
  }
  *Q3 = select DATA_ID, DATA_NAME where COLL_NAME = '*Col';
  writeLine ("stdout", "select DATA_ID, DATA_NAME");
  foreach (*R3 in *Q3) {
    *Id = *R3.DATA_ID;
    *File = *R3.DATA_NAME;
    writeLine ("stdout", "Found *File, *Id");
  }
  *Q4 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = '*Col' and DATA_REPL_NUM = '0';
  writeLine ("stdout", "select DATA_NAME, DATA_CREATE_TIME");
  foreach (*R4 in *Q4) {
    *File = *R4.DATA_NAME;
    *Tim = *R4.DATA_CREATE_TIME;
    writeLine ("stdout", "Found *File, *Tim");
  }
}
INPUT *Relcol = "test"
OUTPUT ruleExecOut
