acPostProcForPut {
# calculate the checksum
# append the file size, date, and checksum to a report
  msiSplitPath ($objPath, *Coll, *File);
  if (*Coll == "/dfcmain/home/rwmoore/Project") {
    msiDataObjChksum($objPath, "forceChksum=", *Chksum);
    *Q1 = select DATA_SIZE where DATA_NAME = '*File' and COLL_NAME = '*Coll';
    foreach (*R1 in *Q1) {*Size = *R1.DATA_SIZE;}
    msiGetSystemTime(*Tim, "human");
# open report file
    *LPath = "/dfcmain/home/rwmoore/Project/Depreport"
    msiDataObjOpen(*LPath, *Fdesc);
    msiDataObjLseek(*Fdesc, "0", "SEEK_END", *Stat);
    writeLine("*LPath", "*Tim *File, Size *Size, Checksum *Chksum");
  }
}
