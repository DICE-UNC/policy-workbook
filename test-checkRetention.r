checkRetention {
# test-checkRetention.r
# Identify files whose retention period has expired
  checkCollInput (*Coll);
  msiGetIcatTime(*Time,"unix");
  *Q1 = select DATA_NAME, COLL_NAME, DATA_EXPIRY where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *D = *R1.DATA_NAME;
    *C = *R1.COLL_NAME;
    *E = *R1.DATA_EXPIRY;
    if (int(*Time) > int(*E) && *E != "") {
      writeLine("stdout","*C/*D retention period has expired");
    }
  } 
}
INPUT *Coll =$"/$rodsZoneClient/home/$userNameClient"
OUTPUT ruleExecOut
