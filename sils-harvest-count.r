harvestCountHome {
# harvest-count.r
# count homework from student directories Class-INLS624
# restrict count to prior 7 days
# count weeks since Jan 11, 2016
# skip the 10th week
  *Start = 1452531302.;
  msiGetSystemTime(*Timen, "unix");
  *Time = double(*Timen);
  *Period = 7. * 24. * 3600.;
  *Week = (*Time - *Start) / *Period;
  *Sub = int (*Week);
  if (*Sub > 10) {*Sub = *Sub - 1; }
  writeLine ("stdout", "Week *Sub of class INSL624");
   *Stu = list("buchanar", "culbert", "sdesai11", "mmhowell", "kelsey3", "mitchemp", "mweshy", "dragonp");
  *Home = "/$rodsZoneClient/home/$userNameClient/Home";
  *Part = "/$rodsZoneClient/home";
  foreach (*S in *Stu) {
    *Count = 0;
    *ColStu = "*Part/*S/Class-INLS624";
     *Q1 = select DATA_NAME, DATA_REPL_NUM, DATA_CREATE_TIME where COLL_NAME = '*ColStu';
     foreach (*R1 in *Q1) {
#      *File = *R1.DATA_NAME;
#      *Rep = *R1.DATA_REPL_NUM;
#      *Filtim = double (*R1.DATA_CREATE_TIME);
#      if (*Rep == "0" && (*Time - *Filtim) < *Period) {
#        *Count = *Count + 1;
#        *t = datetime(*Filtim);
#        writeLine("stdout", "*S *Sub *Filtim *Time *Period *File *t");
#      }
     }
     writeLine ("stdout", "Found *Count files for week *Sub for *S");
   }
}
INPUT null
OUTPUT ruleExecOut
