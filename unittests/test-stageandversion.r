stagingplusversioningRule {
# creates a rule that archives files from a source collection to an archive
# the rule versions the files if they already exist in the archive
# check collections
  *Src = "/$rodsZoneClient/home/$userNameClient/*Source";
  *Dest = "/$rodsZoneClient/home/$userNameClient/*Destination";
  writeLine("stdout", "Source *Src");
  checkCollInput (*Src);
  writeLine("stdout", "Destination *Dest");
  checkCollInput (*Dest); 
  writeLine("stdout", "Resource *Res");
  checkRescInput (*Res, *DestZone);
  *Len = strlen(*Src);
# get current time, Timestamp is YYY-MM-DD.hh:mm:ss 
  msiGetSystemTime(*TimeA, "unix");
# create a collection for log files if it does not exist 
  createLogFile (*Dest, "log", "Check", *Res, *LPath, *Lfile, *L_FD);
  writeLine("stdout", "Path *LPath, Log at *Lfile");
# find files that already in the archive
*Query = select DATA_NAME, DATA_CHECKSUM, DATA_ID, COLL_NAME where COLL_NAME = '*Src';
  foreach(*Row in *Query) {
    *File = *Row.DATA_NAME;
    *Check = *Row.DATA_CHECKSUM;
    *Coll = *Row.COLL_NAME;
    *Dataid = *Row.DATA_ID;
	*temp_count=0;
	*Query2 = select count(DATA_ID) where COLL_NAME like '*Dest%' and DATA_NAME='*File';
   foreach(*Row2 in *Query2){
     *temp_count = int( *Row2.DATA_ID);
   }
# if file not already archived then copy file over
   if(*temp_count ==0){
          *Src1 = "*Coll/*File";
          *Dest1 = "*Dest/*File";
          msiDataObjCopy(*Src1,*Dest1,"destRescName=*Res++++forceFlag=", *Status);
          msiSetACL("default","own", "*Acct", *Dest1);
          msiDataObjChksum(*Dest1, "forceChksum=", *Chksum);
          if (*Check != *Chksum) {
            writeLine("*Lfile", "Bad checksum for file *Dest1");
          } else {
            writeLine("*Lfile", "Moved file *Src1 to *Dest1");
          }
        }
# if file already archived then create versioned file with timestamp
	else {
# name of the versioned file
	  *Path = "*Coll/*File";
      checkPathInput (*Path);
	  msiSplitPath(*Path, *Coll2, *Fil);
# build the version name with timestamp
      msiStrlen(*Fil,*Lfile);
	  msiGetSystemTime(*Tim, "human");
# check for a file extension
	  *Lsub = int(*Lfile);
	  *Iloc = *Lsub -1;
	while (*Iloc >= 0) {
    msiSubstr(*Fil,"*Iloc","1",*Char);
    if (*Char == ".") {
      *Lsub = *Iloc;
      break;
    }
    else {
      *Iloc = *Iloc -1;
    }
	}
	msiSubstr(*Fil,"0","*Lsub",*Fstart);
	*Fend = "";
	if(*Iloc != 0) {
     *Iloc =int(*Lfile) - *Lsub; 
      msiSubstr(*Fil,"*Lsub","*Iloc",*Fend);
	}
	 *Vers = *Fstart ++ "." ++ "*Tim" ++ *Fend;
	 *Pathver = *Coll2 ++ "/" ++ *Vers;
# copy the versioned file over to the destination collection
	 msiDataObjCopy(*Path,*Pathver, "forceFlag=",*Status);
	 msiSetACL("default","own", "*Acct", *Pathver);
     msiDataObjChksum(*Pathver, "forceChksum=", *Chksum);
     if (*Check != *Chksum) {
		writeLine("*Lfile", "Bad checksum for file *Pathver");
    } else {
		writeLine("*Lfile", "Moved file *Src1 to *Pathver");
          }
	}
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
  *Lfile = "*LPath/*Name:*TimeH";
  *Dfile = "destRescName=*Res++++forceFlag=";
  msiDataObjCreate(*Lfile, *Dfile, *L_FD);
}
INPUT *Res="LTLResc", *DestZone="lifelibZone", *Acct="$userNameClient", *Source="test",*Destination="archive"
OUTPUT ruleExecOut
