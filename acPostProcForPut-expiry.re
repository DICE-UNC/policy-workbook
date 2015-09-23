acPostProcForPut {
  msiSplitPath($objPath, *Coll, *File);
  if(*Coll ==  "/UNC-ARCHIVE/home/Archive") {
    msiGetSystemTime(*T, "unix");
    *Time = int(*T) + 3600*24*365;
    msiSysMetaModify("data_expiry", "*Time");
  }
}
