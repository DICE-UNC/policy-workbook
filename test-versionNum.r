versionNum {
# test-versionNum.r
# create a copy of files in source collection with a version number
# input
#  path name
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *DesColl = "/$rodsZoneClient/home/$userNameClient/*DestColl";
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Path = "*Coll/*File";
    *Q2 = select DATA_NAME where COLL_NAME = '*DesColl' and DATA_NAME like '*File..%';
    *Num = 0;
    foreach (*R2 in *Q2) {
      *Ver = *R2.DATA_NAME;
      *Vend = int(substr(*Ver, strlen(*File)+2, strlen(*Ver)));
      if (*Vend > *Num) {*Num = *Vend;}
    }
    *Numinc = *Num + 1;
    *Vers = *File ++ ".." ++ "*Numinc";
    *Pathver = *DesColl ++ "/" ++ *Vers;
    msiDataObjCopy(*Path,*Pathver, "forceFlag=",*Status);
    writeLine("stdout","*Path written as version *Pathver");
  }
}
INPUT *SourceColl =$"updates", *DestColl =$"archive"
OUTPUT ruleExecOut
