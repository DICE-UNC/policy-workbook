reportCollection {
# dmp-report-size.r
# Identify publicly accessible collections
# List the number of files and size
  checkCollInput (*Coll);
  checkCollInput (*PathColl);
  checkRescInput (*Res, $rodsZoneClient);
#============ create a collection for reports if it does not exist ===============
  createLogFile (*PathColl, "Reports", "Report", *Res, *LPath, *Lfile, *L_FD);

  *Totsize = 0.0;
  *Q0 = select count(DATA_ID), sum(DATA_SIZE), COLL_NAME where COLL_NAME like '*Coll%';
  foreach (*R0 in *Q0) {
    *Colln = *R0.COLL_NAME;
    *Num = *R0.DATA_ID;
    *Size = *R0.DATA_SIZE;
    *Totsize = *Totsize + double (*Size);
    writeLine("*Lfile", "Collection *Colln has *Num files with size *Size bytes");
  }
  writeLine("*Lfile", "Total collection size is *Totsize bytes");
}
INPUT *Coll = '/$rodsZoneClient/home/$userNameClient/rules', *PathColl = "/$rodsZoneClient/home/$userNameClient", *Res = "demoResc"
OUTPUT ruleExecOut
