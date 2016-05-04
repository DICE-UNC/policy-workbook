listHandleTotalReport {
# dfc-list-handletotal-report.r
# list how many data objects have handle approval

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

  writeLine("stdout", "Handle Report for $rodsZoneClient");
  writeLine("stdout", "");
  writeLine("stdout", "HandleApproval              Total");
  writeLine("stdout", "---------------------------------");

  *Nam.total = str(0);
  *Q = select META_DATA_ATTR_VALUE where META_DATA_ATTR_NAME like '*AVU_NAME';

  foreach (*R in *Q) {
    *Metavalue = *R.META_DATA_ATTR_VALUE;

    *Q2 = select count(DATA_ID) where META_DATA_ATTR_VALUE like *Metavalue and META_DATA_ATTR_NAME like *AVU_NAME;
    foreach (*R2 in *Q2) {
      *Num = *R2.DATA_ID;
      *Nam.*Metavalue = *Num;
      *Nam.total = str(int(*Nam.total) + int(*Num));
      break;
    }
    *PreviousVal = *Metavalue;
  }
  foreach (*Metavalue in *Nam) {
    if (*Metavalue != "total") {
      *C1 = *Nam.*Metavalue;
      *C2 = *Metavalue;
      if (strlen(*C2) < 8) {*C2 = *C2 ++ "\t";}
      if (strlen(*C2) < 16) {*C2 = *C2 ++ "\t";}
      if (strlen(*C2) < 24) {*C2 = *C2 ++ "\t";}
      writeLine ("stdout", "*C2    *C1");
    }
  }
  *C1 = *Nam.total;
  *C2 = "Total data objects that have Handles:\t\t";
  writeLine("stdout", "");
  writeLine ("stdout", "*C2    *C1");
  foreach (*Metaname in *Nam ) {
    *Nam.*Metaname = str(0);
  }

  # now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/handle-list.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
INPUT *AVU_NAME="HandleApproval", *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
