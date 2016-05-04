mytestrule{
#  rule to test datetimef function to convert a string/integer/double
#  to a variable of type dateime.
  msiGetSystemTime(*Time,"unix");
  *out = timestrf(datetime(double(*Time)), "%y %m %d");
  writeLine("stdout", "datetime of *Time is *out");
  *T = time();
  writeLine("stdout", "time command gives *T");
  msiGetSystemTime (*T2, "human");
  writeLine("stdout", "human gives *T2");
 *Q = select DATA_MODIFY_TIME where DATA_NAME = 'foo1.txt' and COLL_NAME = '/$rodsZoneClient/home/$userNameClient';
  foreach (*R in *Q) {
    *T3 =*R.DATA_MODIFY_TIME;
  }
  writeLine ("stdout", "data modify *T3");
 *Q = select DATA_CREATE_TIME where DATA_NAME = 'foo1' and COLL_NAME = '/$rodsZoneClient/home/$userNameClient';
  foreach (*R in *Q) {
    *T3 =*R.DATA_CREATE_TIME;
  }
  writeLine ("stdout", "data create *T3");
  *Q2 = select DATA_EXPIRY where DATA_NAME = 'foo1' and COLL_NAME = '/$rodsZoneClient/home/$userNameClient';
  foreach (*R2 in *Q2) { *T4 = *R2.DATA_EXPIRY;}
  writeLine ("stdout", "Data expiry *T4");
}
INPUT null
OUTPUT ruleExecOut

