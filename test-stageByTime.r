stageByTime {
# test-stageByTime.r
# copy files from a staging area into a new subdirectory each year
# sort files into yearly subdirectories
  checkCollInput (*Srccoll);
  checkCollInput (*Destcoll);
  stagefiles (*Srccoll, *Destcoll );
}
stagefiles (*Srccoll, *Destcoll) {
  delay ("<PLUSET>1m</PLUSET><EF>1y</EF>") {
    msiGetSystemTime(*Time,"unix");
    *Date = timestrf(datetime(double(*Time)), "%y");
    *Destc = *Destcoll ++ "/*Date";
    isColl(*Destc, "stdout", *Status);
    if (*Status >= 0) {
      *Q1 = select DATA_NAME where COLL_NAME = '*Srccoll';
      foreach (*R1 in *Q1) {
        *File = *R1.DATA_NAME;
        *Src = *Srccoll ++ "/*File";
        *Dest = *Destc ++ "/*File";
        writeLine("stdout","*Src *Dest");
        msiDataObjRename(*Src, *Dest, "0", *Status);
      }
    }
  }
}
INPUT *Srccoll = "/$rodsZoneClient/home/$userNameClient/test", *Destcoll = "/$rodsZoneClient/home/$userNameClient/archive"
OUTPUT ruleExecOut
