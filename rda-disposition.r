rule-disposition {
# rda-disposition.r
#Input parameter is:
#  Name of collection that will be checked
#  Retention_Flag with value "EXPIRED" or "NOT EXPIRED"
#Output is:
#  Migration of "EXPIRED" files to an archive collection
  *Coll = "/$rodsZoneClient/home/$userNameClient/" ++ *Collrel;
  *Dest = "/$rodsZoneClient/home/$userNameClient/" ++ *Archiverel;
#Verify that input path is a collection
  checkCollInput (*Coll);
#Verify that archive path is a collection
  checkCollInput (*Dest);
  *Count = 0;
  #Loop over files in the collection
  *Q1 = select DATA_ID,DATA_NAME where COLL_NAME = '*Coll' and META_DATA_ATTR_NAME = 'Retention_Flag' and META_DATA_ATTR_VALUE = 'EXPIRED';
  foreach(*R1 in *Q1) {
    *File = *R1.DATA_NAME;
  # move the file to the archive
    *SourceFile = *Coll ++ "/" ++ *File;
    *DestFile = *Dest ++ "/" ++ *File;
    msiDataObjRename(*SourceFile,*DestFile,"0",*Status);
    if (*Status < 0) {
      writeLine("stdout", "File *SourceFile could not be archived");
    }
    else { *Count = *Count + 1;}
}
  writeLine("stdout", "Migrated *Count files to the archive *Dest");
}
INPUT *Collrel = "sub2", *Archiverel = "archive"
OUTPUT ruleExecOut
