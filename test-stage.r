myStagingRule {
# rda-stage.r
# Loop over files in a staging area, /$rodsZoneClient/home/$userNameClient/*stage
# Put all files into collection /$rodsZoneClient/home/$userNameClient/*Coll
  *Src = "/$rodsZoneClient/home/$userNameClient/*Stage";
  *Dest= "/$rodsZoneClient/home/$userNameClient/*Coll";
  checkCollInput (*Src);
  checkCollInput (*Dest);
 
#============ find files to stage
  *Query = select DATA_NAME, DATA_CHECKSUM where COLL_NAME = '*Src';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Check = *Row.DATA_CHECKSUM;
    *Src1 = *Src ++ "/" ++ *File;
    *Dest1 = *Dest ++ "/" ++ *File;
# Move file and set access permission
    writeLine("stdout", "Moving file *Src1 to *Dest1");
    msiDataObjCopy(*Src1,*Dest1,"forceFlag=", *Status);
    msiSetACL("default","own",$userNameClient, *Dest1);
# verify checksum
    msiDataObjChksum(*Dest1, "forceChksum=", *Chksum);
    if(*Check != *Chksum) {
      writeLine("stdout", "Checksum failed on *Dest1");
    }
# Delete file from staging area if checksum is good
    else {
      msiDataObjUnlink("objPath=*Src1++++forceFlag=", *Status);
    }
  } 
}
INPUT *Stage=$"stage", *Coll=$"archive"
OUTPUT ruleExecOut
