testfile {
# test-file.r
# verify each file exists
  *Coll = "/$rodsZoneClient/home/$userNameClient";
  *Q1 = select DATA_NAME, COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Col = *R1.COLL_NAME;
    *Path = "*Col/*File";
    *Out2 = errormsg(msiDataObjChksum(*Path, "ChksumAll=++++verifyChksum=", *Chksum), *msg1);
    if (*Out2 != 0) {writeLine("stdout", "Error *msg1 for *Path");}
  }
}
INPUT null
OUTPUT ruleExecOut
