createChecksums {
# test-checksum.r
# verify each file has a checksum
  *Coll = "/$rodsZoneClient/home/$userNameClient/archive";
  *Q1 = select DATA_NAME, DATA_CHECKSUM, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Check = *R1.DATA_CHECKSUM;
    *Path = "*Col/*File";
    if (*Check == "") {
# create checksum
      *Out2 = errormsg(msiDataObjChksum(*Path, "ChksumAll=++++verifyChksum=", *Chksum), *msg1);
      if (*Out2 != 0) {writeLine("stdout", "Error *msg1 for *Path");}
      writeLine("stdout","For *Col/*File New checksum = *Chksum, Old checksum = *Check");
    }
  }
}
INPUT null
OUTPUT ruleExecOut
