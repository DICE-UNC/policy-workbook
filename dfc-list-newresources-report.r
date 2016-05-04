listNewResourcesReport {
# dfc-list-newresources-report.r
# list all resources created in the last *Interval

# create report collection that we are going to write to
  *ShortDate = "";
  msiGetIcatTime(*DateStamp, "human");
  if (strlen("*DateStamp") > 10) {
        *ShortDate = substr("*DateStamp", 0, 10);
  }
  *ReportPath = *BaseColl ++ "/" ++ "*ShortDate" ++ "_reports";
  msiCollCreate(*ReportPath,"1",*Status);
  msiStrlen(*ReportPath,*ROOTLENGTH);
  *OFFSET = int(*ROOTLENGTH) + 1;

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

  # now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/newresource-report.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
INPUT *Interval=2419200, *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
