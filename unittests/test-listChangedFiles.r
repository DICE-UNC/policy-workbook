testDelay {
  if (*Coll == "/$rodsZoneClient/home/$userNameClient/Class-INLS624"){
    msiGetSystemTime(*Timen, "unix");
    *Time = double(*Timen);
    *Period = 7. * 24. * 3600.;
    *Q1 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = "*Coll" and DATA_REPL_NUM = "0";
    foreach (*R1 in *Q1) {
      *File = *R1.DATA_NAME;
      *Create = double (*R1.DATA_CREATE_TIME);
      if (*Time - *Create <= *Period) {
        writeLine("stdout","Added file *File");
      }
    }
  }
}
INPUT *Coll="/$rodsZoneClient/home/$userNameClient/Class-INLS624"
OUTPUT ruleExecOut
