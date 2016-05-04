manifestBackup {
# test-manifestBackup.r
# create a backup copy of files in source collection
# create versioned subdirectory containing changed files
# log all changes in a manifest
# periodically execute the rule
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *CollMan = "/$rodsZoneClient/home/$userNameClient/Reports";
  periodicBackup (*Coll, *CollMan, "Manifest", *Res);
  writeLine("stdout", "Started periodic backup of *Coll");
}
periodicBackup (*Coll, *CollMan, *Manifest, *Res) {
#  delay ("<PLUSET>1s</PLUSET><EF>1m</EF>") {
  createManifest (*CollMan, *Manifest, *Res, *Lfile, *L_FD);
  msiGetSystemTime (*Tim, "human");
  writeLine ("*Lfile", "Backup executed at *Tim");
  *Num = 0;
  *Timc = 0.;
  msiSplitPath (*Coll, *Head, *End);
  *Q2 = select COLL_NAME, COLL_CREATE_TIME where COLL_PARENT_NAME = '*Coll';
  foreach (*R2 in *Q2) {
    *Ver = *R2.COLL_NAME;
    *Vend = "0";
    *Stat = errormsg(msiSplitPathByKey(*Ver, ".", *Vhead, *Vend),*msg);
    if (*Stat == 0 && int(*Vend) > *Num) {
      *Num = int(*Vend);
      *Timc = double(*R2.COLL_CREATE_TIME);
    }
  }
  *Numinc = *Num + 1;
  *Vers = *End ++ "." ++ "*Numinc";
  *Pathver = *Coll ++ "/" ++ *Vers;
  isColl(*Pathver, *Lfile, *Status);
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Q3 = select DATA_MODIFY_TIME where DATA_NAME = '*File' and COLL_NAME = '*Coll';
    foreach (*R3 in *Q3) {*Timem = double(*R3.DATA_MODIFY_TIME);}
    if(*Timem > *Timc) {
      *Path = "*Coll/*File";
      *Pathd = "*Pathver/*File";
      writeLine("*Lfile","periodicBackup *Coll, *File, *Path, *Pathd");
      *out = errormsg(msiDataObjCopy(*Path, *Pathd, "destRescName=*Res++++forceFlag=", *Status), *msg);
      if(*out != 0) {
        writeLine("*Lfile", "Error on copy *out, error message *msg");
        writeLine("*Lfile", "Unable to back up *File");
      } else {
        writeLine("*Lfile","*File stored as version *Pathd");
      }
    }
  }
#}
}
isColl (*LPath, *Lfile, *Status) {
  *Status = 0;
  *Result = "0";
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  writeLine("stdout", "isColl *Result");
  if(*Result == "0" ) {
    msiCollCreate(*LPath, "1", *Status);
    if(*Status < 0) {
      writeLine("stdout","Could not create *LPath collection");
      writeLine("*Lfile","Could not create *LPath collection");
    } 
    # end of log collection creation
  }
}
createManifest (*Coll, *Manifest, *Res, *Lfile, *L_FD) {
# *Coll is a collection holding the manifest file
# *Manifest is the name of the manifest file
  isColl (*Coll, "serverLog", *Stat);
  writeLine("stdout","createManifest *Coll, *Manifest");
  isData (*Coll, *Manifest, *Status);
  *Lfile = "*Coll/*Manifest";
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
  } else {
    msiDataObjOpen("objPath=*Lfile", *L_FD);
    msiDataObjLseek (*L_FD, "0", "SEEK_END", *Status);
  }
}
isData (*Coll, *File, *Status) {
# Check whether a file already exists
  writeLine("stdout", "isData *Coll, *File");
  *Q = select count(DATA_ID) where COLL_NAME = '*Coll' and DATA_NAME = '*File';
  foreach (*R in *Q) {
    *Status = *R.DATA_ID;
  }
  *Status;
}

INPUT *SourceColl =$"uploads", *Res =$"lifelibResc1"
OUTPUT ruleExecOut
