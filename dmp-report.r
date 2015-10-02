reportCollection {
# dmp-report.r
# Identify publicly accessible collections
# List the number of files and size
  checkCollInput (*PathColl);
  checkRescInput (*Res, $rodsZoneClient);
#============ create a collection for reports if it does not exist ===============
  createLogFile (*PathColl, "Reports", "Report", *Res, *LPath, *Lfile, *L_FD);
 
  *Q0 = select USER_ID where USER_NAME = 'anonymous';
  foreach (*R0 in *Q0) {*Pub = *R0.USER_ID;}
  *Q1 = select COLL_ACCESS_COLL_ID where COLL_ACCESS_USER_ID = '*Pub';
  foreach (*R1 in *Q1) {
    *Collid = *R1.COLL_ACCESS_COLL_ID;
    *Q2 = select count(DATA_ID), sum(DATA_SIZE), COLL_NAME where COLL_ID = '*Collid';
    foreach (*R2 in *Q2) {
      *Num = *R2.DATA_ID;
      *Size = *R2.DATA_SIZE;
      *Coll = *R2.COLL_NAME;
      writeLine("*Lfile", "Public collection *Coll has *Num files with size *Size bytes");
    }
  }
}
INPUT *PathColl = "/$rodsZoneClient/home/$userNameClient", *Res = "demoResc"
OUTPUT ruleExecOut
