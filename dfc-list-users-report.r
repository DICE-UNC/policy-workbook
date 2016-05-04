listUsersReport {
# dfc-list-users-report.r

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

# list all other irods users
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

#print total number of users
  writeLine("stdout","*Total TOTAL iRODS users");

# now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/user-report.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
INPUT *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
