myStagingRule {
# rda-stage.r
# Loop over files in a staging area, /$rodsZoneClient/home/$userNameClient/*stage
# Put all files into collection /*DestZone/home/$userNameClient#$rodsZoneClient/*Coll
  *Src = "/$rodsZoneClient/home/$userNameClient/*Stage";
  *Dest= "/*DestZone/home/$userNameClient" ++ "#$rodsZoneClient/" ++ *Coll;
  checkCollInput (*Src);
  checkCollInput (*Dest); 
  checkRescInput (*Res, *DestZone);
  createLogFile (*Dest, "log", "Check", *Res, *LPath, *Lfile, *Dfile, *L_FD);
 
#============ find files to stage
  *Query = select DATA_NAME, DATA_CHECKSUM where COLL_NAME = '*Src';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Check = *Row.DATA_CHECKSUM;
    *Src1 = *Src ++ "/" ++ *File;
    *Dest1 = *Dest ++ "/" ++ *File;
# Move file and set access permission
    msiDataObjCopy(*Src1,*Dest1,"destRescName=*Res++++forceFlag=", *Status); 
    msiSetACL("default","own",$userNameClient, *Dest1);
    writeLine("*Lfile", "Moved file *Src1 to *Dest1");
# verify checksum
    msiDataObjChksum(*Dest1, "forceChksum=", *Chksum);
    if(*Check != *Chksum) {
      writeLine("*Lfile", "Checksum failed on *Dest1");
    }
# Delete file from staging area if checksum is good
    else {
      msiDataObjUnlink("objPath=*Src1++++forceFlag=", *Status); 
    }
  }  
}
INPUT *Stage =$"stage", *Coll=$"Archive", *DestZone=$"tempZone", *Res=$"demoResc"
OUTPUT ruleExecOut
