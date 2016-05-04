storeFile {
# execute the rule with irule -F test-StoreFile.r "*File='localfilename'"
# Store report in standard collection with time stamp
  *Coll = "/lifelibZone/home/$userNameClient/Reports";
  isColl(*Coll, "stdout", *Status1);
  if (*Status1 < 0) { fail;}  
  *Res = "LTLResc";
  msiGetSystemTime(*Time,"human");
  msiSplitPathByKey (*File, "/", *Col, *File1);
  writeLine ("stdout", "*File, *Col, *File1");
  *Path = "*Coll/*File1" ++ ".*Time";
  *local = "localPath=*File++++forceFlag=";
  msiDataObjPut(*Path, *Res, *local, *Status);
  if (*Status >= 0) {
    writeLine ("stdout", "*File was stored in *Path");
  }
}
isColl (*LPath, *Lfile, *Status) {
  *Status = 0;
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  if(*Result == "0" ) {
    msiCollCreate(*LPath, "1", *Status);
    if(*Status < 0) {
      writeLine("*Lfile","Could not create *LPath collection");
    }  # end of check on status
  }  # end of log collection creation
}
INPUT *File="/Users/reagan/Documents/copy/UNC/iRODS-Course/2016/rules/test" 
OUTPUT ruleExecOut
