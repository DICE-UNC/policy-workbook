listFederationsReport {
# dfc-list-feds-report
# list all federations with this zone

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

  writeLine("stdout","Federated zones report");
  writeLine("stdout","");
  writeLine("stdout","Name                        Connection");
  writeLine("stdout","--------------------------------------");
  *Count = 0;
  *Q1 = select ZONE_NAME, ZONE_CONNECTION where ZONE_TYPE = 'remote';

  foreach (*R1 in *Q1) {
    *Name = *R1.ZONE_NAME;
    *Conn = *R1.ZONE_CONNECTION;
    *Count = *Count + 1;
    if (strlen(*Name) < 8) {*Name = *Name ++ "\t";}
    if (strlen(*Name) < 16) {*Name = *Name ++ "\t";}
    if (strlen(*Name) < 24) {*Name = *Name ++ "\t";}
    writeLine("stdout","*Name    *Conn");
  }

  writeLine("stdout","");
  writeLine("stdout","Total federated zones: *Count");

   # now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/federation-list.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
INPUT *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
