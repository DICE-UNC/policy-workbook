listUsers {
# dfc-list-users.r
# list all persons with rodsadmin status
  writeLine("stdout","iRODS users that have admin privilege:");
  *Count1 = 0;
  *Q1 = select order(USER_NAME), USER_ZONE where USER_TYPE = 'rodsadmin';

  foreach (*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Zone = *R1.USER_ZONE;
    *Count1 = *Count1 + 1;
    writeLine("stdout","  *Name#*Zone");
  }
  writeLine("stdout","*Count1 admin iRODS users");
  writeLine("stdout","");

  writeLine("stdout","Other iRODS users:");
  *Count2 = 0;
  *Q1 = select order(USER_NAME), USER_ZONE where USER_TYPE = 'rodsuser';
  foreach (*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Zone = *R1.USER_ZONE;
    *Count2 = *Count2 + 1;
    writeLine("stdout","  *Name#*Zone");
  }
  *Total = *Count1 + *Count2;
  writeLine("stdout","*Count2 other iRODS users");
  writeLine("stdout","*Total TOTAL iRODS users");
}
INPUT null
OUTPUT ruleExecOut
