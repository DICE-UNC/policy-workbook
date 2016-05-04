testCopy {
# trying multiple copies
  *Coll = "/$rodsZoneClient/home/$userNameClient/uploads";
  *CollDest = "/$rodsZoneClient/home/$userNameClient/test";
  *Q1 = select DATA_NAME where COLL_NAME = '*Coll';
  *Lfile = "stdout";
  *Res = "lifelibResc1";
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Path = "*Coll/*File";
    *Pathd = "*CollDest/*File";
    writeLine("*Lfile"," *Coll, *File, *Path, *Pathd");
    *out = errormsg(msiDataObjCopy(*Path, *Pathd, "destRescName=*Res++++forceFlag=", *Status), *msg);
    if(*out != 0) {
      writeLine("*Lfile", "Error on copy *out, error message *msg");
      writeLine("*Lfile", "Unable to back up *File");
    } else {
      writeLine("*Lfile","*File stored as version *Pathd");
    }
  }
}
INPUT null
OUTPUT ruleExecOut
