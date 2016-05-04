collBackup {
# test-collBackup.r
# create a backup copy of files in source collection
# create versioned subdirectory 
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *Num = 0;
  msiSplitPath (*Coll, *Head, *End);
  *Q2 = select COLL_NAME where COLL_PARENT_NAME = '*Coll';
  foreach (*R2 in *Q2) {
    *Ver = *R2.COLL_NAME;
    *Vend = "0";
    *out = errormsg(msiSplitPathByKey(*Ver, ".", *Vhead, *Vend),*msg);
    if (int(*Vend) > *Num) {*Num = int(*Vend);}
  }
  *Numinc = *Num + 1;
  *Vers = *End ++ "." ++ "*Numinc";
  *Pathver = *Coll ++ "/" ++ *Vers;
  isColl(*Pathver, "stdout", *Status);
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Path = "*Coll/*File";
    *Pathd = "*Pathver/*File";
    msiDataObjCopy(*Path,*Pathd, "forceFlag=",*Status);
    writeLine("stdout","*Path written as version *Pathd");
  }
}
INPUT *SourceColl =$"uploads"
OUTPUT ruleExecOut
