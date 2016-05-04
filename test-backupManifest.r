manifestBackup {
# test-backupManifest.r
# create a backup copy of files in backup  collection
# create versioned subdirectory containing changed files
# log all changes in a manifest
# periodically execute the rule
  *Coll = "/$rodsZoneClient/home/$userNameClient/*SourceColl";
  *CollBack = "/$rodsZoneClient/home/$userNameClient/Backup";
  *CollMan = "/$rodsZoneClient/home/$userNameClient/Reports";
# *CollMan is a collection holding the manifest file
# *Manifest is the name of the manifest file
  isColl (*CollMan, "stdout", *Status);
  isColl (*CollBack, "stdout", *Status1);
  *Lfile = "*CollMan/*Manifest";
  isData (*CollMan, *Manifest, *Status);
  if (*Status == "0") {
# create manifest file
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *C_FD);
    msiDataObjClose (*C_FD, *Status);
    writeLine("stdout", "Created *Manifest file");
  }
  manifest (*Lfile, *Coll, *CollBack, *Res);
}
manifest(*Lfile, *Coll, *CollBack,  *Res) {
  delay ("<PLUSET>1s</PLUSET><EF>10s</EF>") {
    msiDataObjOpen("objPath=*Lfile++++openFlags=O_RDWR", *L_FD);
    msiDataObjLseek (*L_FD, "0", "SEEK_END", *Status);
    msiGetSystemTime (*Tim, "human");
    writeLine ("*Lfile", "Backup executed at *Tim");
    *Num = 0;
    *Timc = 0.;
    msiSplitPath (*Coll, *Head, *End);
    *Collsub = "*CollBack/*End";
    *Q2 = select COLL_NAME, COLL_CREATE_TIME where COLL_PARENT_NAME = '*CollBack' and COLL_NAME like '*Collsub%';
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
    msiSplitPath (*Coll, *Head, *End);
    *Vers = *End ++ "." ++ "*Numinc";
    *Pathver = *CollBack ++ "/" ++ *Vers;
    *Status = 0;
    *Result = "0";
    *Query0 = select count(COLL_ID) where COLL_NAME = '*Pathver';
    foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
    if(*Result == "0" ) {
      msiCollCreate(*Pathver, "1", *Status);
      if(*Status < 0) {
        writeLine("*Lfile","Could not create *Pathver collection");
      }
    }
    *Q0 = select count(DATA_NAME) where COLL_NAME = '*Coll';
    foreach (*R0 in *Q0) {*N = *R0.DATA_NAME;}
    if (*N > "0") {
      *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
      foreach(*R1 in *Q1) {
        *File = *R1.DATA_NAME;
        *Q3 = select DATA_MODIFY_TIME where DATA_NAME = '*File' and COLL_NAME = '*Coll';
        foreach (*R3 in *Q3) {*Timem = double(*R3.DATA_MODIFY_TIME);}
        if(*Timem > *Timc) {
          *Path = "*Coll/*File";
          *Pathd = "*Pathver/*File";
          *out = errormsg(msiDataObjCopy(*Path, *Pathd, "destRescName=*Res++++forceFlag=", *Status), *msg);
          if(*out != 0) {
            writeLine("*Lfile", "Unable to back up *File");
          } else {
            writeLine("*Lfile","*File stored as version *Pathd");
          }
        }
      }
    }
    msiDataObjClose(*L_FD, *Status);
  }
}
INPUT *SourceColl =$"uploads", *Res =$"LTLResc", *Manifest = "Manifest"
OUTPUT ruleExecOut
