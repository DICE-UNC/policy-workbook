periodicArchive {
# dmp-periodic-backup.r
  checkCollInput (*Src);
  checkCollInput (*Dest);
  checkRescInput (*Res, *DestZone);
# periodically archive a collection every week
  delay("<PLUSET>1m</PLUSET><EF>7d</EF>") {
    collArchive (*Res, *Src, *Dest, *Acct);
  }
  writeLine("stdout","Periodic rule queued for archiving a collection");
}
collArchive (*Res, *Src, *Dest, *Acct) {
# Loop over files in a collection, *Src
# Copy all files into an archive collection. *Dest
  *Len = strlen(*Src);
#=============get current time, Timestamp is YYY-MM-DD.hh:mm:ss  ================
  msiGetSystemTime(*TimeA, "unix");

#============ create a collection for log files if it does not exist ===============
  createLogFile (*Dest, "log", "Check", *Res, *LPath, *Lfile, "forceFlag=", *L_FD);

#============ find files to archive
  *Query = select DATA_NAME, DATA_CHECKSUM,COLL_NAME where COLL_NAME like '*Src%';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Check = *Row.DATA_CHECKSUM;
    *Coll = *Row.COLL_NAME;
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
    isColl(*DestColl, *Lfile, *Status1);
    if (*Status1 == "0") {
# If file is already in the archive, do not copy it again
      isData(*DestColl, *File, *Status);
      if (*Status == "0") {
        msiDataObjCopy(*Src1,*Dest1,"destRescName=*Res++++forceFlag=", *Status);
        msiSetACL("default","own", "*Acct", *Dest1);
        msiDataObjChksum(*Dest1, "forceChksum=", *Chksum);
        if (*Check != *Chksum) {
          writeLine("*Lfile", "Bad checksum for file *Dest1");
        }
        else { writeLine("*Lfile", "Moved file *Src1 to *Dest1");
          writeLine("*Lfile", "Moved file *Src1 to *Dest1");
        }
      }
    }
  }
}
INPUT *Res=$"stage", *DestZone =$"ornlZone", *Acct =$"Mauna-acct", *Src=$"/Mauna/home/atmos/sensor", *Dest =$"/*DestZone/home/*Acct#Mauna/archive"
OUTPUT ruleExecOut
