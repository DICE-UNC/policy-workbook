myStagingRule {
# rda-stageformat.r
# Periodic execution of the staging of files
  *Src = "/$rodsZoneClient/home/$userNameClient/" ++ *Stage;
  *Dest= "/$rodsZoneClient/home/$userNameClient/" ++ *Coll;
  checkCollInput (*Src);
  checkCollInput (*Dest);
  delay("<PLUSET>1m</PLUSET><EF>1d</EF>") {
# Loop over files in a staging area, /$rodsZoneClient/home/$userNameClient/*stage
# Put all files with .r into collection /$rodsZoneClient/home/$userNameClient/*Coll

# ==== create a collection for log files if it does not exist
    createLogFile (*Dest, "log", "Check", *Res, *LPath, *Lfile, *Dfile, *L_FD);

#============ find files to stage
    *Query = select DATA_NAME where COLL_NAME = '*Src' and DATA_NAME like '%.r';
    foreach(*Row in *Query) {
      *File = *Row.DATA_NAME;
      *Src1 = *Src ++ "/" ++ *File;
      *Dest1 = *Dest ++ "/" ++ *File;
#Check whether file already exists
      *Q3 = select count(DATA_NAME) where COLL_NAME = '*Dest' and DATA_NAME = '*File';
      foreach (*R3 in *Q3) { *DataID = *R3.DATA_NAME;}
# Move file and set access permission
      if(*DataID == "0") {
        msiDataObjRename(*Src1,*Dest1, "0", *Status);
        msiSetACL("default","own",$userNameClient, *Dest1);
        writeLine("*Lfile", "Moved file *Src1 to *Dest1");
      }
    }
  }
}
INPUT *Stage =$"stage", *Coll=$"rules", *Res=$"demoResc"
OUTPUT ruleExecOut

