testOwn {
  checkOwnerAccess ("/$rodsZoneClient/home/$userNameClient/log", "foo1", *Stat);
  writeLine ("stdout", "Status was *Stat");
  checkRescInput (*Res, $rodsZoneClient);
  createLogFile ("/$rodsZoneClient/home/$userNameClient", "log", "Check", *Res, *LPath, *Lfile, *L_FD);
  writeLine ("stdout", "Path *LPath, Lfile *Lfile, FD *L_FD");
}
checkOwnerAccess(*Coll, *File, *Stat) {
# check that owner of file has access to the file
  *Q1 = select DATA_OWNER_NAME, DATA_ID where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach (*R1 in *Q1) {
    *Owner = *R1.DATA_OWNER_NAME;
    *Dataid = *R1.DATA_ID;
  }
  *Q2 = select USER_ID where USER_NAME = '*Owner';
  foreach (*R2 in *Q2) {*Userid = *R2.USER_ID;}
# Find ACL for the file
  *Q3 = select DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*Dataid';
# Loop over access controls for each file
  *Stat = "1";
  foreach(*R3 in *Q3) {
    *Userdid = *R3.DATA_ACCESS_USER_ID;
    if(*Userid == *Userdid) {
      *Stat = "0";
      break;
    }
  }
}
checkRescInput (*Res, *Zone) {
# local zone is defined by your irods_environment file
  if (*Zone != $rodsZoneClient) {
# execute query in the remote zone
    findZoneHostName(*Zone, *Host, *Port);
    remote (*Host,"<ZONE>*Zone</ZONE>") {
      *Q1 = select count(RESC_ID) where RESC_NAME = '*Res';
      foreach (*R1 in *Q1) {*n = *R1.RESC_ID;}
      if (*n == "0") {
        writeLine("stdout","Remote resource *Res is not defined in zone *Zone");
#       fail;
      }
      writeLine("stdout", "Resource *Res exists in remote zone *Zone");
    }
  }
  else {
# query local zone
    *Q1 = select count(RESC_ID) where RESC_NAME = '*Res';
    foreach (*R1 in *Q1) {*n = *R1.RESC_ID;}
    if (*n == "0") {
      writeLine ("stdout", "Local resource *Res is not defined");
      fail;
    }
    writeLine ("stdout", "Resource *Res exists in local zone $rodsZoneClient");
  }
}
createLogFile (*Coll, *Sub, *Name, *Res, *LPath, *Lfile, *L_FD) {
# Create a log sub-directory within *Coll if it is missing
# Create a timestamped log file with the input file name *Name
  msiGetSystemTime(*TimeH,"human");
#============ create a collection for log files if it does not exist ===============
  *LPath = "*Coll/*Sub";
  isColl (*LPath, "stdout", *Status);
  if (*Status < 0) { fail;}
#============ create file into which results will be written =========================
  *Lfile = "*LPath/*Name-*TimeH";
  *Dfile = "destRescName=*Res++++forceFlag=";
  msiDataObjCreate(*Lfile, *Dfile, *L_FD);
}
isColl (*LPath, *Lfile, *Status) {
  *Status = 0;
  *Query0 = select count(COLL_ID) where COLL_NAME = '*LPath';
  foreach(*Row0 in *Query0) {*Result = *Row0.COLL_ID;}
  if(*Result == "0" ) {
    writeLine("stdout","Creating collection *LPath");
    msiCollCreate(*LPath, "1", *Status);
    if(*Status < 0) {
      writeLine("*Lfile","Could not create *LPath collection");
    }  # end of check on status
  }  # end of log collection creation
}
INPUT *Res = "lifelibResc1" 
OUTPUT ruleExecOut
