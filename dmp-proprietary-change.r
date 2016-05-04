myTestRule {
# dmp-proprietary-change.r
# check files for expiration of proprietary period (6 months from creation)
# and set public access
  *Home="/$rodsZoneClient/home/$userNameClient/";
  *Path= *Home ++ *RelativeCollection;
  checkCollInput (*Path);
  msiGetSystemTime(*TimeU,"unix");
  *Tim = double(*TimeU);
  *Del = 182 * 24 * 3600;
  *Q0 = select USER_ID where USER_NAME = 'anonymous';
  foreach (*R0 in *Q0) { *Anonid = *R0.USER_ID; }
# Loop over files
  *Q1 = select DATA_NAME, DATA_CREATE_TIME, DATA_ID where COLL_NAME = '*Path';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    *Create = *R1.DATA_CREATE_TIME;
    *Dataid = *R1.DATA_ID;
# Check for files past proprietary period
    if (*Tim-double(*Create) >= *Del) {
      *Query4 = select DATA_ACCESS_TYPE, DATA_ACCESS_USER_ID where DATA_ACCESS_DATA_ID = '*Dataid';
#Loop over access controls for each file to avoid replicating access controls
      writeLine("stdout", "*Path/*File is past the proprietary period");
      *Count = 0;
      foreach(*Row4 in *Query4) {
        *Userdid = *Row4.DATA_ACCESS_USER_ID;
        *Datatype = *Row4.DATA_ACCESS_TYPE;
        if(*Userdid == *Anonid && *Datatype == "read") { *Count = 1;}
      }
      if (*Count == 0) {
        msiSetACL("default", "read", "anonymous", *Path);
        writeLine("stdout", "Set public access on *Path/*File");
      }
    }
  }
}
INPUT *RelativeCollection="derived",  *Acl = "read"
OUTPUT ruleExecOut

