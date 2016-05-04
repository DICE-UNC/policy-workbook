CollectionSize {
# dfc-dataobject-size-report.r
# For each accessible collection list the number of files and total size

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

# Collect all user home collections and go through each one to get data totals
  *Totsize = 0.0;
  *Q0 = select count(DATA_ID), sum(DATA_SIZE), COLL_NAME where COLL_NAME like '*Coll%';

  foreach (*R0 in *Q0) {
    *Colln = *R0.COLL_NAME;
    *Num = *R0.DATA_ID;
    *Size = *R0.DATA_SIZE;
    *Totsize = *Totsize + double (*Size);
    writeLine("stdout", "Collection *Colln has *Num files with size *Size bytes");
  }

  writeLine("stdout", "Total collection size is *Totsize bytes");

  # now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/dataobject-size-report.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}
#INPUT *Coll = "/$rodsZoneClient/home/", *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
INPUT *Coll = "/", *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
