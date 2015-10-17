myStagingRule {
# hipaa-stageFederation.r
# Loop over files in a collection, *Src 
# Put all files into a staging collection. *Dest
  checkCollInput (*Src);
  checkCollInput (*Dest);
  checkRescInput (*Res, *DestZone);
  *Len = strlen(*Src);

#=============get current time, Timestamp is YYY-MM-DD.hh:mm:ss  ================
  msiGetSystemTime(*TimeA,"unix");

#============ create a collection for log files if it does not exist ===============
  createLogFile(*Dest, "log", "Check", *Res, *LPath, *Lfile, *L_FD);

#============ find files to stage
  *Query = select DATA_NAME, DATA_CHECKSUM, COLL_NAME, DATA_MODIFY_TIME where COLL_NAME like '*Src%';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Check = *Row.DATA_CHECKSUM;
    *Coll = *Row.COLL_NAME;
    if(*Coll != "*LPath") {
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
       if (*Status >= 0) {
         msiDataObjCopy(*Src1,*Dest1,"destRescName=*Res++++forceFlag=", *Status);
         msiSetACL("default","own",*Owner, *Dest1);
         msiDataObjChksum(*Dest1, "forceChksum=", *Chksum);
         if (*Check != *Chksum) {
           writeLine("*Lfile", "Bad checksum for file *Dest1");
         }
         else {
            writeLine("*Lfile","*Src1 copied to *Dest1 *Check *TimeH");
         }
       }
     }
  }
}
INPUT *Res=$"demoResc", *DestZone =$"tempZone", *Src=$"/$rodsZoneClient/home/$userNameClient/sub1", *Dest=$"/*DestZone/home/*Owner/sub2", *Owner = "odum_fed#dfcmain"
OUTPUT ruleExecOut
