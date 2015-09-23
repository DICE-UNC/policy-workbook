myStagingRule {
# odum-stage-ag.r
# Loop over files in a staging area, /$rodsZoneClient/home/$userNameClient/*stage
# Check that the variable "Use_Agreement" on the collection has the value "RECEIVED"
# If true, put all files into collection /$rodsZoneClient/home/$userNameClient/*Coll
  *Src = "/$rodsZoneClient/home/$userNameClient/" ++ *Stage;
  *Dest= "/$rodsZoneClient/home/$userNameClient/" ++ *Coll;
  checkCollInput (*Src);
  checkCollInput (*Dest);
  *Query1 = select META_COLL_ATTR_VALUE where COLL_NAME = '*Src' and META_COLL_ATTR_NAME = 'Use_Agreement';
  foreach (*Row1 in *Query1) {
    *Use = *Row1.META_COLL_ATTR_VALUE;
  }
  if (*Use == "RECEIVED") {
    *Query2 = select DATA_NAME where COLL_NAME = '*Src';
    foreach(*Row2 in *Query2) {
      *File = *Row2.DATA_NAME;
      *Src1 = *Src ++ "/" ++ *File;
      *Dest1 = *Dest ++ "/" ++ *File;
#Check whether file already exists
      *Q3 = select count(DATA_NAME) where COLL_NAME = '*Dest' and DATA_NAME = '*File';
      foreach (*R3 in *Q3) { *DataID = *R3.DATA_NAME;}
# Move file and set access permission
      if(*DataID == "0") {
        msiDataObjRename (*Src1, *Dest1,"0", *Status);
        if (*Status == "0") { 
          writeLine("stdout", "Moved file *Src1 to *Dest1"); 
        }
        else {
          writeLine("stdout", "File *Src1 was not moved");
        }
      }
    }
  }  
}
INPUT *Stage =$"stage", *Coll=$"Rules"
OUTPUT ruleExecOut
