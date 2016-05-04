manifestSummary {
# test-manifestSummary.r
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  *LPath = "*Coll/Reports";
  isColl (*LPath, "stdout", *Status);
  isData (*LPath, *Manifest, *Status);
  if (*Status == "0") {
# create manifest file
    *Lfile = "*LPath/*Manifest";
    *Dfile = "destRescName=*Res++++forceFlag=";
    msiDataObjCreate(*Lfile, *Dfile, *L_FD);
  } else {
    *Lfile = "*LPath/*Manifest";
    msiDataObjOpen("objPath=*Lfile", *L_FD);
  }
  msiDataObjLseek (*L_FD, "0", "SEEK_END", *Status);
  msiGetSystemTime (*Tim, "human");
  *Q1 = select count(DATA_ID), sum(DATA_SIZE) where COLL_NAME like '*LPath%';
  foreach(*R1 in *Q1){
    *Num = *R1.DATA_ID;
    *Sum = *R1.DATA_SIZE;
    writeLine("*Lfile", "*Tim, Number = *Num, Size = *Sum");
  }
}
INPUT *Manifest ="Storage", *Res ="LTLResc"
OUTPUT ruleExecOut
