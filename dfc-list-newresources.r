listNewResources {
# dfc-list-newresources.r
# list all resources created in the last *Interval

# 28 days = 2419200 seconds 
  *IntervalInDays = double(*Interval) / 86400;
  msiGetIcatTime(*CurrentEpoch, "unix");
  *CutoffEpoch = double(*CurrentEpoch) - double(*Interval);
  writeLine("stdout","iRODS resources that have been created in the last *IntervalInDays day(s):");
  *Count = 0;

# get all of the users
  *Q1 = select order(RESC_NAME), RESC_ZONE_NAME, RESC_CREATE_TIME;

# now find the ones created in the last *Interval provided
  foreach (*R1 in *Q1) {
    *Name = *R1.RESC_NAME;
    *Zone = *R1.RESC_ZONE_NAME;
    *CreateTime = *R1.RESC_CREATE_TIME;
    if (double(*CreateTime) >= double(*CutoffEpoch)) {
       *Count = *Count + 1;
       writeLine("stdout","  *Name#*Zone");
    }
  }

  writeLine("stdout","");
  writeLine("stdout","*Count TOTAL iRODS resources created in the last *IntervalInDays day(s)");
}
INPUT *Interval=2419200
OUTPUT ruleExecOut
