myStagingRule {
# odum-periodic-stage.r
# Loop over files in a collection, *Src 
# Put all files into a staging collection. *Dest
  checkCollInput (*Src);
  checkCollInput (*Dest);
  checkRescInput (*Res, *DestZone);
  delay ("<PLUSET>1m</PLUSET><EF>7d</EF>") {
    stage(*Src, *Res, *Dest);
  }
}
stage(*Src, *Res, *Dest) {
  *Len = strlen(*Src);

#=============get current time, Timestamp is YYY-MM-DD.hh:mm:ss  ================
msiGetSystemTime(*TimeA,"unix");

#============ create a collection for log files if it does not exist ===============
  createLogFile(*Src, "log", "Check", *Res, *LPath, *Lfile, *Dfile, *L_FD);
#============ find files to stage
  *Query = select DATA_NAME, DATA_CHECKSUM,COLL_NAME where COLL_NAME like '*Src%';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Check = *Row.DATA_CHECKSUM;
    *Coll = *Row.COLL_NAME;
    if (*Coll != *LPath ) {
      *L1 = strlen(*Coll);
      *Src1 = *Coll ++ "/" ++ *File;
      *C1 = substr(*Coll,*Len,*L1);
      if(strlen(*C1)==0) {
         *DestColl = *Dest;
         *Dest1 = *Dest ++ "/" ++ *File;
      } else {
         *DestColl = *Dest ++ *C1;
         *Dest1 = *Dest ++ *C1 ++ "/" ++ *File;
      }
      isColl(*DestColl, *Lfile, *Status);
      if (*Status >= "0") {
        msiDataObjCopy(*Src1,*Dest1,"destRescName=*Res++++forceFlag=", *Status);
        msiSetACL("default","own","rwmoore#testZone", *Dest1);
        msiDataObjChksum(*Dest1, "forceChksum=", *Chksum);
        if (*Check != *Chksum) {
          writeLine("*Lfile", "Bad checksum for file *Dest1");
        }
        else { writeLine("*Lfile", "Moved file *Src1 to *Dest1");
          writeLine("*Lfile","Moved file *Src1 to *Dest1");
        }
      }
    }
  }
}
INPUT *Res=$"demoResc", *DestZone =$"tempZone", *Src=$"/$rodsZoneClient/home/$userNameClient/stage", *Dest =$"/*DestZone/home/$userNameClient#$rodsZoneClient/stage"
OUTPUT ruleExecOut
