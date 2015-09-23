ListChanges {
# dmp-report-changes.r
# List all files in the version directory
#============ create a collection for log files if it does not exist ===============
  checkRescInput (*Res, $rodsZoneClient);
  createLogFile ("/Mauna/home/atmos/change", "log", "Change", *Res, *LPath, *Lfile, *Dfile, *L_FD);
 
  *Q2 = select DATA_NAME, COLL_NAME where COLL_NAME like '/Mauna/home/atmos/version%';
  foreach (*R2 in *Q2) {
    *Coll = *R2.COLL_NAME;
    *File = *R2.DATA_NAME;
    writeLine("Lfile", "*Coll/*File");
  }
}
INPUT *Res = "maunaRes"
OUTPUT ruleExecOut
