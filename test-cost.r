costReport {
# test-cost.r
# calculate cost based on number of files, size, and metadata
# tabulate costs for all files in the *Src directory
# report is stored in specified directory, *Rep
  isColl (*Src, "stdout", *Stat);
  isColl (*Rep, "stdout", *Stat1);
  checkRescInput (*Res, $rodsZoneClient);
#============ create a collection for log files if it does not exist ===============
  createLogFile (*Rep, "Reports", "Cost", *Res, *LPath, *Lfile, *L_FD);

  *Count = 0;
  *Tot = 0.;
  *Countmeta = 0;
  *Q = select DATA_ID, DATA_SIZE where COLL_NAME like '*Src%';
  foreach (*R in *Q) {
    *Count = *Count + 1;
    *Size = *R.DATA_SIZE;
    *DataID = *R.DATA_ID;
    *Tot = *Tot + double(*Size);
    *Q1 = select count(META_DATA_ATTR_ID) where DATA_ID = '*DataID';
    foreach (*R1 in *Q1) {*Cmeta = *R1.META_DATA_ATTR_ID;}
    *Countmeta = *Countmeta + int(*Cmeta);
  }
  writeLine("*Lfile", "Cost factors are\n  \$*FacSize per GByte\n  \$*FacCount per million files\n  \$*FacMeta per million metadata attributes");
  *CostS = *FacSize * *Tot / 1000000000.;
  *CostN = *FacCount * *Count / 1000000;
  *CostM = *FacMeta * *Countmeta / 1000000;
  writeLine ("*Lfile","Storage cost = \$*CostS for *Tot bytes");
  writeLine ("*Lfile", "File cost = \$*CostN for *Count files");
  writeLine ("*Lfile", "Metadata cost = \$*CostM for *Countmeta attributes");
}
INPUT *FacSize=0.10, *FacCount=1., *FacMeta=1., *Src=$"/$rodsZoneClient/home/$userNameClient", *Res="LTLResc", *Rep=$"/$rodsZoneClient/home/$userNameClient"
OUTPUT ruleExecOut
