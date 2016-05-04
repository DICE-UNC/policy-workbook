collBackup {
# test-collBackupChanges.r
# create a backup copy of files in source collection
# create versioned subdirectory containing changed files
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *Num = 0;
  *Timc = 0.;
  msiSplitPath (*Coll, *Head, *End);
  *Q2 = select COLL_NAME, COLL_CREATE_TIME where COLL_PARENT_NAME = '*Coll';
  foreach (*R2 in *Q2) {
    *Ver = *R2.COLL_NAME;
    *Vend = "0";
    *Out = errormsg(msiSplitPathByKey(*Ver, ".", *Vhead, *Vend), *Msg);
    if (int(*Vend) > *Num) {
      *Num = int(*Vend);
      *Timc = double(*R2.COLL_CREATE_TIME);
    }
  }
  *Numinc = *Num + 1;
  *Vers = *End ++ "." ++ "*Numinc";
  *Pathver = *Coll ++ "/" ++ *Vers;
  isColl(*Pathver, "stdout", *Status);
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Q3 = select DATA_MODIFY_TIME where DATA_NAME = '*File' and COLL_NAME = '*Coll';
    foreach (*R3 in *Q3) {*Timem = double(*R3.DATA_MODIFY_TIME);}
    if(*Timem > *Timc) {
      *Path = "*Coll/*File";
      *Pathd = "*Pathver/*File";
      msiDataObjCopy(*Path,*Pathd, "forceFlag=",*Status);
      writeLine("stdout","*Path written as version *Pathd");
    }
  }
}
INPUT *SourceColl =$"uploads"
OUTPUT ruleExecOut
