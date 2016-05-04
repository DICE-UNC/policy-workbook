listAttrNamesReport {
# dfc-list-attr-names-report
# list of unique AVU attribute names

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

  writeLine("stdout","Unique AVU attribute names:");
  *Count = 0;
  *Q1 = select order(META_DATA_ATTR_NAME);

  foreach (*R1 in *Q1) {
    *Name = *R1.META_DATA_ATTR_NAME;
    *Count = *Count + 1;
    writeLine("stdout","*Count)\t*Name");
  }
  writeLine("stdout","");
  writeLine("stdout","Total unique AVU attribute names: *Count");

   # now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/attr-name-list.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
INPUT *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
