sizeByRescReport {
# dfc-size-byresc-report.r
# Calculate usage by storage resource

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

  *Total = 0.;
  *Name = $userNameClient;
  writeLine ("stdout", "Resource                Data-stored (Gbytes)");
  writeLine ("stdout", "--------------------------------------------");

  *Q1 = select RESC_NAME, RESC_PARENT;
  foreach (*R1 in *Q1) {
   *Resc = *R1.RESC_NAME;
   *Parent = *R1.RESC_PARENT;

    # only query the top-level resouces, since they are the only ones that return size data
    if (strlen(*Parent) <= 0) {
      *Q2 = select sum(DATA_SIZE) where DATA_RESC_NAME = '*Resc';

      foreach(*R2 in *Q2) {
        *Usage = double(*R2.DATA_SIZE)/1024./1024./1024.;
        writeParam(*Resc, str(*Usage));
        *Total = *Total + *Usage;
      }

    }
  }
  writeLine("stdout", "");
  writeParam("Total", str(*Total));

# now save it all to reportdata object
  msiDataObjCreate("*ReportPath" ++ "/size-byresc.txt","forceFlag=",*FD);
  msiDataObjWrite(*FD,"stdout",*WLEN);
  msiDataObjClose(*FD,*Status);
  msiFreeBuffer("stdout");
}

writeParam(*R0, *R1) {
# convert input strings into 16 character fields
  *C0 = *R0;
  if (strlen(*C0) < 8) {*C0 = "*C0\t";}
  if (strlen(*C0) < 16) {*C0 = "*C0\t";}
  *C0 = "*C0\t";
  *C1 = *R1;
  if (strlen(*C1) < 8) {*C1 = "*C1\t";}
  if (strlen(*C1) < 16) {*C1 = "*C1\t";}
  writeLine("stdout", "*C0*C1");
}
INPUT *BaseColl="/dfcmain/home/dfcAdmin/AdminReports"
OUTPUT ruleExecOut
