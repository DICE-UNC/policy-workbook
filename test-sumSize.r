sumSize {
# test-sumSize.r
# List the number of files and size for your collection
# checkRescInput (*Res, $rodsZoneClient);
#============ create a collection for reports if it does not exist ===============
#  createLogFile (*PathColl, "Reports", "Report", *Res, *LPath, *Lfile, *L_FD);
  *Q2 = select count(DATA_ID), sum(DATA_SIZE) where COLL_NAME like '*PathColl%';
  foreach (*R2 in *Q2) {
    *Num = *R2.DATA_ID;
    *Size = *R2.DATA_SIZE;
    *C2 = double(*Size)/1024./1024./1024.;
    *C1 = "$userNameClient";
    if (strlen(*C1) < 8) {*C1 = "*C1\t";}
#    writeLine("*Lfile", "*C1 has *Num files with size *C2 Gbytes");
    writeLine("stdout", "*C1 has *Num files with size *C2 Gbytes");
  }
}
INPUT *PathColl = "/$rodsZoneClient/home/$userNameClient", *Res = "LTLResc"
OUTPUT ruleExecOut
