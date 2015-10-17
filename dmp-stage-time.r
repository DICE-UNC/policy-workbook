stageByTime {
# dmp-stage-time.r
# copy files from a staging area into a new subdirectory each year
# extract year as extension from each file
# sort files into yearly subdirectories
  checkCollInput (*Srccoll);
  checkCollInput (*Destcoll);
  *Q1 = select DATA_NAME where COLL_NAME = '*Srccoll';
  foreach (*R1 in *Q1) {
    *File = *R1.DATA_NAME;
    msiSplitPathByKey(*File,".",*head,*B);
    *Src = *Srccoll ++ "/*File";
    *Destc = *Destcoll ++ "/*B";
    isColl(*Destc, "stdout", *Status);
    if (*Status >= 0) {
      *Dest = *Destc ++ "/*File"
      msiDataObjRename(*Src, *Dest, "0", *Status);
      writeLine("stdout","moved file from *Src to *Dest");
    }
  }
}
INPUT *Srccoll = "/dfcmain/home/rwmoore/test", *Destcoll = "/dfcmain/home/rwmoore/sensor"
OUTPUT ruleExecOut
