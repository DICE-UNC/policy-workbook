listAdmin {
# dmp-list-admin.r
# list all persons with rodsadmin status
  *Count = 0;
  *Q1 = select USER_NAME where USER_TYPE = 'rodsadmin';
  foreach (*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Count = *Count + 1;
    writeLine("stdout","Person with admin privilege *Name");
  }
  writeLine("stdout","*Count persons have admin privilege");
}
INPUT null
OUTPUT ruleExecOut
