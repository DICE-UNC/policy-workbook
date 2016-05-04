harvestHome {
# harvest.r
# harvest homework from student directories Class-INLS624
# restrict harvest to prior 8 days
# count weeks since Jan 11, 2016
# skip the 10th week
  *Start = 1452531302.;
  msiGetSystemTime(*Timen, "unix");
  *Time = double(*Timen);
  *Period = 7. * 24. * 3600.;
  *Week = (*Time - *Start) / *Period;
  *Sub = int (*Week);
  writeLine ("stdout", "Week *Sub of class INSL624");
  *Stu = list("buchanar", "culbert", "sdesai11", "mmhowell", "kelsey3", "mitchemp", "mweshy", "dragonp");
  *Home = "/$rodsZoneClient/home/$userNameClient/Home";
  *Part = "/$rodsZoneClient/home";
  foreach (*S in *Stu) {
    *ColStu = "*Part/*S/Class-INLS624";
    *Dest = "*Home/*S/*Sub";
    isColl (*Dest, "stdout", *Status);
    *Q1 = select DATA_NAME, DATA_CREATE_TIME where COLL_NAME = '*ColStu' and DATA_REPL_NUM = '0';
    foreach (*R1 in *Q1) {
      *File = *R1.DATA_NAME;
      isData (*Dest, *File, *Stat1);
      if (*Stat1 == "0") {
        *Filtim = double (*R1.DATA_CREATE_TIME);
        if ((*Time - *Filtim) < *Period) {
# copy the file into a subdirectory indexed by the week since the start
          *Path = "*Dest/*File";
          *Src = "*ColStu/*File";
          *Out = errormsg(msiDataObjCopy(*Src, *Path, "forceFlag=", *Sta), *Msg);
          if (*Out != 0) {
            writeLine("stdout", "Error message for *S for *Src");
          } 
          else {
            msiSetACL("default", "own", "rwmoore", *Path);
            msiSetACL("default", "read", *S, *Path);
            writeLine ("stdout", "*Src copied to *Path");
          }
        }
      }
    }
  }
}
INPUT null
OUTPUT ruleExecOut
