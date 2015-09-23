myTestRule {
# rda-backup.r
# Test delayed execution
  *Home = "/$rodsZoneClient/home/$userNameClient/";
  *Source = *Home ++ *Collrel;
  checkCollInput (*Coll);
  *Dest = *Home ++ *Destrel;
  checkCollInput (*Dest);
  writeLine("stdout", "Backup collection *Source");
  delay("<PLUSET>1s</PLUSET><EF>7ds</EF>") {
    msiGetSystemTime(*Time, "human");
# Create backup collection with name *Dest/Check-Timestamp
#=============get current time, Timestamp is YYY-MM-DD.hh:mm:ss  ======================
    msiGetSystemTime(*TimeH, "human");
#============ create a collection for backup if it does not exist ===============
    *Lpath = *Dest ++ "/" ++ *TimeH;
    *Q1 = select count(COLL_NAME) where COLL_NAME = '*Lpath';
    foreach(*R1 in *Q1) {
    *Result = *R1.COLL_NAME;
    }
    if(*Result == "0") {
      msiCollCreate(*Lpath, "1", *Status);
      if(*Status < 0) {
        writeLine("serverlog", "Could not create backup collection");
        fail;
      }  # end of check on status
    }  # end of backup collection creation
    writeLine("serverLog", "Created Backup for *Source at *TimeH");
    msiCollRsync(*Source,*Lpath,*Resource, "IRODS_TO_IRODS", *Status);
    if(*Status < 0) {
      writeLine("serverlog", "Backup failed at *TimeH");
    }
  }
}
INPUT *Collrel = "test", *Destrel = "back1", *Resource = "testResc"
OUTPUT ruleExecOut
