listAVUsReport {
# dfc-list-avus-report.r
# create a list of all metadata names used in a collection

  *ShortDate = "";
  msiGetIcatTime(*DateStamp, "human");
  if (strlen("*DateStamp") > 10) {
        *ShortDate = substr("*DateStamp", 0, 10);
  }
  *ReportPath = *BaseColl ++ "/" ++ "*ShortDate" ++ "_reports";
  msiCollCreate(*ReportPath,"1",*Status);
  msiStrlen(*ReportPath,*ROOTLENGTH);
  *OFFSET = int(*ROOTLENGTH) + 1;
  *Q1 = select order(USER_NAME);

  foreach (*R1 in *Q1) {
    *UserName = *R1.USER_NAME;
    *Coll = "/$rodsZoneClient/home/*UserName";
    writeLine ("stdout", "Metadata names for *Coll collection:");
    *Metanum.total = str(0);
    *Q2 = select order(META_DATA_ATTR_NAME), count(META_DATA_ATTR_ID) where COLL_NAME like '*Coll';
    foreach (*R2 in *Q2) {
      *Metaname = *R2.META_DATA_ATTR_NAME;
      *Num = *R2.META_DATA_ATTR_ID;
      *Metanum.total = str(int(*Metanum.total) + int(*Num));
      *Metanum.*Metaname = *Num;
    }
    foreach (*Metaname in *Metanum) {
      if (*Metaname != "total") {
        *C1 = *Metanum.*Metaname;
        *C2 = *Metaname;
        if (strlen(*C2) < 8) {*C2 = *C2 ++ "\t";}
        if (strlen(*C2) < 16) {*C2 = *C2 ++ "\t";}
        if (strlen(*C2) < 24) {*C2 = *C2 ++ "\t";}
        writeLine ("stdout", "*C2    *C1");
      }
    }
    *C1 = *Metanum.total;
    *C2 = "total\t\t\t";
    writeLine ("stdout", "*C2    *C1");
    writeLine ("stdout", "");
  }

  # now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/newresource-report.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
INPUT *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
