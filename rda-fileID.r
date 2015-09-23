myTestRule {
# rda-fileID.r
# find the DATA_ID associated with a file name
  checkFileInput (*File);
  *Coll = "/$rodsZoneClient/home/$userNameClient/" ++ *RelativeCollectionName;
  checkCollInput (*Coll);
  *Query = select DATA_ID where DATA_NAME = '*File' and COLL_NAME = '*Coll';
  foreach(*Row in *Query) {
    *Dataid = *Row.DATA_ID;
    writeLine("stdout", "Collection *Coll, File *File, File ID *Dataid");
  }
}
INPUT *File = 'foo1', *RelativeCollectionName = 'test'
OUTPUT ruleExecOut 
