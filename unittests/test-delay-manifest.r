myruleEx54 {
  *Coll = "/$rodsZoneClient/home/$userNameClient/*Sub";
  checkCollInput (*Coll);
  *LPath = "*Coll/*Name";
  isData(*Coll, *Name, *Status);
  if (*Status == "0") {
# create file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*LPath, *Dfile, *L_FD);
  }
  executeDelay (*LPath):
}
executeDelay (*LPath) {
  delay("<PLUSET>1s</PLUSET><EF>7d</EF>") {
# open report file
    msiDataObjOpen(*LPath, *Fdesc);
# microservice to find the end of the manifest file
    msiDataObjLseek(*Fdesc, "0", "SEEK_END", *Stat);
#  Inside the braces for the delay micro-service statement to write info to manifest file.
#  the creation time on a file is within a week of the current time
    msiGetSystemTime(*Timen, "unix");
    *Time = double(*Timen);
    *Period = 7. * 24. * 3600.;
    *Q1 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = '*Coll' and DATA_REPL_NUM = '0';
    foreach (*R1 in *Q1) {
      *File = *R1.DATA_NAME;
      *Timec = double(*R1.DATA_CREATE_TIME);
      if (*Time-*Timec <= *Period) {
        writeLine("*LPath","added file *File");
      }
    }
    msiDataObjClose(*Fdesc, *Status);
  }
}  
INPUT *Sub="Reports", *Name="Manifest", *Res="LTLResc"
OUTPUT ruleExecOut
