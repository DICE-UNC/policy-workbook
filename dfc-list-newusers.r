listNewUsers {
# dfc-list-newusers.r
# list all  users created in the last *Interval

# 28 days = 2419200 seconds 
  *IntervalInDays = double(*Interval) / 86400;
  msiGetIcatTime(*CurrentEpoch, "unix");
  *CutoffEpoch = double(*CurrentEpoch) - double(*Interval);
  writeLine("stdout","iRODS users that have been created in the last *IntervalInDays day(s):");
  *Count = 0;

# get all of the users
  *Q1 = select order(USER_NAME), USER_ZONE, USER_CREATE_TIME;

# now find the ones created in the last *Interval provided
  foreach (*R1 in *Q1) {
    *Name = *R1.USER_NAME;
    *Zone = *R1.USER_ZONE;
    *CreateTime = *R1.USER_CREATE_TIME;
    if (double(*CreateTime) >= double(*CutoffEpoch)) {
       *Count = *Count + 1;
       writeLine("stdout","  *Name#*Zone");
    }
  }

  writeLine("stdout","");
  writeLine("stdout","*Count TOTAL iRODS users created in the last *IntervalInDays day(s)");
}
INPUT *Interval=2419200
OUTPUT ruleExecOut
